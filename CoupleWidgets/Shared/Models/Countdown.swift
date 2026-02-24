import Foundation

struct Countdown: Equatable {
	var eventAtUTC: Date?
	/// Custom name for the countdown (e.g. "Wiedersehen"). Empty/nil → display as "Countdown".
	var label: String?
}

extension Countdown {
	/// Max length for label so it fits in all widgets (e.g. circular). Enforced at input and when saving.
	static let labelMaxLength = 12

	/// Display title: custom label if non-empty, else "Countdown".
	func displayTitle() -> String {
		let trimmed = (label ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
		return trimmed.isEmpty ? "Countdown" : trimmed
	}
}

