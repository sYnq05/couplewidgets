import Foundation

/// Timezone resolution and hour-difference calculation for distance/city pairs (preset cities or nearest preset for coordinates).
enum TimeZoneDifference {
	/// Resolves timezone for a place: by preset city name, or by nearest preset when only coordinates are available.
	static func timeZone(cityName: String?, lat: Double?, lon: Double?) -> TimeZone? {
		if let name = cityName, !name.isEmpty, let preset = CityPreset.cityByName(name) {
			return TimeZone(identifier: preset.timeZoneIdentifier)
		}
		if let lat = lat, let lon = lon, let nearest = CityPreset.nearest(toLat: lat, lon: lon) {
			return TimeZone(identifier: nearest.timeZoneIdentifier)
		}
		return nil
	}

	/// Difference in hours (me - partner). Positive = me is ahead. Uses current date for DST.
	static func hoursDifference(me: TimeZone, partner: TimeZone, at date: Date = Date()) -> Int {
		let s1 = me.secondsFromGMT(for: date)
		let s2 = partner.secondsFromGMT(for: date)
		return (s1 - s2) / 3600
	}

	/// Resolves both timezones and returns hour difference, or nil if either cannot be resolved.
	static func hoursDifference(
		meCityName: String?, meLat: Double?, meLon: Double?,
		partnerCityName: String?, partnerLat: Double?, partnerLon: Double?,
		at date: Date = Date()
	) -> Int? {
		guard let tzMe = timeZone(cityName: meCityName, lat: meLat, lon: meLon),
		      let tzPartner = timeZone(cityName: partnerCityName, lat: partnerLat, lon: partnerLon) else {
			return nil
		}
		return hoursDifference(me: tzMe, partner: tzPartner, at: date)
	}
}
