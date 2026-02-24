import Foundation

struct CityPreset: Equatable, Hashable, Identifiable {
	var id: String { name }
	let name: String
	let country: String
	let lat: Double
	let lon: Double
	/// IANA time zone identifier (e.g. "Europe/Berlin") for time-difference calculation.
	let timeZoneIdentifier: String
}

/// One country with its cities for two-step picker (country → city). Names sorted alphabetically.
struct CountryPreset: Identifiable {
	var id: String { name }
	let name: String
	let cities: [CityPreset]
}

extension CityPreset {
	static let all: [CityPreset] = CountryPreset.all.flatMap(\.cities)

	static func cityByName(_ name: String) -> CityPreset? {
		guard !name.isEmpty else { return nil }
		return all.first(where: { $0.name == name })
	}

	/// Returns the preset city closest to the given coordinates (by Haversine distance).
	static func nearest(toLat lat: Double, lon: Double) -> CityPreset? {
		all.min(by: { a, b in
			DistanceCalculator.haversineKm(lat1: lat, lon1: lon, lat2: a.lat, lon2: a.lon) < DistanceCalculator.haversineKm(lat1: lat, lon1: lon, lat2: b.lat, lon2: b.lon)
		})
	}
}

extension CountryPreset {
	/// Countries and cities both sorted alphabetically (localized).
	static let all: [CountryPreset] = [
		CountryPreset(name: "China", cities: [
			CityPreset(name: "Beijing", country: "China", lat: 39.9042, lon: 116.4074, timeZoneIdentifier: "Asia/Shanghai"),
			CityPreset(name: "Chengdu", country: "China", lat: 30.5728, lon: 104.0668, timeZoneIdentifier: "Asia/Shanghai"),
			CityPreset(name: "Chongqing", country: "China", lat: 29.5630, lon: 106.5516, timeZoneIdentifier: "Asia/Shanghai"),
			CityPreset(name: "Dongguan", country: "China", lat: 23.0205, lon: 113.7518, timeZoneIdentifier: "Asia/Shanghai"),
			CityPreset(name: "Guangzhou", country: "China", lat: 23.1291, lon: 113.2644, timeZoneIdentifier: "Asia/Shanghai"),
			CityPreset(name: "Hangzhou", country: "China", lat: 30.2741, lon: 120.1551, timeZoneIdentifier: "Asia/Shanghai"),
			CityPreset(name: "Nanjing", country: "China", lat: 32.0603, lon: 118.7969, timeZoneIdentifier: "Asia/Shanghai"),
			CityPreset(name: "Shanghai", country: "China", lat: 31.2304, lon: 121.4737, timeZoneIdentifier: "Asia/Shanghai"),
			CityPreset(name: "Shenzhen", country: "China", lat: 22.5431, lon: 114.0579, timeZoneIdentifier: "Asia/Shanghai"),
			CityPreset(name: "Suzhou", country: "China", lat: 31.2989, lon: 120.5853, timeZoneIdentifier: "Asia/Shanghai"),
			CityPreset(name: "Tianjin", country: "China", lat: 39.3434, lon: 117.3616, timeZoneIdentifier: "Asia/Shanghai"),
			CityPreset(name: "Wuhan", country: "China", lat: 30.5928, lon: 114.3055, timeZoneIdentifier: "Asia/Shanghai"),
			CityPreset(name: "Xi'an", country: "China", lat: 34.3416, lon: 108.9398, timeZoneIdentifier: "Asia/Shanghai"),
		]),
		CountryPreset(name: "Deutschland", cities: [
			CityPreset(name: "Berlin", country: "Deutschland", lat: 52.5200, lon: 13.4050, timeZoneIdentifier: "Europe/Berlin"),
			CityPreset(name: "Bonn", country: "Deutschland", lat: 50.7374, lon: 7.0982, timeZoneIdentifier: "Europe/Berlin"),
			CityPreset(name: "Bremen", country: "Deutschland", lat: 53.0793, lon: 8.8017, timeZoneIdentifier: "Europe/Berlin"),
			CityPreset(name: "Dortmund", country: "Deutschland", lat: 51.5136, lon: 7.4653, timeZoneIdentifier: "Europe/Berlin"),
			CityPreset(name: "Dresden", country: "Deutschland", lat: 51.0504, lon: 13.7373, timeZoneIdentifier: "Europe/Berlin"),
			CityPreset(name: "Düsseldorf", country: "Deutschland", lat: 51.2277, lon: 6.7735, timeZoneIdentifier: "Europe/Berlin"),
			CityPreset(name: "Essen", country: "Deutschland", lat: 51.4556, lon: 7.0116, timeZoneIdentifier: "Europe/Berlin"),
			CityPreset(name: "Frankfurt am Main", country: "Deutschland", lat: 50.1109, lon: 8.6821, timeZoneIdentifier: "Europe/Berlin"),
			CityPreset(name: "Hamburg", country: "Deutschland", lat: 53.5511, lon: 9.9937, timeZoneIdentifier: "Europe/Berlin"),
			CityPreset(name: "Hannover", country: "Deutschland", lat: 52.3759, lon: 9.7320, timeZoneIdentifier: "Europe/Berlin"),
			CityPreset(name: "Köln", country: "Deutschland", lat: 50.9375, lon: 6.9603, timeZoneIdentifier: "Europe/Berlin"),
			CityPreset(name: "Leipzig", country: "Deutschland", lat: 51.3397, lon: 12.3731, timeZoneIdentifier: "Europe/Berlin"),
			CityPreset(name: "München", country: "Deutschland", lat: 48.1351, lon: 11.5820, timeZoneIdentifier: "Europe/Berlin"),
			CityPreset(name: "Münster", country: "Deutschland", lat: 51.9607, lon: 7.6261, timeZoneIdentifier: "Europe/Berlin"),
			CityPreset(name: "Nürnberg", country: "Deutschland", lat: 49.4521, lon: 11.0767, timeZoneIdentifier: "Europe/Berlin"),
			CityPreset(name: "Recklinghausen", country: "Deutschland", lat: 51.6138, lon: 7.1974, timeZoneIdentifier: "Europe/Berlin"),
			CityPreset(name: "Stuttgart", country: "Deutschland", lat: 48.7758, lon: 9.1829, timeZoneIdentifier: "Europe/Berlin"),
		]),
		CountryPreset(name: "Frankreich", cities: [
			CityPreset(name: "Paris", country: "Frankreich", lat: 48.8566, lon: 2.3522, timeZoneIdentifier: "Europe/Paris"),
		]),
		CountryPreset(name: "Großbritannien", cities: [
			CityPreset(name: "London", country: "Großbritannien", lat: 51.5074, lon: -0.1278, timeZoneIdentifier: "Europe/London"),
		]),
		CountryPreset(name: "Italien", cities: [
			CityPreset(name: "Rom", country: "Italien", lat: 41.9028, lon: 12.4964, timeZoneIdentifier: "Europe/Rome"),
		]),
		CountryPreset(name: "Niederlande", cities: [
			CityPreset(name: "Amsterdam", country: "Niederlande", lat: 52.3676, lon: 4.9041, timeZoneIdentifier: "Europe/Amsterdam"),
		]),
		CountryPreset(name: "Österreich", cities: [
			CityPreset(name: "Graz", country: "Österreich", lat: 47.0707, lon: 15.4395, timeZoneIdentifier: "Europe/Vienna"),
			CityPreset(name: "Salzburg", country: "Österreich", lat: 47.8095, lon: 13.0550, timeZoneIdentifier: "Europe/Vienna"),
			CityPreset(name: "Wien", country: "Österreich", lat: 48.2082, lon: 16.3738, timeZoneIdentifier: "Europe/Vienna"),
		]),
		CountryPreset(name: "Schweiz", cities: [
			CityPreset(name: "Basel", country: "Schweiz", lat: 47.5596, lon: 7.5886, timeZoneIdentifier: "Europe/Zurich"),
			CityPreset(name: "Bern", country: "Schweiz", lat: 46.9480, lon: 7.4474, timeZoneIdentifier: "Europe/Zurich"),
			CityPreset(name: "Genf", country: "Schweiz", lat: 46.2044, lon: 6.1432, timeZoneIdentifier: "Europe/Zurich"),
			CityPreset(name: "Zürich", country: "Schweiz", lat: 47.3769, lon: 8.5417, timeZoneIdentifier: "Europe/Zurich"),
		]),
		CountryPreset(name: "Spanien", cities: [
			CityPreset(name: "Barcelona", country: "Spanien", lat: 41.3851, lon: 2.1734, timeZoneIdentifier: "Europe/Madrid"),
		]),
		CountryPreset(name: "USA", cities: [
			CityPreset(name: "Austin", country: "USA", lat: 30.2672, lon: -97.7431, timeZoneIdentifier: "America/Chicago"),
			CityPreset(name: "Boston", country: "USA", lat: 42.3601, lon: -71.0589, timeZoneIdentifier: "America/New_York"),
			CityPreset(name: "Chicago", country: "USA", lat: 41.8781, lon: -87.6298, timeZoneIdentifier: "America/Chicago"),
			CityPreset(name: "Denver", country: "USA", lat: 39.7392, lon: -104.9903, timeZoneIdentifier: "America/Denver"),
			CityPreset(name: "Los Angeles", country: "USA", lat: 34.0522, lon: -118.2437, timeZoneIdentifier: "America/Los_Angeles"),
			CityPreset(name: "Miami", country: "USA", lat: 25.7617, lon: -80.1918, timeZoneIdentifier: "America/New_York"),
			CityPreset(name: "New York City", country: "USA", lat: 40.7128, lon: -74.0060, timeZoneIdentifier: "America/New_York"),
			CityPreset(name: "San Francisco", country: "USA", lat: 37.7749, lon: -122.4194, timeZoneIdentifier: "America/Los_Angeles"),
			CityPreset(name: "Seattle", country: "USA", lat: 47.6062, lon: -122.3321, timeZoneIdentifier: "America/Los_Angeles"),
			CityPreset(name: "Washington DC", country: "USA", lat: 38.9072, lon: -77.0369, timeZoneIdentifier: "America/New_York"),
		]),
	].sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
}
