import Foundation

enum TimelineHelpers {
	static func datesEvery30MinutesFor12Hours(from start: Date) -> [Date] {
		let interval: TimeInterval = 30 * 60
		let count = Int((12 * 60 * 60) / interval)
		return (0...count).map { start.addingTimeInterval(TimeInterval($0) * interval) }
	}
}

