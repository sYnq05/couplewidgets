import SwiftUI
import AuthenticationServices

struct PairingView: View {
	@EnvironmentObject private var model: AppModel
	@EnvironmentObject private var appleAuth: AppleAuthService
	@EnvironmentObject private var languageManager: LanguageManager

	@State private var redeemInput: String = ""
	@State private var showRedeemSuccess: Bool = false
	@State private var showEmptyCodeAlert: Bool = false
	@State private var showCodeAlreadyUsedAlert: Bool = false
	@State private var showSignInRequiredAlert: Bool = false
	@State private var redeemInProgress: Bool = false
	@State private var showUnlinkConfirm: Bool = false
	@State private var showSyncFailedAlert: Bool = false
	private var lang: String { languageManager.resolvedCode }

	private func roleDisplayName(_ role: CoupleRole) -> String {
		switch role {
		case .owner: return L10n.tr(.pairingRoleOwner, language: lang)
		case .partner: return L10n.tr(.pairingRolePartner, language: lang)
		case .none: return L10n.tr(.pairingRoleNone, language: lang)
		}
	}

	private var snapshot: CacheSnapshot { model.snapshot }

	var body: some View {
		Form {
			Section {
				if appleAuth.isSignedIn {
					LabeledContent(L10n.tr(.pairingAppleAccount, language: lang), value: L10n.tr(.pairingSignedIn, language: lang))
						.foregroundColor(.primary)
					Button(role: .destructive) {
						appleAuth.signOut()
					} label: {
						Text(L10n.tr(.signOut, language: lang))
					}
				} else {
					SignInWithAppleButton(.signIn) { request in
						request.requestedScopes = []
					} onCompletion: { result in
						switch result {
						case .success(let authorization):
							guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
							Task { @MainActor in
								appleAuth.applyCredential(userIdentifier: credential.user)
							}
						case .failure:
							break
						}
					}
					.signInWithAppleButtonStyle(.black)
					.frame(height: 50)
				}
			} header: {
				Text(L10n.tr(.pairingSignInSection, language: lang))
					.font(.subheadline.weight(.semibold))
					.foregroundColor(.primary)
			} footer: {
				if !appleAuth.isSignedIn {
					Text(L10n.tr(.pairingSignInRequired, language: lang))
						.font(.footnote)
						.foregroundColor(Color(.secondaryLabel))
				}
			}

			Section {
				LabeledContent(L10n.tr(.yourName, language: lang)) {
					Text(snapshot.me.name.isEmpty ? "—" : snapshot.me.name)
						.foregroundColor(.primary)
				}
				LabeledContent(L10n.tr(.partnerNameLabel, language: lang)) {
					Text(snapshot.partner.name.isEmpty ? "—" : snapshot.partner.name)
						.foregroundColor(.primary)
				}
				LabeledContent(L10n.tr(.pairingPaired, language: lang)) { Text(snapshot.couple.paired ? L10n.tr(.pairingYes, language: lang) : L10n.tr(.pairingNo, language: lang)).foregroundColor(.primary) }
				LabeledContent(L10n.tr(.pairingRole, language: lang)) { Text(roleDisplayName(snapshot.couple.role)).foregroundColor(.primary) }
			} header: {
				Text(L10n.tr(.pairingStatusSection, language: lang)).font(.subheadline.weight(.semibold)).foregroundColor(.primary)
			} footer: {
				Text(L10n.tr(.editNamesInSettings, language: lang))
					.font(.footnote)
					.foregroundColor(Color(.secondaryLabel))
			}

			Section {
				if snapshot.couple.role == .owner, snapshot.couple.paired {
					LabeledContent(L10n.tr(.pairingInviteCode, language: lang)) {
						HStack(spacing: 8) {
							Text(snapshot.couple.inviteCode ?? "—")
								.font(.system(.body, design: .monospaced))
								.foregroundColor(.primary)
							if let code = snapshot.couple.inviteCode, !code.isEmpty {
								Button {
									UIPasteboard.general.string = code
								} label: {
									Image(systemName: "doc.on.doc")
										.font(.body)
										.foregroundColor(.secondary)
										.frame(minWidth: 44, minHeight: 44)
										.contentShape(Rectangle())
								}
								.buttonStyle(.borderless)
							}
						}
					}
					Button(L10n.tr(.pairingRegenerateCode, language: lang)) {
						model.regenerateInviteCode()
						Task {
							_ = await model.syncPush()
						}
					}
					.disabled(!appleAuth.isSignedIn)
				}

				Button(role: .destructive) {
					showUnlinkConfirm = true
				} label: {
					Text(L10n.tr(.pairingUnlink, language: lang))
				}
			} header: {
				Text(L10n.tr(.pairingActionsSection, language: lang)).font(.subheadline.weight(.semibold)).foregroundColor(.primary)
			}

			Section {
				TextField(L10n.tr(.pairingRedeemButton, language: lang), text: $redeemInput, prompt: Text(L10n.tr(.pairingRedeemPlaceholder, language: lang)).foregroundColor(Color(.secondaryLabel)))
					.textInputAutocapitalization(.characters)
					.autocorrectionDisabled()
					.font(.system(.body, design: .monospaced))
					.foregroundColor(.primary)
				Button(L10n.tr(.pairingRedeemButton, language: lang)) {
					let trimmed = redeemInput.trimmingCharacters(in: .whitespacesAndNewlines)
					if trimmed.isEmpty {
						showEmptyCodeAlert = true
						return
					}
					if !appleAuth.isSignedIn {
						showSignInRequiredAlert = true
						return
					}
					redeemInProgress = true
					model.redeemInviteCode(trimmed)
					redeemInput = ""
					Task {
						let result = await model.syncPush()
						switch result {
						case .partnerSlotAlreadyTaken:
							await MainActor.run {
								redeemInProgress = false
								model.unlink()
								showCodeAlreadyUsedAlert = true
							}
						case .saveFailed:
							await MainActor.run {
								redeemInProgress = false
								showSyncFailedAlert = true
							}
						case .success:
							if model.snapshot.couple.paired, model.snapshot.couple.role == .partner {
								await model.syncPull()
							}
							await MainActor.run {
								redeemInProgress = false
								if model.snapshot.couple.paired, model.snapshot.couple.role == .partner {
									showRedeemSuccess = true
								}
							}
						}
					}
				}
				.buttonStyle(.borderedProminent)
				.tint(.accentColor)
				.frame(maxWidth: .infinity)
				.disabled(redeemInProgress || !appleAuth.isSignedIn)
			} header: {
				Text(L10n.tr(.pairingRedeemSection, language: lang)).font(.subheadline.weight(.semibold)).foregroundColor(.primary)
			} footer: {
				Text(L10n.tr(.pairingRedeemFooter, language: lang))
					.font(.footnote)
					.foregroundColor(Color(.secondaryLabel))
			}
		}
		.navigationTitle(L10n.tr(.pairingNavTitle, language: lang))
		.navigationBarTitleDisplayMode(.inline)
		.toolbarBackground(.visible, for: .navigationBar)
		.onAppear {
			model.refreshFromCache()
			if snapshot.couple.role == .owner, snapshot.couple.paired, appleAuth.isSignedIn {
				Task { _ = await model.syncPush() }
			}
		}
		.alert(L10n.tr(.pairingRedeemSuccessTitle, language: lang), isPresented: $showRedeemSuccess) {
			Button("OK", role: .cancel) {}
		} message: {
			Text(L10n.tr(.pairingRedeemSuccessMessage, language: lang))
		}
		.alert(L10n.tr(.pairingRedeemSection, language: lang), isPresented: $showEmptyCodeAlert) {
			Button("OK", role: .cancel) {}
		} message: {
			Text(L10n.tr(.pairingRedeemEmptyCode, language: lang))
		}
		.alert(L10n.tr(.pairingCodeAlreadyUsedTitle, language: lang), isPresented: $showCodeAlreadyUsedAlert) {
			Button("OK", role: .cancel) {}
		} message: {
			Text(L10n.tr(.pairingCodeAlreadyUsedMessage, language: lang))
		}
		.alert(L10n.tr(.signInWithApple, language: lang), isPresented: $showSignInRequiredAlert) {
			Button("OK", role: .cancel) {}
		} message: {
			Text(L10n.tr(.pairingSignInRequired, language: lang))
		}
		.alert(L10n.tr(.pairingUnlinkConfirmTitle, language: lang), isPresented: $showUnlinkConfirm) {
			Button(L10n.tr(.cancel, language: lang), role: .cancel) {}
			Button(L10n.tr(.pairingUnlink, language: lang), role: .destructive) {
				model.unlink()
			}
		} message: {
			Text(L10n.tr(.pairingUnlinkConfirmMessage, language: lang))
		}
		.alert(L10n.tr(.pairingSyncFailedTitle, language: lang), isPresented: $showSyncFailedAlert) {
			Button("OK", role: .cancel) {}
		} message: {
			Text(L10n.tr(.pairingSyncFailedMessage, language: lang))
		}
	}
}

