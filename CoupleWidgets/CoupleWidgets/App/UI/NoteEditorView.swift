import SwiftUI

struct NoteEditorView: View {
	@EnvironmentObject private var model: AppModel
	@EnvironmentObject private var languageManager: LanguageManager

	@State private var text: String = ""
	@State private var author: Author = .me
	@State private var showAuthor: Bool = true
	@State private var showStreak: Bool = true
	@State private var notifyPartner: Bool = true
	@State private var showSavedAlert: Bool = false
	@State private var showEmptyNoteAlert: Bool = false
	@State private var showResetAlert: Bool = false

	private var snapshot: CacheSnapshot { model.snapshot }
	private var lang: String { languageManager.resolvedCode }

	private var hasChanges: Bool {
		let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
		let sameText = trimmed == (snapshot.note.text.trimmingCharacters(in: .whitespacesAndNewlines))
		let displayedInitials = snapshot.note.displayAuthorInitials(meInitials: snapshot.me.initials, partnerInitials: snapshot.partner.initials)
		let sameAuthor = selectedAuthorInitials() == displayedInitials
		return !sameText || !sameAuthor
	}

	enum Author: String, CaseIterable, Identifiable {
		case me
		case partner
		var id: String { rawValue }
	}

	private var lastUpdatedFormatted: String {
		guard let date = snapshot.note.updatedAtUTC else { return "—" }
		let f = DateFormatter()
		f.dateFormat = "MMM d"
		return f.string(from: date)
	}

	private var previewTitle: String {
		showAuthor ? String(format: L10n.tr(.noteFromInitials, language: lang), selectedAuthorInitials()) : L10n.tr(.note, language: lang)
	}

	var body: some View {
		ZStack {
			Color(UIColor.systemGroupedBackground)
				.ignoresSafeArea()
			ScrollView {
				VStack(spacing: 20) {
					IOSSection(title: L10n.tr(.noteConfiguration, language: lang)) {
						IOSTextAreaRow(
							text: $text,
							placeholder: L10n.tr(.notePlaceholder, language: lang),
							maxLength: 100
						)
						HStack {
							Text(L10n.tr(.noteAuthor, language: lang))
								.foregroundStyle(.primary)
							Spacer()
							Picker("", selection: $author) {
								Text("\(snapshot.me.initials) (\(L10n.tr(.noteMe, language: lang)))").tag(Author.me)
								Text("\(snapshot.partner.initials) (\(L10n.tr(.notePartnerLabel, language: lang)))").tag(Author.partner)
							}
							.labelsHidden()
							.pickerStyle(.menu)
						}
						.frame(height: 44)
					}

					IOSSection(title: L10n.tr(.citiesDisplayOptions, language: lang)) {
						IOSToggleRow(label: L10n.tr(.noteShowAuthorInitials, language: lang), isOn: $showAuthor)
						IOSToggleRow(label: L10n.tr(.noteShowStreak, language: lang), isOn: $showStreak)
					}

					IOSSection(title: L10n.tr(.citiesNotifications, language: lang)) {
						IOSToggleRow(label: L10n.tr(.noteNotifyPartner, language: lang), isOn: $notifyPartner)
					}

					IOSSection(title: L10n.tr(.citiesStatistics, language: lang)) {
						VStack(spacing: 0) {
							IOSStatCard(
								icon: "flame",
								iconColor: Color.orange.opacity(0.15),
								label: L10n.tr(.noteCurrentStreak, language: lang),
								value: "\(snapshot.streak.streakCount)",
								valueColor: .orange
							)
							IOSStatCard(
								icon: "chart.line.uptrend.xyaxis",
								iconColor: Color.purple.opacity(0.15),
								label: L10n.tr(.noteLongestStreak, language: lang),
								value: "\(snapshot.streak.longestStreak)",
								valueColor: .purple
							)
							IOSStatCard(
								icon: "calendar",
								iconColor: Color.blue.opacity(0.15),
								label: L10n.tr(.noteLastUpdated, language: lang),
								value: lastUpdatedFormatted,
								valueColor: .primary
							)
						}
					}

					// WIDGET PREVIEW
					IOSWidgetPreview {
						NoteScreenPreviewView(
							title: previewTitle,
							note: text.isEmpty ? "" : text,
							authorInitials: showAuthor ? selectedAuthorInitials() : nil,
							showStreak: showStreak,
							currentStreak: snapshot.streak.streakCount,
							lastUpdated: snapshot.note.updatedAtUTC
						)
					}

					IOSSection(title: L10n.tr(.reset, language: lang)) {
						Button(role: .destructive) {
							showResetAlert = true
						} label: {
							Text(L10n.tr(.reset, language: lang) + " – " + L10n.tr(.note, language: lang))
								.frame(maxWidth: .infinity, alignment: .leading)
						}
					}
				}
				.padding(.horizontal, 20)
				.padding(.vertical, 16)
			}
		}
		.navigationTitle(L10n.tr(.note, language: lang))
		.navigationBarTitleDisplayMode(.inline)
		.toolbarBackground(.visible, for: .navigationBar)
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button(L10n.tr(.save, language: lang)) {
					handleSave()
				}
				.font(.system(size: 17, weight: .semibold))
				.foregroundStyle(Color.blue)
				.disabled(!hasChanges)
				.buttonStyle(.plain)
			}
			ToolbarItemGroup(placement: .keyboard) {
				Spacer()
				Button("Fertig") {
					UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
				}
				.fontWeight(.semibold)
			}
		}
		.alert(L10n.tr(.savedAlertTitle, language: lang), isPresented: $showSavedAlert) {
			Button("OK", role: .cancel) {}
		} message: {
			Text(L10n.tr(.savedAlertMessage, language: lang))
		}
		.alert(L10n.tr(.note, language: lang), isPresented: $showEmptyNoteAlert) {
			Button("OK", role: .cancel) {}
		} message: {
			Text(L10n.tr(.tapToWriteExplanation, language: lang))
		}
		.alert(L10n.tr(.widgetResetTitle, language: lang), isPresented: $showResetAlert) {
			Button(L10n.tr(.cancel, language: lang), role: .cancel) {}
			Button(L10n.tr(.reset, language: lang), role: .destructive) {
				model.resetNote()
			}
		} message: {
			Text(L10n.tr(.widgetResetMessage, language: lang))
		}
		.onAppear {
			text = snapshot.note.text
			author = (snapshot.note.authorInitials == snapshot.partner.initials) ? .partner : .me
		}
	}

	private func selectedAuthorInitials() -> String {
		switch author {
		case .me: snapshot.me.initials
		case .partner: snapshot.partner.initials
		}
	}

	private func handleSave() {
		let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
		if trimmed.isEmpty {
			showEmptyNoteAlert = true
			return
		}
		model.saveNote(text: text, authorInitials: selectedAuthorInitials(), authorIsMe: author == .me)
		showSavedAlert = true
	}
}
