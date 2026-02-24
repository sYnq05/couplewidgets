import Foundation

struct CacheProfileSnapshot: Equatable {
	var name: String
	var initials: String
	var cityLabel: String?
	/// Country for display (from preset or reverse geocoding). Used when city is not in preset.
	var country: String?
	var lat: Double?
	var lon: Double?
}

struct CacheSnapshot: Equatable {
	var couple: CoupleState
	var me: CacheProfileSnapshot
	var partner: CacheProfileSnapshot

	var countdown: Countdown
	var note: Note
	var streak: Streak

	var lastCacheWriteAtUTC: Date?
}

extension CacheSnapshot {
	var miniLabel: String {
		"\(me.initials) ↔ \(partner.initials)"
	}

	var meCity: CityPreset? {
		guard let label = me.cityLabel, let lat = me.lat, let lon = me.lon, !label.isEmpty else { return nil }
		let country = me.country ?? CityPreset.cityByName(label)?.country ?? ""
		let tz = CityPreset.cityByName(label)?.timeZoneIdentifier ?? CityPreset.nearest(toLat: lat, lon: lon)?.timeZoneIdentifier ?? "UTC"
		return CityPreset(name: label, country: country, lat: lat, lon: lon, timeZoneIdentifier: tz)
	}

	var partnerCity: CityPreset? {
		guard let label = partner.cityLabel, let lat = partner.lat, let lon = partner.lon, !label.isEmpty else { return nil }
		let country = partner.country ?? CityPreset.cityByName(label)?.country ?? ""
		let tz = CityPreset.cityByName(label)?.timeZoneIdentifier ?? CityPreset.nearest(toLat: lat, lon: lon)?.timeZoneIdentifier ?? "UTC"
		return CityPreset(name: label, country: country, lat: lat, lon: lon, timeZoneIdentifier: tz)
	}
}

