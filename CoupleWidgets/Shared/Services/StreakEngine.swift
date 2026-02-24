import Foundation

enum StreakEngine {
	static func applyNoteUpdate(existing: Streak, nowUTC: Date) -> Streak {
		let day: TimeInterval = 24 * 60 * 60
		let twoDays: TimeInterval = 48 * 60 * 60

		guard let last = existing.lastNoteAtUTC else {
			return Streak(
				streakCount: 1,
				longestStreak: max(1, existing.longestStreak),
				lastNoteAtUTC: nowUTC
			)
		}

		let delta = nowUTC.timeIntervalSince(last)

		var newStreak = existing.streakCount
		if delta < day {
			// no increment
		} else if delta < twoDays {
			newStreak += 1
		} else {
			newStreak = 1
		}

		return Streak(
			streakCount: newStreak,
			longestStreak: max(existing.longestStreak, newStreak),
			lastNoteAtUTC: nowUTC
		)
	}
}

