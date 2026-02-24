import Foundation

final class CacheService {
	let suiteName: String
	private let defaults: UserDefaults
	let isUsingStandardFallback: Bool

	init(suiteName: String = AppGroupKeys.suiteName) {
		self.suiteName = suiteName
		if let ud = UserDefaults(suiteName: suiteName) {
			self.defaults = ud
			self.isUsingStandardFallback = false
		} else {
			self.defaults = .standard
			self.isUsingStandardFallback = true
		}
	}

	func ensureDefaultsIfNeeded(nowUTC: Date = Date()) {
		if defaults.bool(forKey: AppGroupKeys.hasInitialized) {
			return
		}

		defaults.set(true, forKey: AppGroupKeys.hasInitialized)

		defaults.set(false, forKey: AppGroupKeys.paired)
		defaults.set(CoupleRole.none.rawValue, forKey: AppGroupKeys.role)
		defaults.set(CoupleEntitlement.unlocked.rawValue, forKey: AppGroupKeys.entitlement)
		defaults.removeObject(forKey: AppGroupKeys.inviteCode)

		defaults.set("Me", forKey: AppGroupKeys.myName)
		defaults.set("A", forKey: AppGroupKeys.myInitials)
		defaults.set("", forKey: AppGroupKeys.myCityLabel)
		defaults.removeObject(forKey: AppGroupKeys.myCountry)
		defaults.removeObject(forKey: AppGroupKeys.myLat)
		defaults.removeObject(forKey: AppGroupKeys.myLon)

		defaults.set("Partner", forKey: AppGroupKeys.partnerName)
		defaults.set("B", forKey: AppGroupKeys.partnerInitials)
		defaults.set("", forKey: AppGroupKeys.partnerCityLabel)
		defaults.removeObject(forKey: AppGroupKeys.partnerCountry)
		defaults.removeObject(forKey: AppGroupKeys.partnerLat)
		defaults.removeObject(forKey: AppGroupKeys.partnerLon)

		defaults.set(0, forKey: AppGroupKeys.distanceKm)
		defaults.set("A ↔ B", forKey: AppGroupKeys.distanceLabel)

		defaults.removeObject(forKey: AppGroupKeys.eventAtUTC)
		defaults.set("Set date", forKey: AppGroupKeys.countdownDisplay)

		defaults.set("", forKey: AppGroupKeys.noteText)
		defaults.set("A", forKey: AppGroupKeys.noteAuthorInitials)
		defaults.set(true, forKey: AppGroupKeys.noteAuthorIsMe)
		defaults.removeObject(forKey: AppGroupKeys.noteUpdatedAt)

		defaults.set(1, forKey: AppGroupKeys.streakCount)
		defaults.set(1, forKey: AppGroupKeys.longestStreak)
		defaults.removeObject(forKey: AppGroupKeys.lastNoteAt)

		defaults.set(nowUTC.timeIntervalSince1970, forKey: AppGroupKeys.lastCacheWriteAt)
		defaults.synchronize()
	}

	func readSnapshot() -> CacheSnapshot {
		let role = CoupleRole(rawValue: defaults.string(forKey: AppGroupKeys.role) ?? "") ?? .none
		let entitlement = CoupleEntitlement(rawValue: defaults.string(forKey: AppGroupKeys.entitlement) ?? "") ?? .unlocked
		let paired = defaults.bool(forKey: AppGroupKeys.paired)
		let inviteCode = defaults.string(forKey: AppGroupKeys.inviteCode)

		let meName = defaults.string(forKey: AppGroupKeys.myName) ?? "Me"
		let meInitials = defaults.string(forKey: AppGroupKeys.myInitials) ?? "A"
		let meCityLabel = defaults.string(forKey: AppGroupKeys.myCityLabel)
		let meCountry = defaults.string(forKey: AppGroupKeys.myCountry)
		let meLat = readDoubleOptional(forKey: AppGroupKeys.myLat)
		let meLon = readDoubleOptional(forKey: AppGroupKeys.myLon)

		let partnerName = defaults.string(forKey: AppGroupKeys.partnerName) ?? "Partner"
		let partnerInitials = defaults.string(forKey: AppGroupKeys.partnerInitials) ?? "B"
		let partnerCityLabel = defaults.string(forKey: AppGroupKeys.partnerCityLabel)
		let partnerCountry = defaults.string(forKey: AppGroupKeys.partnerCountry)
		let partnerLat = readDoubleOptional(forKey: AppGroupKeys.partnerLat)
		let partnerLon = readDoubleOptional(forKey: AppGroupKeys.partnerLon)

		let eventInterval = readDoubleOptional(forKey: AppGroupKeys.eventAtUTC)
		let eventAtUTC = eventInterval.map { Date(timeIntervalSince1970: $0) }
		let countdownLabel = defaults.string(forKey: AppGroupKeys.countdownLabel)
		let countdown = Countdown(eventAtUTC: eventAtUTC, label: countdownLabel)

		let noteText = defaults.string(forKey: AppGroupKeys.noteText) ?? ""
		let noteAuthor = defaults.string(forKey: AppGroupKeys.noteAuthorInitials) ?? meInitials
		let noteAuthorIsMe = defaults.object(forKey: AppGroupKeys.noteAuthorIsMe) as? Bool
		let noteUpdatedInterval = readDoubleOptional(forKey: AppGroupKeys.noteUpdatedAt)
		let noteUpdatedAtUTC = noteUpdatedInterval.map { Date(timeIntervalSince1970: $0) }
		let note = Note(text: noteText, authorInitials: noteAuthor, authorIsMe: noteAuthorIsMe, updatedAtUTC: noteUpdatedAtUTC)

		let streakCount = defaults.integer(forKey: AppGroupKeys.streakCount)
		let longest = defaults.integer(forKey: AppGroupKeys.longestStreak)
		let lastNoteInterval = readDoubleOptional(forKey: AppGroupKeys.lastNoteAt)
		let lastNoteAtUTC = lastNoteInterval.map { Date(timeIntervalSince1970: $0) }
		let streak = Streak(
			streakCount: max(1, streakCount),
			longestStreak: max(1, longest),
			lastNoteAtUTC: lastNoteAtUTC
		)

		let lastWriteInterval = readDoubleOptional(forKey: AppGroupKeys.lastCacheWriteAt)
		let lastWriteUTC = lastWriteInterval.map { Date(timeIntervalSince1970: $0) }

		return CacheSnapshot(
			couple: CoupleState(role: role, entitlement: entitlement, paired: paired, inviteCode: inviteCode),
			me: CacheProfileSnapshot(name: meName, initials: meInitials, cityLabel: meCityLabel, country: meCountry, lat: meLat, lon: meLon),
			partner: CacheProfileSnapshot(name: partnerName, initials: partnerInitials, cityLabel: partnerCityLabel, country: partnerCountry, lat: partnerLat, lon: partnerLon),
			countdown: countdown,
			note: note,
			streak: streak,
			lastCacheWriteAtUTC: lastWriteUTC
		)
	}

	private func readDoubleOptional(forKey key: String) -> Double? {
		guard let number = defaults.object(forKey: key) as? NSNumber else { return nil }
		return number.doubleValue
	}

	func writeSnapshot(_ snapshot: CacheSnapshot, nowUTC: Date = Date()) {
		defaults.set(snapshot.couple.paired, forKey: AppGroupKeys.paired)
		defaults.set(snapshot.couple.role.rawValue, forKey: AppGroupKeys.role)
		defaults.set(snapshot.couple.entitlement.rawValue, forKey: AppGroupKeys.entitlement)
		if let code = snapshot.couple.inviteCode, !code.isEmpty {
			defaults.set(code, forKey: AppGroupKeys.inviteCode)
		} else {
			defaults.removeObject(forKey: AppGroupKeys.inviteCode)
		}

		defaults.set(snapshot.me.name, forKey: AppGroupKeys.myName)
		defaults.set(snapshot.me.initials, forKey: AppGroupKeys.myInitials)
		defaults.set(snapshot.partner.name, forKey: AppGroupKeys.partnerName)
		defaults.set(snapshot.partner.initials, forKey: AppGroupKeys.partnerInitials)

		writeCity(label: snapshot.me.cityLabel, country: snapshot.me.country, lat: snapshot.me.lat, lon: snapshot.me.lon, labelKey: AppGroupKeys.myCityLabel, countryKey: AppGroupKeys.myCountry, latKey: AppGroupKeys.myLat, lonKey: AppGroupKeys.myLon)
		writeCity(label: snapshot.partner.cityLabel, country: snapshot.partner.country, lat: snapshot.partner.lat, lon: snapshot.partner.lon, labelKey: AppGroupKeys.partnerCityLabel, countryKey: AppGroupKeys.partnerCountry, latKey: AppGroupKeys.partnerLat, lonKey: AppGroupKeys.partnerLon)

		if let event = snapshot.countdown.eventAtUTC {
			defaults.set(event.timeIntervalSince1970, forKey: AppGroupKeys.eventAtUTC)
		} else {
			defaults.removeObject(forKey: AppGroupKeys.eventAtUTC)
		}
		let cdLabel = snapshot.countdown.label?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		if cdLabel.isEmpty {
			defaults.removeObject(forKey: AppGroupKeys.countdownLabel)
		} else {
			defaults.set(String(cdLabel.prefix(Countdown.labelMaxLength)), forKey: AppGroupKeys.countdownLabel)
		}
		defaults.set(CountdownFormatter.displayString(eventAtUTC: snapshot.countdown.eventAtUTC, nowUTC: nowUTC), forKey: AppGroupKeys.countdownDisplay)

		defaults.set(snapshot.note.text, forKey: AppGroupKeys.noteText)
		defaults.set(snapshot.note.authorInitials, forKey: AppGroupKeys.noteAuthorInitials)
		if let authorIsMe = snapshot.note.authorIsMe {
			defaults.set(authorIsMe, forKey: AppGroupKeys.noteAuthorIsMe)
		} else {
			defaults.removeObject(forKey: AppGroupKeys.noteAuthorIsMe)
		}
		if let updatedAt = snapshot.note.updatedAtUTC {
			defaults.set(updatedAt.timeIntervalSince1970, forKey: AppGroupKeys.noteUpdatedAt)
		} else {
			defaults.removeObject(forKey: AppGroupKeys.noteUpdatedAt)
		}

		defaults.set(snapshot.streak.streakCount, forKey: AppGroupKeys.streakCount)
		defaults.set(snapshot.streak.longestStreak, forKey: AppGroupKeys.longestStreak)
		if let lastNoteAt = snapshot.streak.lastNoteAtUTC {
			defaults.set(lastNoteAt.timeIntervalSince1970, forKey: AppGroupKeys.lastNoteAt)
		} else {
			defaults.removeObject(forKey: AppGroupKeys.lastNoteAt)
		}

		let miniLabel = snapshot.miniLabel
		defaults.set(miniLabel, forKey: AppGroupKeys.distanceLabel)
		if let meCity = snapshot.meCity, let partnerCity = snapshot.partnerCity {
			let km = DistanceCalculator.haversineKm(lat1: meCity.lat, lon1: meCity.lon, lat2: partnerCity.lat, lon2: partnerCity.lon)
			defaults.set(km, forKey: AppGroupKeys.distanceKm)
		} else {
			defaults.set(0, forKey: AppGroupKeys.distanceKm)
		}

		defaults.set(nowUTC.timeIntervalSince1970, forKey: AppGroupKeys.lastCacheWriteAt)
		defaults.synchronize()
	}

	func setPendingDeleteInviteCode(_ code: String?) {
		if let code = code, !code.isEmpty {
			defaults.set(code, forKey: AppGroupKeys.pendingDeleteInviteCode)
		} else {
			defaults.removeObject(forKey: AppGroupKeys.pendingDeleteInviteCode)
		}
		defaults.synchronize()
	}

	func pendingDeleteInviteCode() -> String? {
		defaults.string(forKey: AppGroupKeys.pendingDeleteInviteCode)
	}

	private func writeCity(label: String?, country: String?, lat: Double?, lon: Double?, labelKey: String, countryKey: String, latKey: String, lonKey: String) {
		let cleanLabel = (label ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
		defaults.set(cleanLabel, forKey: labelKey)
		let cleanCountry = (country ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
		if cleanCountry.isEmpty {
			defaults.removeObject(forKey: countryKey)
		} else {
			defaults.set(cleanCountry, forKey: countryKey)
		}
		if let lat, let lon, !cleanLabel.isEmpty {
			defaults.set(lat, forKey: latKey)
			defaults.set(lon, forKey: lonKey)
		} else {
			defaults.removeObject(forKey: latKey)
			defaults.removeObject(forKey: lonKey)
		}
	}
}

