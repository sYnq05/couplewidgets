import SwiftUI

struct CountdownEditorView: View {
	@EnvironmentObject private var model: AppModel
	@EnvironmentObject private var languageManager: LanguageManager

	@State private var isEnabled: Bool = false
	@State private var selectedDate: Date = Date().addingTimeInterval(60 * 60)
	@State private var labelText: String = ""
	@State private var dailyReminder: Bool = false
	@State private var showSavedAlert: Bool = false
	@State private var showResetAlert: Bool = false

	private var snapshot: CacheSnapshot { model.snapshot }
	private var lang: String { languageManager.resolvedCode }

	private var savedLabel: String {
		(snapshot.countdown.label ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
	}

	private var hasChanges: Bool {
		let savedEvent = snapshot.countdown.eventAtUTC
		let labelChanged = labelText.trimmingCharacters(in: .whitespacesAndNewlines) != savedLabel
		if isEnabled {
			guard let saved = savedEvent else { return true }
			return abs(selectedDate.timeIntervalSince(saved)) > 1 || labelChanged
		} else {
			return savedEvent != nil || labelChanged
		}
	}

	private var daysRemaining: Int {
		Calendar.current.dateComponents([.day], from: Date(), to: selectedDate).day ?? 0
	}

	private var hoursRemaining: Int {
		let comps = Calendar.current.dateComponents([.hour, .minute], from: Date(), to: selectedDate)
		return (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
	}

	private var eventDateShort: String {
		let f = DateFormatter()
		f.dateFormat = "MMM d"
		return f.string(from: selectedDate)
	}

	private var displayTitle: String {
		let t = labelText.trimmingCharacters(in: .whitespacesAndNewlines)
		return t.isEmpty ? L10n.tr(.countdown, language: lang) : t
	}

	var body: some View {
		ZStack {
			Color(UIColor.systemGroupedBackground)
				.ignoresSafeArea()
			ScrollView {
				VStack(spacing: 20) {
					IOSSection(title: L10n.tr(.countdownStatus, language: lang)) {
						IOSToggleRow(label: L10n.tr(.countdownEnable, language: lang), isOn: $isEnabled)
					}

					if isEnabled {
						IOSSection(title: L10n.tr(.countdownConfiguration, language: lang)) {
							IOSInputRow(
								label: L10n.tr(.countdownTitleLabel, language: lang),
								text: $labelText,
								placeholder: L10n.tr(.countdownTitlePlaceholder, language: lang)
							)
							.onChange(of: labelText) { _, newValue in
								if newValue.count > Countdown.labelMaxLength {
									labelText = String(newValue.prefix(Countdown.labelMaxLength))
								}
							}
						}

						IOSSection(title: L10n.tr(.countdownDateAndTime, language: lang)) {
							IOSDatePickerRow(
								label: L10n.tr(.countdownDateLabel, language: lang),
								selection: $selectedDate,
								displayedComponents: .date
							)
							IOSDatePickerRow(
								label: L10n.tr(.countdownTimeLabel, language: lang),
								selection: $selectedDate,
								displayedComponents: .hourAndMinute
							)
						}

						IOSSection(title: L10n.tr(.citiesNotifications, language: lang)) {
							IOSToggleRow(label: L10n.tr(.countdownDailyReminder, language: lang), isOn: $dailyReminder)
						}

						IOSSection(title: L10n.tr(.citiesStatistics, language: lang)) {
							VStack(spacing: 0) {
								IOSStatCard(
									icon: "calendar",
									iconColor: Color.orange.opacity(0.15),
									label: L10n.tr(.countdownDaysRemaining, language: lang),
									value: "\(daysRemaining)",
									valueColor: .orange
								)
								IOSStatCard(
									icon: "clock",
									iconColor: Color.purple.opacity(0.15),
									label: L10n.tr(.countdownHoursRemaining, language: lang),
									value: "\(max(0, hoursRemaining))",
									valueColor: .purple
								)
								IOSStatCard(
									icon: "sparkles",
									iconColor: Color.blue.opacity(0.15),
									label: L10n.tr(.countdownEventDate, language: lang),
									value: eventDateShort,
									valueColor: .blue
								)
							}
						}

						IOSWidgetPreview {
							CountdownScreenPreviewView(
								title: displayTitle,
								daysRemaining: daysRemaining,
								date: selectedDate
							)
						}
					} else {
						IOSSection(title: "") {
							IOSEmptyState(
								icon: "calendar.badge.clock",
								title: L10n.tr(.countdownDisabled, language: lang),
								description: L10n.tr(.countdownDisabledDescription, language: lang)
							)
						}
					}

					IOSSection(title: L10n.tr(.reset, language: lang)) {
						Button(role: .destructive) {
							showResetAlert = true
						} label: {
							Text(L10n.tr(.reset, language: lang) + " – " + L10n.tr(.countdown, language: lang))
								.frame(maxWidth: .infinity, alignment: .leading)
						}
					}
				}
				.padding(.horizontal, 20)
				.padding(.vertical, 16)
			}
		}
		.navigationTitle(L10n.tr(.countdown, language: lang))
		.navigationBarTitleDisplayMode(.inline)
		.toolbarBackground(.visible, for: .navigationBar)
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button(L10n.tr(.save, language: lang)) {
					model.setCountdownEvent(isEnabled ? selectedDate : nil, label: labelText)
					showSavedAlert = true
				}
				.font(.system(size: 17, weight: .semibold))
				.foregroundStyle(Color.blue)
				.disabled(!hasChanges)
				.buttonStyle(.plain)
			}
		}
		.alert(L10n.tr(.savedAlertTitle, language: lang), isPresented: $showSavedAlert) {
			Button("OK", role: .cancel) {}
		} message: {
			Text(L10n.tr(.savedAlertMessage, language: lang))
		}
		.alert(L10n.tr(.widgetResetTitle, language: lang), isPresented: $showResetAlert) {
			Button(L10n.tr(.cancel, language: lang), role: .cancel) {}
			Button(L10n.tr(.reset, language: lang), role: .destructive) {
				model.resetCountdown()
			}
		} message: {
			Text(L10n.tr(.widgetResetMessage, language: lang))
		}
		.onAppear {
			labelText = snapshot.countdown.label ?? ""
			if let event = snapshot.countdown.eventAtUTC {
				isEnabled = true
				selectedDate = event
			} else {
				isEnabled = false
				selectedDate = Date().addingTimeInterval(60 * 60)
			}
		}
	}
}
