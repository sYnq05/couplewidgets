import Foundation

struct Note: Equatable {
	var text: String
	var authorInitials: String
	/// When true = written by "Me", false = by "Partner". Nil = legacy note (infer from initials).
	var authorIsMe: Bool?
	var updatedAtUTC: Date?
}

extension Note {
	/// Initials to show for the note author, using current me/partner initials so name changes are reflected.
	func displayAuthorInitials(meInitials: String, partnerInitials: String) -> String {
		if authorIsMe == true { return meInitials }
		if authorIsMe == false { return partnerInitials }
		if authorInitials == meInitials { return meInitials }
		if authorInitials == partnerInitials { return partnerInitials }
		return authorInitials
	}
}

