import Combine
import Foundation
import SwiftUI

/// Stores and publishes the app language. "system" = use device language; "de" / "en" = override.
final class LanguageManager: ObservableObject {
	static let storageKey = "appLanguage"

	@Published var appLanguage: String {
		didSet { UserDefaults.standard.set(appLanguage, forKey: Self.storageKey) }
	}

	init() {
		self.appLanguage = UserDefaults.standard.string(forKey: Self.storageKey) ?? "system"
	}

	/// Resolved language code for lookups: "de", "en", or from locale.
	var resolvedCode: String {
		if appLanguage == "system" {
			let code = Locale.preferredLanguages.first.map { String($0.prefix(2)) } ?? "en"
			return code == "de" ? "de" : "en"
		}
		return appLanguage
	}
}
