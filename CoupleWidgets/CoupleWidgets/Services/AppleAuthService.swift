import Foundation
import AuthenticationServices
import Security
import UIKit

/// Sign in with Apple: stores the stable user identifier in Keychain and exposes it for CloudKit pairing (one-to-one).
@MainActor
final class AppleAuthService: NSObject, ObservableObject {
	static let keychainService = "CoupleWidgets.AppleAuth"
	static let keychainAccount = "appleUserIdentifier"

	@Published private(set) var currentUserIdentifier: String?
	@Published private(set) var isSigningIn = false

	var isSignedIn: Bool { currentUserIdentifier != nil }

	override init() {
		super.init()
		currentUserIdentifier = Self.readStoredIdentifier()
	}

	/// Call from the view that presents Sign in with Apple (e.g. PairingView). Presents the Apple ID sheet.
	func signIn() {
		guard !isSigningIn else { return }
		isSigningIn = true
		let provider = ASAuthorizationAppleIDProvider()
		let request = provider.createRequest()
		request.requestedScopes = [] // We only need userIdentifier for pairing; no email/name required
		let controller = ASAuthorizationController(authorizationRequests: [request])
		controller.delegate = self
		controller.presentationContextProvider = self
		controller.performRequests()
	}

	/// Call after SignInWithAppleButton onCompletion with ASAuthorizationAppleIDCredential.user.
	func applyCredential(userIdentifier: String) {
		Self.saveIdentifier(userIdentifier)
		currentUserIdentifier = userIdentifier
	}

	func signOut() {
		Self.deleteStoredIdentifier()
		currentUserIdentifier = nil
	}

	// MARK: - Keychain

	private static func readStoredIdentifier() -> String? {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: keychainService,
			kSecAttrAccount as String: keychainAccount,
			kSecReturnData as String: true,
			kSecMatchLimit as String: kSecMatchLimitOne
		]
		var result: AnyObject?
		let status = SecItemCopyMatching(query as CFDictionary, &result)
		guard status == errSecSuccess, let data = result as? Data, let string = String(data: data, encoding: .utf8) else { return nil }
		return string
	}

	private static func saveIdentifier(_ identifier: String) {
		deleteStoredIdentifier()
		guard let data = identifier.data(using: .utf8) else { return }
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: keychainService,
			kSecAttrAccount as String: keychainAccount,
			kSecValueData as String: data
		]
		SecItemAdd(query as CFDictionary, nil)
	}

	private static func deleteStoredIdentifier() {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: keychainService,
			kSecAttrAccount as String: keychainAccount
		]
		SecItemDelete(query as CFDictionary)
	}
}

extension AppleAuthService: ASAuthorizationControllerDelegate {
	nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
		guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
			Task { @MainActor in isSigningIn = false }
			return
		}
		let id = credential.user
		Self.saveIdentifier(id)
		Task { @MainActor in
			currentUserIdentifier = id
			isSigningIn = false
		}
	}

	nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
		Task { @MainActor in isSigningIn = false }
	}
}

extension AppleAuthService: ASAuthorizationControllerPresentationContextProviding {
	nonisolated func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
		return scene?.windows.first(where: { $0.isKeyWindow }) ?? scene?.windows.first ?? UIWindow()
	}
}
