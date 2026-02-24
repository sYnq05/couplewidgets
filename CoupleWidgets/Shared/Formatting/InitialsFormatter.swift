import Foundation

enum InitialsFormatter {
	static func initials(from name: String, fallback: String) -> String {
		let cleaned = name
			.trimmingCharacters(in: .whitespacesAndNewlines)

		let parts = cleaned
			.split(whereSeparator: { $0.isWhitespace })
			.map(String.init)

		var letters: [Character] = []
		for part in parts {
			guard let first = part.first else { continue }
			letters.append(first)
			if letters.count >= 3 { break }
		}

		if letters.isEmpty, let first = cleaned.first {
			letters = [first]
		}

		let raw = String(letters).uppercased()
		let filtered = raw.filter { $0.isLetter || $0.isNumber }
		let trimmed = String(filtered.prefix(3))
		return trimmed.isEmpty ? fallback : trimmed
	}

	static func sanitize(_ initials: String, fallback: String) -> String {
		let filtered = initials
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.uppercased()
			.filter { $0.isLetter || $0.isNumber }
		let trimmed = String(filtered.prefix(3))
		return trimmed.isEmpty ? fallback : trimmed
	}
}

