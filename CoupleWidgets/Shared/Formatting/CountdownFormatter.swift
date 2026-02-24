import Foundation

enum CountdownFormatter {
	/// Uses calendar-day difference for "X days" so widget and editor (which use Calendar.current) stay in sync across time zones.
	static func displayString(eventAtUTC: Date?, nowUTC: Date) -> String {
		guard let eventAtUTC else { return "Set date" }
		let seconds = eventAtUTC.timeIntervalSince(nowUTC)

		if seconds <= 0 {
			return "0 min"
		}

		let calendar = Calendar.current
		let startOfToday = calendar.startOfDay(for: nowUTC)
		let startOfEvent = calendar.startOfDay(for: eventAtUTC)
		let days = max(0, calendar.dateComponents([.day], from: startOfToday, to: startOfEvent).day ?? 0)

		if days >= 1 {
			return "\(days) days"
		}

		let hour: Double = 60 * 60
		let minute: Double = 60
		if seconds >= hour {
			let hours = Int(ceil(seconds / hour))
			return "\(hours) h"
		}
		let minutes = max(1, Int(ceil(seconds / minute)))
		return "\(minutes) min"
	}
}

