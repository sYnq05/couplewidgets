import Foundation

enum AppGroupKeys {
	static let suiteName = "group.com.yourcompany.couplewidgets"

	static let hasInitialized = "cg.hasInitialized"

	static let paired = "cg.paired"
	static let role = "cg.role"
	static let entitlement = "cg.entitlement"
	static let inviteCode = "cg.inviteCode"

	static let myName = "cg.myName"
	static let myInitials = "cg.myInitials"
	static let myCityLabel = "cg.myCityLabel"
	static let myCountry = "cg.myCountry"
	static let myLat = "cg.myLat"
	static let myLon = "cg.myLon"

	static let partnerName = "cg.partnerName"
	static let partnerInitials = "cg.partnerInitials"
	static let partnerCityLabel = "cg.partnerCityLabel"
	static let partnerCountry = "cg.partnerCountry"
	static let partnerLat = "cg.partnerLat"
	static let partnerLon = "cg.partnerLon"

	static let distanceKm = "cg.distanceKm"
	static let distanceLabel = "cg.distanceLabel"

	static let eventAtUTC = "cg.eventAtUTC"
	static let countdownLabel = "cg.countdownLabel"
	static let countdownDisplay = "cg.countdownDisplay"

	static let noteText = "cg.noteText"
	static let noteAuthorInitials = "cg.noteAuthorInitials"
	static let noteAuthorIsMe = "cg.noteAuthorIsMe"
	static let noteUpdatedAt = "cg.noteUpdatedAt"

	static let streakCount = "cg.streakCount"
	static let longestStreak = "cg.longestStreak"
	static let lastNoteAt = "cg.lastNoteAt"

	static let lastCacheWriteAt = "cg.lastCacheWriteAt"

	/// Invite code whose CloudKit record should be deleted (e.g. after regenerate). Cleared after successful delete or on retry.
	static let pendingDeleteInviteCode = "cg.pendingDeleteInviteCode"
}

