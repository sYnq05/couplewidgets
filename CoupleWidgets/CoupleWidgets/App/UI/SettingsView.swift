import SwiftUI

// MARK: - Release: Vor dem App-Store-Release in ReleaseConfig deine Daten eintragen

private enum ReleaseConfig {
	static let imprintName = "Dein Name / Firma"
	static let imprintStreet = "Straße und Hausnummer"
	static let imprintPlzOrt = "PLZ Ort"
	static let imprintEmail = "deine-email@beispiel.de"
	/// Optional: z.B. "Registergericht: Amtsgericht X, Registernummer HRB …, USt-IdNr. DE…"
	static let imprintOptional = ""
	static let supportEmail = "support@beispiel.de"
	/// App-ID aus App Store Connect (z.B. "1234567890"). Leer = „App bewerten“ ausblenden.
	static let appStoreAppId = ""
}

private func imprintContentDE() -> String {
	var optionalBlock = ""
	if !ReleaseConfig.imprintOptional.isEmpty {
		optionalBlock = "Optional (wenn zutreffend):\n\(ReleaseConfig.imprintOptional)\n\n"
	}
	return """
	Impressum

	Angaben gemäß § 5 TMG / § 18 MStV:

	\(ReleaseConfig.imprintName)
	\(ReleaseConfig.imprintStreet)
	\(ReleaseConfig.imprintPlzOrt)

	Kontakt:
	E-Mail: \(ReleaseConfig.imprintEmail)

	\(optionalBlock)Verantwortlich für den Inhalt nach § 55 Abs. 2 RStV:
	\(ReleaseConfig.imprintName)
	\(ReleaseConfig.imprintStreet), \(ReleaseConfig.imprintPlzOrt)

	Die Datenschutzerklärung findest du unter Einstellungen → Rechtliches in der App.
	"""
}

private func imprintContentEN() -> String {
	var optionalBlock = ""
	if !ReleaseConfig.imprintOptional.isEmpty {
		optionalBlock = "Optional (if applicable):\n\(ReleaseConfig.imprintOptional)\n\n"
	}
	return """
	Imprint

	Information according to § 5 TMG / § 18 MStV:

	\(ReleaseConfig.imprintName)
	\(ReleaseConfig.imprintStreet)
	\(ReleaseConfig.imprintPlzOrt)

	Contact:
	Email: \(ReleaseConfig.imprintEmail)

	\(optionalBlock)Responsible for content according to § 55 Abs. 2 RStV:
	\(ReleaseConfig.imprintName)
	\(ReleaseConfig.imprintStreet), \(ReleaseConfig.imprintPlzOrt)

	You can find the privacy policy under Settings → Legal in the app.
	"""
}

struct SettingsView: View {
	@EnvironmentObject private var model: AppModel
	@EnvironmentObject private var appleAuth: AppleAuthService
	@EnvironmentObject private var languageManager: LanguageManager

	@State private var myName: String = ""
	@State private var partnerName: String = ""
	@State private var showSavedAlert: Bool = false

	private var snapshot: CacheSnapshot { model.snapshot }
	private var hasChanges: Bool {
		myName != snapshot.me.name || partnerName != snapshot.partner.name
	}

	private var appVersion: String {
		(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "—"
	}
	private var buildNumber: String {
		(Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "—"
	}

	private var lang: String { languageManager.resolvedCode }

	var body: some View {
		List {
			Section {
				TextField(L10n.tr(.yourName, language: lang), text: $myName, prompt: Text(L10n.tr(.settingsNamePlaceholder, language: lang)))
					.textContentType(.name)
					.autocorrectionDisabled()
					.onChange(of: myName) { _, newValue in
						if newValue.count > 30 { myName = String(newValue.prefix(30)) }
					}
				TextField(L10n.tr(.partnerNameLabel, language: lang), text: $partnerName, prompt: Text(L10n.tr(.settingsPartnerPlaceholder, language: lang)))
					.textContentType(.name)
					.autocorrectionDisabled()
					.onChange(of: partnerName) { _, newValue in
						if newValue.count > 30 { partnerName = String(newValue.prefix(30)) }
					}
			} header: {
				Text(L10n.tr(.profileSection, language: lang))
			}

			if appleAuth.isSignedIn {
				Section {
					Button(role: .destructive) {
						appleAuth.signOut()
					} label: {
						Text(L10n.tr(.signOut, language: lang))
					}
				} header: {
					Text(L10n.tr(.accountSection, language: lang))
				}
			}

			Section {
				Picker(L10n.tr(.languageSection, language: lang), selection: $languageManager.appLanguage) {
					Text(L10n.tr(.languageDe, language: lang)).tag("de")
					Text(L10n.tr(.languageEn, language: lang)).tag("en")
					Text(L10n.tr(.languageSystem, language: lang)).tag("system")
				}
			} header: {
				Text(L10n.tr(.languageSection, language: lang))
			}

			Section {
				LabeledContent(L10n.tr(.version, language: lang), value: "\(appVersion) (\(buildNumber))")
				Text(L10n.tr(.appDescription, language: lang))
					.font(.footnote)
					.foregroundStyle(.secondary)
			} header: {
				Text(L10n.tr(.appSection, language: lang))
			}

			Section {
				Text(L10n.tr(.widgetsHowTo, language: lang))
					.font(.subheadline)
					.foregroundStyle(.secondary)
			} header: {
				Text(L10n.tr(.widgetsSection, language: lang))
			} footer: {
				Text(L10n.tr(.widgetsFooter, language: lang))
			}

			Section(L10n.tr(.legal, language: lang)) {
				NavigationLink(L10n.tr(.privacy, language: lang)) {
					LegalTextView(
						title: L10n.tr(.privacy, language: lang),
						content: L10n.tr(.appDescription, language: lang) + " " + (lang == "de" ? "Die App nutzt weder Analytics noch Drittanbieter-Tracking." : "The app does not use analytics or third-party tracking.")
					)
				}
				NavigationLink(L10n.tr(.imprint, language: lang)) {
					LegalTextView(
						title: L10n.tr(.imprint, language: lang),
						content: lang == "de" ? imprintContentDE() : imprintContentEN()
					)
				}
			}

			Section(L10n.tr(.support, language: lang)) {
				if let url = URL(string: "mailto:\(ReleaseConfig.supportEmail)") {
					Link(destination: url) {
						Label(L10n.tr(.contact, language: lang), systemImage: "envelope")
					}
				}
				if !ReleaseConfig.appStoreAppId.isEmpty,
				   let url = URL(string: "https://apps.apple.com/app/id\(ReleaseConfig.appStoreAppId)?action=write-review") {
					Link(destination: url) {
						Label(L10n.tr(.rateApp, language: lang), systemImage: "star")
					}
				}
			}
		}
		.listStyle(.insetGrouped)
		.navigationTitle(L10n.tr(.settingsTitle, language: lang))
		.navigationBarTitleDisplayMode(.inline)
		.toolbarBackground(.visible, for: .navigationBar)
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button(L10n.tr(.save, language: lang)) {
					model.updateMyName(myName)
					model.updatePartnerName(partnerName)
					showSavedAlert = true
				}
				.font(.system(size: 17, weight: .semibold))
				.foregroundStyle(Color.blue)
				.disabled(!hasChanges)
				.buttonStyle(.plain)
			}
		}
		.onAppear {
			myName = snapshot.me.name
			partnerName = snapshot.partner.name
		}
		.alert(L10n.tr(.savedAlertTitle, language: lang), isPresented: $showSavedAlert) {
			Button("OK", role: .cancel) {}
		} message: {
			Text(L10n.tr(.savedAlertMessage, language: lang))
		}
	}
}

private struct LegalTextView: View {
	let title: String
	let content: String

	var body: some View {
		ScrollView {
			Text(content)
				.font(.body)
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding()
		}
		.navigationTitle(title)
		.navigationBarTitleDisplayMode(.inline)
	}
}
