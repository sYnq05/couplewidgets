import Foundation
import CloudKit

/// Result of pushing to CloudKit (for one-to-one pairing enforcement).
enum CloudKitPushResult {
	case success
	/// Partner tried to claim a code that is already linked to a different Apple ID.
	case partnerSlotAlreadyTaken
	case saveFailed
}

/// Syncs couple data to CloudKit (public database). Record type "Couple", recordName = normalized invite code (e.g. ABCD1234).
/// Owner/partner Apple IDs (ownerAppleId, partnerAppleId) enforce one-to-one: only that pair can sync.
/// Owner maps: me → owner*, partner → partner*. Partner maps: me → partner*, partner → owner*.
final class CloudKitSyncService {
	static let containerID = "iCloud.com.yourcompany.couplewidgets"
	private static let recordType = "Couple"
	private static let ownerAppleIdKey = "ownerAppleId"
	private static let partnerAppleIdKey = "partnerAppleId"

	private let container: CKContainer
	private let database: CKDatabase

	init(containerIdentifier: String = CloudKitSyncService.containerID) {
		container = CKContainer(identifier: containerIdentifier)
		database = container.publicCloudDatabase
	}

	/// Record name from invite code: normalized, no hyphen (e.g. ABCD-1234 → ABCD1234).
	private static func recordName(from inviteCode: String) -> String {
		InviteCodeGenerator.normalize(inviteCode).replacingOccurrences(of: "-", with: "")
	}

	// MARK: - Push

	/// Uploads current snapshot to CloudKit. Pass current Apple user identifier to enforce one-to-one pairing.
	/// Owner: sets ownerAppleId. Partner: fetches record; if partnerAppleId is already set to a different ID, returns .partnerSlotAlreadyTaken; else sets partnerAppleId and saves.
	func push(snapshot: CacheSnapshot, currentAppleId: String?) async -> CloudKitPushResult {
		guard snapshot.couple.isUnlocked,
		      snapshot.couple.paired,
		      let code = snapshot.couple.inviteCode,
		      !code.isEmpty else { return .success }

		let role = snapshot.couple.role
		guard role == .owner || role == .partner else { return .success }

		// Partner or owner without Apple ID must not write (would create unclaimable record or lose data).
		if currentAppleId == nil {
			return .success
		}

		let recordName = Self.recordName(from: code)
		guard !recordName.isEmpty else { return .success }
		let recordID = CKRecord.ID(recordName: recordName)

		if role == .partner, let appleId = currentAppleId {
			// Partner: fetch existing record and claim partner slot if still free.
			do {
				let existing = try await database.record(for: recordID)
				let existingPartnerId = existing[Self.partnerAppleIdKey] as? String
				if let existingPartnerId = existingPartnerId, existingPartnerId != appleId {
					return .partnerSlotAlreadyTaken
				}
				existing[Self.partnerAppleIdKey] = appleId
				set(record: existing, owner: snapshot.partner, partner: snapshot.me)
				setCommon(record: existing, countdown: snapshot.countdown, note: snapshot.note, streak: snapshot.streak)
				existing["inviteCode"] = InviteCodeGenerator.normalize(code)
				try await database.save(existing)
				return .success
			} catch let ckError as CKError where ckError.code == .unknownItem {
				// Record doesn't exist yet (owner hasn't pushed); create it and set partner as claimer.
				let record = CKRecord(recordType: Self.recordType, recordID: recordID)
				set(record: record, owner: snapshot.partner, partner: snapshot.me)
				record[Self.ownerAppleIdKey] = nil
				record[Self.partnerAppleIdKey] = appleId
				setCommon(record: record, countdown: snapshot.countdown, note: snapshot.note, streak: snapshot.streak)
				record["inviteCode"] = InviteCodeGenerator.normalize(code)
				do {
					try await database.save(record)
					return .success
				} catch {
					#if DEBUG
					print("[CloudKitSync] push failed: \(error)")
					#endif
					return .saveFailed
				}
			} catch {
				#if DEBUG
				print("[CloudKitSync] push failed: \(error)")
				#endif
				return .saveFailed
			}
		}

		// Owner: fetch existing record if any so we don't overwrite partnerAppleId.
		var record: CKRecord
		do {
			record = try await database.record(for: recordID)
		} catch let ckError as CKError where ckError.code == .unknownItem {
			record = CKRecord(recordType: Self.recordType, recordID: recordID)
			record[Self.partnerAppleIdKey] = nil
		} catch {
			#if DEBUG
			print("[CloudKitSync] push failed: \(error)")
			#endif
			return .saveFailed
		}
		set(record: record, owner: snapshot.me, partner: snapshot.partner)
		if let appleId = currentAppleId {
			record[Self.ownerAppleIdKey] = appleId
		}
		setCommon(record: record, countdown: snapshot.countdown, note: snapshot.note, streak: snapshot.streak)
		record["inviteCode"] = InviteCodeGenerator.normalize(code)

		do {
			try await database.save(record)
			return .success
		} catch {
			#if DEBUG
			print("[CloudKitSync] push failed: \(error)")
			#endif
			return .saveFailed
		}
	}

	private func set(record: CKRecord, owner: CacheProfileSnapshot, partner: CacheProfileSnapshot) {
		record["ownerName"] = owner.name
		record["ownerInitials"] = owner.initials
		record["ownerCityLabel"] = owner.cityLabel
		record["ownerCountry"] = owner.country
		record["ownerLat"] = owner.lat
		record["ownerLon"] = owner.lon
		record["partnerName"] = partner.name
		record["partnerInitials"] = partner.initials
		record["partnerCityLabel"] = partner.cityLabel
		record["partnerCountry"] = partner.country
		record["partnerLat"] = partner.lat
		record["partnerLon"] = partner.lon
	}

	private func setCommon(record: CKRecord, countdown: Countdown, note: Note, streak: Streak) {
		record["eventAtUTC"] = countdown.eventAtUTC?.timeIntervalSince1970
		record["countdownLabel"] = countdown.label
		record["noteText"] = note.text
		record["noteAuthorInitials"] = note.authorInitials
		record["noteAuthorIsMe"] = note.authorIsMe == true ? 1 : (note.authorIsMe == false ? 0 : nil)
		record["noteUpdatedAt"] = note.updatedAtUTC?.timeIntervalSince1970
		record["streakCount"] = streak.streakCount
		record["longestStreak"] = streak.longestStreak
		record["lastNoteAt"] = streak.lastNoteAtUTC?.timeIntervalSince1970
	}

	/// Deletes the couple record for the given invite code if it exists (e.g. after owner regenerates code). Returns true if deleted or already gone.
	func deleteRecordIfExists(inviteCode: String) async -> Bool {
		guard !inviteCode.isEmpty else { return true }
		let name = Self.recordName(from: inviteCode)
		guard !name.isEmpty else { return true }
		let recordID = CKRecord.ID(recordName: name)
		do {
			let record = try await database.record(for: recordID)
			try await database.deleteRecord(withID: record.recordID)
			return true
		} catch let ckError as CKError where ckError.code == .unknownItem {
			return true
		} catch {
			#if DEBUG
			print("[CloudKitSync] deleteRecord failed: \(error)")
			#endif
			return false
		}
	}

	/// Clears the partner slot in CloudKit when partner unlinks (so the code can be used by someone else).
	func releasePartnerSlot(inviteCode: String, partnerAppleId: String) async {
		guard !inviteCode.isEmpty, !partnerAppleId.isEmpty else { return }
		let name = Self.recordName(from: inviteCode)
		guard !name.isEmpty else { return }
		let recordID = CKRecord.ID(recordName: name)
		do {
			let record = try await database.record(for: recordID)
			let existingPartnerId = record[Self.partnerAppleIdKey] as? String
			guard existingPartnerId == partnerAppleId else { return }
			record[Self.partnerAppleIdKey] = nil
			record["partnerName"] = nil
			record["partnerInitials"] = nil
			record["partnerCityLabel"] = nil
			record["partnerCountry"] = nil
			record["partnerLat"] = nil
			record["partnerLon"] = nil
			try await database.save(record)
		} catch let ckError as CKError where ckError.code == .unknownItem {
			// Record already gone
		} catch {
			#if DEBUG
			print("[CloudKitSync] releasePartnerSlot failed: \(error)")
			#endif
		}
	}

	// MARK: - Pull

	/// Fetches couple record from CloudKit and returns a full CacheSnapshot (mapped by role). Nil if not found, error, or not authorized.
	/// Only runs when signed in (currentAppleId != nil) and the ID is ownerAppleId or partnerAppleId in the record (one-to-one enforcement).
	func pull(role: CoupleRole, current: CacheSnapshot, currentAppleId: String?) async -> CacheSnapshot? {
		guard current.couple.isUnlocked,
		      current.couple.paired,
		      let code = current.couple.inviteCode,
		      !code.isEmpty,
		      role == .owner || role == .partner,
		      currentAppleId != nil else { return nil }

		let recordName = Self.recordName(from: code)
		guard !recordName.isEmpty else { return nil }
		let recordID = CKRecord.ID(recordName: recordName)

		do {
			let record = try await database.record(for: recordID)
			guard let appleId = currentAppleId else { return nil }
			let ownerId = record[Self.ownerAppleIdKey] as? String
			let partnerId = record[Self.partnerAppleIdKey] as? String
			let isOwner = ownerId == appleId
			let isPartner = partnerId == appleId
			guard isOwner || isPartner else { return nil }
			return snapshot(from: record, role: role, current: current)
		} catch let ckError as CKError where ckError.code == .unknownItem {
			return nil
		} catch {
			#if DEBUG
			print("[CloudKitSync] pull failed: \(error)")
			#endif
			return nil
		}
	}

	private func snapshot(from record: CKRecord, role: CoupleRole, current: CacheSnapshot) -> CacheSnapshot? {
		let owner = profile(from: record, prefix: "owner")
		let partner = profile(from: record, prefix: "partner")
		let countdown = Countdown(
			eventAtUTC: (record["eventAtUTC"] as? Double).map { Date(timeIntervalSince1970: $0) },
			label: record["countdownLabel"] as? String
		)
		let noteAuthorIsMe: Bool? = (record["noteAuthorIsMe"] as? Int).map { $0 == 1 }
		let note = Note(
			text: record["noteText"] as? String ?? "",
			authorInitials: record["noteAuthorInitials"] as? String ?? "?",
			authorIsMe: noteAuthorIsMe,
			updatedAtUTC: (record["noteUpdatedAt"] as? Double).map { Date(timeIntervalSince1970: $0) }
		)
		let streak = Streak(
			streakCount: record["streakCount"] as? Int ?? 1,
			longestStreak: record["longestStreak"] as? Int ?? 1,
			lastNoteAtUTC: (record["lastNoteAt"] as? Double).map { Date(timeIntervalSince1970: $0) }
		)

		let me: CacheProfileSnapshot
		let partnerProfile: CacheProfileSnapshot
		if role == .owner {
			me = owner.name.isEmpty ? current.me : owner
			partnerProfile = partner.name.isEmpty ? current.partner : partner
		} else {
			me = partner.name.isEmpty ? current.me : partner
			partnerProfile = owner.name.isEmpty ? current.partner : owner
		}

		return CacheSnapshot(
			couple: current.couple,
			me: me,
			partner: partnerProfile,
			countdown: countdown,
			note: note,
			streak: streak,
			lastCacheWriteAtUTC: current.lastCacheWriteAtUTC
		)
	}

	private func profile(from record: CKRecord, prefix: String) -> CacheProfileSnapshot {
		let name = record["\(prefix)Name"] as? String ?? ""
		let initials = record["\(prefix)Initials"] as? String ?? "?"
		let cityLabel = record["\(prefix)CityLabel"] as? String
		let country = record["\(prefix)Country"] as? String
		let lat = record["\(prefix)Lat"] as? Double
		let lon = record["\(prefix)Lon"] as? Double
		return CacheProfileSnapshot(name: name, initials: initials, cityLabel: cityLabel, country: country, lat: lat, lon: lon)
	}
}
