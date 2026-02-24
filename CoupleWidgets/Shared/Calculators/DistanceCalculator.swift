import Foundation

enum DistanceCalculator {
	private static let earthRadiusKm: Double = 6371.0

	/// Haversine distance in km (exact coordinates). Returns nil if any coordinate is missing.
	static func haversineKm(lat1: Double?, lon1: Double?, lat2: Double?, lon2: Double?) -> Int? {
		guard let lat1 = lat1, let lon1 = lon1, let lat2 = lat2, let lon2 = lon2 else { return nil }
		return haversineKm(lat1: lat1, lon1: lon1, lat2: lat2, lon2: lon2)
	}

	static func haversineKm(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Int {
		let φ1 = lat1 * .pi / 180
		let φ2 = lat2 * .pi / 180
		let Δφ = (lat2 - lat1) * .pi / 180
		let Δλ = (lon2 - lon1) * .pi / 180

		let a = sin(Δφ / 2) * sin(Δφ / 2)
			+ cos(φ1) * cos(φ2) * sin(Δλ / 2) * sin(Δλ / 2)
		let c = 2 * atan2(sqrt(a), sqrt(1 - a))
		let km = earthRadiusKm * c
		return Int(km.rounded())
	}
}

