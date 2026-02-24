import Foundation

enum CoupleRole: String, CaseIterable, Equatable {
	case none
	case owner
	case partner
}

enum CoupleEntitlement: String, CaseIterable, Equatable {
	case locked
	case unlocked
}

struct CoupleState: Equatable {
	var role: CoupleRole
	var entitlement: CoupleEntitlement
	var paired: Bool
	var inviteCode: String?

	var isUnlocked: Bool { entitlement == .unlocked }
}

