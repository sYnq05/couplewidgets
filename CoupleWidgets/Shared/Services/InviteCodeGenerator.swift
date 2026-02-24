import Foundation

enum InviteCodeGenerator {
	/// Base32 alphabet excluding 0/O/1/I.
	private static let alphabet: [Character] = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")

	static func generate(random: inout some RandomNumberGenerator) -> String {
		func nextChar() -> Character {
			let idx = Int.random(in: 0..<alphabet.count, using: &random)
			return alphabet[idx]
		}

		let part1 = String((0..<4).map { _ in nextChar() })
		let part2 = String((0..<4).map { _ in nextChar() })
		return "\(part1)-\(part2)"
	}

	static func normalize(_ code: String) -> String {
		code
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.uppercased()
	}
}

