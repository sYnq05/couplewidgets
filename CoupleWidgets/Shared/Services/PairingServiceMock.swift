import Foundation

enum PairingServiceMock {
	static func buySimulate(existing: CacheSnapshot, nowUTC: Date, random: inout some RandomNumberGenerator) -> CacheSnapshot {
		var updated = existing
		updated.couple.role = .owner
		updated.couple.entitlement = .unlocked
		updated.couple.paired = true
		updated.couple.inviteCode = InviteCodeGenerator.generate(random: &random)
		return updated
	}

	static func regenerateInviteCode(existing: CacheSnapshot, random: inout some RandomNumberGenerator) -> CacheSnapshot {
		guard existing.couple.role == .owner, existing.couple.isUnlocked, existing.couple.paired else { return existing }
		var updated = existing
		updated.couple.inviteCode = InviteCodeGenerator.generate(random: &random)
		return updated
	}

	/// Redeem invite code. Owner must not redeem their own code. Partner can join with a code or switch to a new code (after owner regenerated).
	static func redeemCode(existing: CacheSnapshot, input: String) -> CacheSnapshot {
		let normalizedInput = InviteCodeGenerator.normalize(input)
		guard !normalizedInput.isEmpty else { return existing }

		let expected = InviteCodeGenerator.normalize(existing.couple.inviteCode ?? "")
		let codeMatches = !expected.isEmpty && normalizedInput == expected
		let partnerJoiningWithoutCode = expected.isEmpty

		// Owner must not accidentally "redeem" their own code (would flip to partner).
		if existing.couple.role == .owner, codeMatches {
			return existing
		}

		// Partner already paired but entering a different (new) code → switch to new code (e.g. after owner regenerated).
		if existing.couple.role == .partner, existing.couple.paired, !expected.isEmpty, normalizedInput != expected {
			var updated = existing
			updated.couple.inviteCode = normalizedInput
			return updated
		}

		guard codeMatches || partnerJoiningWithoutCode else { return existing }

		var updated = existing
		updated.couple.role = .partner
		updated.couple.entitlement = .unlocked
		updated.couple.paired = true
		if partnerJoiningWithoutCode {
			updated.couple.inviteCode = normalizedInput
		}
		return updated
	}

	static func unlink(existing: CacheSnapshot) -> CacheSnapshot {
		var updated = existing
		updated.couple.role = .none
		updated.couple.entitlement = .unlocked
		updated.couple.paired = false
		updated.couple.inviteCode = nil
		return updated
	}
}

