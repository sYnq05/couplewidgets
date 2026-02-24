import Foundation
import Combine
import WidgetKit

@MainActor
final class AppModel: ObservableObject {
	@Published private(set) var snapshot: CacheSnapshot
	let cache: CacheService
	let appleAuth: AppleAuthService
	private let cloudKit: CloudKitSyncService

	init(cache: CacheService? = nil, cloudKit: CloudKitSyncService? = nil, appleAuth: AppleAuthService? = nil) {
		let c = cache ?? CacheService()
		self.cache = c
		self.appleAuth = appleAuth ?? AppleAuthService()
		self.cloudKit = cloudKit ?? CloudKitSyncService()
		self.cache.ensureDefaultsIfNeeded(nowUTC: Date())
		self.snapshot = c.readSnapshot()
	}

	var isUsingStandardFallback: Bool {
		cache.isUsingStandardFallback
	}

	func refreshFromCache() {
		snapshot = cache.readSnapshot()
	}

	/// Fetches latest data from CloudKit and merges into local cache. When signed in with Apple, only returns data if this device is part of the pair (owner/partner).
	func syncPull() async {
		let current = snapshot
		guard current.couple.paired, let code = current.couple.inviteCode, !code.isEmpty else { return }
		let role = current.couple.role
		guard role == .owner || role == .partner else { return }
		let appleId = appleAuth.currentUserIdentifier
		guard let updated = await cloudKit.pull(role: role, current: current, currentAppleId: appleId) else { return }
		cache.writeSnapshot(updated, nowUTC: Date())
		snapshot = updated
		reloadAllWidgetTimelines()
	}

	/// Pushes current snapshot to CloudKit. Returns result for partner-claim (e.g. .partnerSlotAlreadyTaken). Call after redeem as partner to claim the slot.
	func syncPush() async -> CloudKitPushResult {
		let result = await cloudKit.push(snapshot: snapshot, currentAppleId: appleAuth.currentUserIdentifier)
		if case .success = result {
			// Optionally reload widgets after push
		}
		return result
	}

	func commit(_ mutate: (inout CacheSnapshot) -> Void) {
		var updated = snapshot
		mutate(&updated)
		snapshot = updated
		cache.writeSnapshot(updated, nowUTC: Date())
		reloadAllWidgetTimelines()
	}

	func buySimulate() {
		commit { snap in
			var rng = SystemRandomNumberGenerator()
			snap = PairingServiceMock.buySimulate(existing: snap, nowUTC: Date(), random: &rng)
		}
	}

	func regenerateInviteCode() {
		let oldCode = snapshot.couple.inviteCode
		commit { snap in
			var rng = SystemRandomNumberGenerator()
			snap = PairingServiceMock.regenerateInviteCode(existing: snap, random: &rng)
		}
		if let code = oldCode, !code.isEmpty {
			cache.setPendingDeleteInviteCode(code)
			Task {
				let ok = await cloudKit.deleteRecordIfExists(inviteCode: code)
				if ok { cache.setPendingDeleteInviteCode(nil) }
			}
		}
	}

	/// Retries deleting the pending old record (e.g. after regenerate while offline). Call when app becomes active.
	func retryPendingRecordDeletes() async {
		guard let code = cache.pendingDeleteInviteCode(), !code.isEmpty else { return }
		let ok = await cloudKit.deleteRecordIfExists(inviteCode: code)
		if ok { cache.setPendingDeleteInviteCode(nil) }
	}

	func redeemInviteCode(_ input: String) {
		commit { snap in
			snap = PairingServiceMock.redeemCode(existing: snap, input: input)
		}
	}

	func unlink() {
		let code = snapshot.couple.inviteCode
		let wasPartner = snapshot.couple.role == .partner
		let appleId = appleAuth.currentUserIdentifier
		commit { snap in
			snap = PairingServiceMock.unlink(existing: snap)
		}
		if wasPartner, let c = code, !c.isEmpty, let aid = appleId {
			Task { await cloudKit.releasePartnerSlot(inviteCode: c, partnerAppleId: aid) }
		}
		CloudKitSubscriptionService.shared.setupSubscription(inviteCode: nil)
	}

	func updateMyName(_ name: String) {
		commit { snap in
			snap.me.name = name
			snap.me.initials = InitialsFormatter.initials(from: name, fallback: "A")
		}
	}

	func updatePartnerName(_ name: String) {
		commit { snap in
			snap.partner.name = name
			snap.partner.initials = InitialsFormatter.initials(from: name, fallback: "B")
		}
	}

	func setMyCity(_ city: CityPreset?) {
		commit { snap in
			snap.me.cityLabel = city?.name
			snap.me.country = city?.country
			snap.me.lat = city?.lat
			snap.me.lon = city?.lon
		}
	}

	/// Stores exact coordinates and optional display label/country (e.g. from reverse geocoding or nearest preset).
	func setMyLocation(lat: Double, lon: Double, cityLabel: String?, country: String?) {
		let trim = { (s: String?) -> String? in
			guard let t = s?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
			return t
		}
		commit { snap in
			snap.me.lat = lat
			snap.me.lon = lon
			snap.me.cityLabel = trim(cityLabel)
			snap.me.country = trim(country)
		}
	}

	func setPartnerCity(_ city: CityPreset?) {
		commit { snap in
			snap.partner.cityLabel = city?.name
			snap.partner.country = city?.country
			snap.partner.lat = city?.lat
			snap.partner.lon = city?.lon
		}
	}

	func setCountdownEvent(_ date: Date?, label: String? = nil) {
		commit { snap in
			snap.countdown.eventAtUTC = date
			if let label = label {
				let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
				snap.countdown.label = trimmed.isEmpty ? nil : String(trimmed.prefix(Countdown.labelMaxLength))
			}
		}
	}

	func saveNote(text: String, authorInitials: String, authorIsMe: Bool) {
		let trimmed = String(text.prefix(100)).trimmingCharacters(in: .whitespacesAndNewlines)
		let now = Date()
		commit { snap in
			snap.note.text = trimmed
			snap.note.authorInitials = InitialsFormatter.sanitize(authorInitials, fallback: snap.me.initials)
			snap.note.authorIsMe = authorIsMe
			snap.note.updatedAtUTC = now
			snap.streak = StreakEngine.applyNoteUpdate(existing: snap.streak, nowUTC: now)
		}
	}

	func resetDistance() {
		commit { snap in
			snap.me.cityLabel = nil
			snap.me.country = nil
			snap.me.lat = nil
			snap.me.lon = nil
			snap.partner.cityLabel = nil
			snap.partner.country = nil
			snap.partner.lat = nil
			snap.partner.lon = nil
		}
	}

	func resetCountdown() {
		commit { snap in
			snap.countdown.eventAtUTC = nil
			snap.countdown.label = nil
		}
	}

	func resetNote() {
		saveNote(text: "", authorInitials: snapshot.me.initials, authorIsMe: true)
	}

	private func reloadAllWidgetTimelines() {
		WidgetCenter.shared.reloadAllTimelines()
	}
}

