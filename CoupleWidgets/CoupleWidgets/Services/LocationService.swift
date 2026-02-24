import Foundation
import CoreLocation
import MapKit
import Combine
import WidgetKit

/// One-shot location for "use my location" in Cities; optional background updates (significant location changes) to keep widget and distance up to date.
final class LocationService: NSObject, ObservableObject {
	private let manager = CLLocationManager()
	private var continuation: CheckedContinuation<(lat: Double, lon: Double), Error>?
	private var isBackgroundMonitoringActive = false
	private let cache = CacheService()

	override init() {
		super.init()
		manager.delegate = self
		manager.desiredAccuracy = kCLLocationAccuracyBest
	}

	/// Request when-in-use authorization if not determined. Call before requestCurrentLocation().
	func requestAuthorizationIfNeeded() {
		switch manager.authorizationStatus {
		case .notDetermined:
			manager.requestWhenInUseAuthorization()
		default:
			break
		}
	}

	/// Request "always" so we can update location in background. Call after user has granted when-in-use (e.g. after first "Mein Standort").
	func requestAlwaysAuthorizationIfNeeded() {
		switch manager.authorizationStatus {
		case .authorizedWhenInUse:
			manager.requestAlwaysAuthorization()
		default:
			break
		}
	}

	/// Start background updates (significant location changes). Call when app has "always" authorization. Safe to call repeatedly.
	func startBackgroundMonitoringIfAuthorized() {
		guard manager.authorizationStatus == .authorizedAlways else { return }
		guard !isBackgroundMonitoringActive else { return }
		isBackgroundMonitoringActive = true
		manager.allowsBackgroundLocationUpdates = true
		manager.startMonitoringSignificantLocationChanges()
	}

	/// Fetch current location once. Throws if denied, restricted, or location unavailable.
	func requestCurrentLocation() async throws -> (lat: Double, lon: Double) {
		try await withCheckedThrowingContinuation { cont in
			DispatchQueue.main.async { [weak self] in
				guard let self else { return }
				switch self.manager.authorizationStatus {
				case .denied:
					cont.resume(throwing: LocationError.denied)
					return
				case .restricted:
					cont.resume(throwing: LocationError.denied)
					return
				case .notDetermined:
					self.continuation = cont
					self.manager.requestWhenInUseAuthorization()
					return
				case .authorizedAlways, .authorizedWhenInUse:
					break
				@unknown default:
					cont.resume(throwing: LocationError.denied)
					return
				}
				self.continuation = cont
				self.manager.requestLocation()
			}
		}
	}

	/// Reverse geocode coordinates to city and country (MapKit, iOS 26+). Returns (nil, nil) on failure.
	func reverseGeocode(lat: Double, lon: Double) async -> (city: String?, country: String?) {
		let location = CLLocation(latitude: lat, longitude: lon)
		guard let request = MKReverseGeocodingRequest(location: location) else {
			return (nil, nil)
		}
		return await withCheckedContinuation { cont in
			request.getMapItems { mapItems, _ in
				guard let item = mapItems?.first else {
					cont.resume(returning: (nil, nil))
					return
				}
				let city: String?
				let country: String?
				if let addr = item.addressRepresentations {
					city = addr.cityName
					country = addr.regionName
				} else {
					city = nil
					country = nil
				}
				cont.resume(returning: (city, country))
			}
		}
	}
}

extension LocationService: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let loc = locations.last else { return }
		let lat = loc.coordinate.latitude
		let lon = loc.coordinate.longitude
		if let cont = continuation {
			continuation = nil
			cont.resume(returning: (lat, lon))
			return
		}
		if isBackgroundMonitoringActive {
			DispatchQueue.main.async { [weak self] in
				guard let self else { return }
				self.applyLocationToCache(lat: lat, lon: lon)
				WidgetCenter.shared.reloadAllTimelines()
			}
		}
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		continuation?.resume(throwing: error)
		continuation = nil
	}

	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		if continuation != nil {
			switch manager.authorizationStatus {
			case .denied, .restricted:
				continuation?.resume(throwing: LocationError.denied)
				continuation = nil
			case .authorizedAlways, .authorizedWhenInUse:
				manager.requestLocation()
			default:
				break
			}
		}
		if manager.authorizationStatus == .authorizedAlways {
			startBackgroundMonitoringIfAuthorized()
		}
	}

	/// Writes lat/lon into shared cache for "me" and updates city/country from nearest preset so the displayed location stays in sync. Call from background-safe context.
	private func applyLocationToCache(lat: Double, lon: Double) {
		var snap = cache.readSnapshot()
		snap.me.lat = lat
		snap.me.lon = lon
		if let nearest = CityPreset.nearest(toLat: lat, lon: lon) {
			snap.me.cityLabel = nearest.name
			snap.me.country = nearest.country
		}
		cache.writeSnapshot(snap, nowUTC: Date())
		NotificationCenter.default.post(name: .locationCacheDidUpdate, object: nil)
	}
}

extension Notification.Name {
	static let locationCacheDidUpdate = Notification.Name("locationCacheDidUpdate")
}

enum LocationError: LocalizedError {
	case denied

	var errorDescription: String? {
		switch self {
		case .denied: return "Location access denied or restricted."
		}
	}
}
