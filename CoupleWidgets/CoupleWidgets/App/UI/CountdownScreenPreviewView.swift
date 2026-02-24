import SwiftUI

/// Countdown screen widget preview: matches systemMedium widget layout (dark card, header + mainText, title below).
struct CountdownScreenPreviewView: View {
	@EnvironmentObject private var languageManager: LanguageManager
	let title: String
	let daysRemaining: Int
	let date: Date

	private static let previewPrimary = Color.white
	private static let previewSecondary = Color.white.opacity(0.85)
	private static let previewStroke = Color.white.opacity(0.6)

	private var mainText: String {
		let lang = languageManager.resolvedCode
		return daysRemaining >= 0 ? String(format: L10n.tr(.countdownDaysRemainingFormat, language: lang), daysRemaining) : L10n.tr(.setDate, language: lang)
	}

	var body: some View {
		ZStack {
			LinearGradient(
				colors: [Color(white: 0.18), Color(white: 0.10)],
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)
			VStack(alignment: .leading, spacing: 0) {
				HStack(alignment: .top) {
					HStack(spacing: 4) {
						Image(systemName: "calendar")
							.font(.subheadline)
							.foregroundColor(Self.previewPrimary)
						Text(L10n.tr(.countdown, language: languageManager.resolvedCode))
							.font(.subheadline.weight(.semibold))
							.foregroundColor(Self.previewPrimary)
					}
					Spacer(minLength: 0)
					Text(mainText)
						.font(.system(.title2, design: .rounded).weight(.bold))
						.foregroundColor(Self.previewPrimary)
						.lineLimit(1)
						.minimumScaleFactor(0.5)
				}
				.padding(.bottom, 8)
				Text(title)
					.font(.caption)
					.foregroundColor(Self.previewSecondary)
			}
			.padding(16)
			.overlay(RoundedRectangle(cornerRadius: 18).stroke(Self.previewStroke, lineWidth: 1))
		}
		.frame(height: 160)
		.clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
	}
}
