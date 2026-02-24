import XCTest
@testable import CoupleWidgets

final class StreakEngineTests: XCTestCase {
	func testStreakBoundary_23h59m_noIncrement() {
		let last = Date(timeIntervalSince1970: 0)
		let existing = Streak(streakCount: 5, longestStreak: 7, lastNoteAtUTC: last)
		let now = last.addingTimeInterval((23 * 60 * 60) + (59 * 60))

		let updated = StreakEngine.applyNoteUpdate(existing: existing, nowUTC: now)
		XCTAssertEqual(updated.streakCount, 5)
		XCTAssertEqual(updated.longestStreak, 7)
		XCTAssertEqual(updated.lastNoteAtUTC, now)
	}

	func testStreakBoundary_24h_increment() {
		let last = Date(timeIntervalSince1970: 0)
		let existing = Streak(streakCount: 5, longestStreak: 7, lastNoteAtUTC: last)
		let now = last.addingTimeInterval(24 * 60 * 60)

		let updated = StreakEngine.applyNoteUpdate(existing: existing, nowUTC: now)
		XCTAssertEqual(updated.streakCount, 6)
		XCTAssertEqual(updated.longestStreak, 7)
		XCTAssertEqual(updated.lastNoteAtUTC, now)
	}

	func testStreakBoundary_47h59m_increment() {
		let last = Date(timeIntervalSince1970: 0)
		let existing = Streak(streakCount: 5, longestStreak: 7, lastNoteAtUTC: last)
		let now = last.addingTimeInterval((47 * 60 * 60) + (59 * 60))

		let updated = StreakEngine.applyNoteUpdate(existing: existing, nowUTC: now)
		XCTAssertEqual(updated.streakCount, 6)
		XCTAssertEqual(updated.longestStreak, 7)
		XCTAssertEqual(updated.lastNoteAtUTC, now)
	}

	func testStreakBoundary_48h_reset() {
		let last = Date(timeIntervalSince1970: 0)
		let existing = Streak(streakCount: 5, longestStreak: 7, lastNoteAtUTC: last)
		let now = last.addingTimeInterval(48 * 60 * 60)

		let updated = StreakEngine.applyNoteUpdate(existing: existing, nowUTC: now)
		XCTAssertEqual(updated.streakCount, 1)
		XCTAssertEqual(updated.longestStreak, 7)
		XCTAssertEqual(updated.lastNoteAtUTC, now)
	}
}

final class CountdownFormatterTests: XCTestCase {
	func testCountdownBoundary_24h_isDays() {
		let now = Date(timeIntervalSince1970: 0)
		let event = now.addingTimeInterval(24 * 60 * 60)
		XCTAssertEqual(CountdownFormatter.displayString(eventAtUTC: event, nowUTC: now), "1 days")
	}

	func testCountdownBoundary_23h01m_isHoursCeil() {
		let now = Date(timeIntervalSince1970: 0)
		let event = now.addingTimeInterval((23 * 60 * 60) + (1 * 60))
		XCTAssertEqual(CountdownFormatter.displayString(eventAtUTC: event, nowUTC: now), "24 h")
	}

	func testCountdownBoundary_59m01s_isMinutesCeil() {
		let now = Date(timeIntervalSince1970: 0)
		let event = now.addingTimeInterval((59 * 60) + 1)
		XCTAssertEqual(CountdownFormatter.displayString(eventAtUTC: event, nowUTC: now), "60 min")
	}

	func testCountdownPast_isZeroMinutes() {
		let now = Date(timeIntervalSince1970: 1000)
		let event = now.addingTimeInterval(-5)
		XCTAssertEqual(CountdownFormatter.displayString(eventAtUTC: event, nowUTC: now), "0 min")
	}
}

final class DistanceCalculatorTests: XCTestCase {
	func testDistanceSanity_BerlinToNYC_isLarge() {
		let berlin = CityPreset.all.first(where: { $0.name == "Berlin" })!
		let nyc = CityPreset.all.first(where: { $0.name == "New York City" })!
		let km = DistanceCalculator.haversineKm(lat1: berlin.lat, lon1: berlin.lon, lat2: nyc.lat, lon2: nyc.lon)
		XCTAssertGreaterThan(km, 1000)
	}
}

