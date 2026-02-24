import SwiftUI

/// Note screen widget preview: matches systemMedium widget layout (dark card, bubble icon + "Note", note text, — initials).
struct NoteScreenPreviewView: View {
	@EnvironmentObject private var languageManager: LanguageManager
	let title: String
	let note: String
	var authorInitials: String? = nil
	let showStreak: Bool
	let currentStreak: Int
	let lastUpdated: Date?

	private static let noteIcon = "bubble.left.fill"
	private static let noteAccent = Color(red: 0.06, green: 0.73, blue: 0.51)
	private static let previewPrimary = Color.white
	private static let previewSecondary = Color.white.opacity(0.85)
	private static let previewTertiary = Color.white.opacity(0.65)
	private static let previewStroke = Color.white.opacity(0.6)

	var body: some View {
		ZStack {
			LinearGradient(
				colors: [Color(white: 0.18), Color(white: 0.10)],
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)
			VStack(alignment: .leading, spacing: 8) {
				HStack(spacing: 4) {
					Image(systemName: Self.noteIcon)
						.font(.subheadline)
						.foregroundColor(Self.noteAccent)
					Text(L10n.tr(.note, language: languageManager.resolvedCode))
						.font(.subheadline.weight(.semibold))
						.foregroundColor(Self.previewPrimary)
				}
				Text(note.isEmpty ? L10n.tr(.noteNoMessageYet, language: languageManager.resolvedCode) : note)
					.font(.system(.subheadline, design: .rounded).weight(.medium))
					.foregroundColor(note.isEmpty ? Self.previewSecondary : Self.previewPrimary)
					.lineLimit(5)
					.minimumScaleFactor(0.8)
				if let initials = authorInitials, !initials.isEmpty {
					Text("— \(initials)")
						.font(.caption)
						.foregroundColor(Self.previewTertiary)
				}
			}
			.padding(16)
			.overlay(RoundedRectangle(cornerRadius: 18).stroke(Self.previewStroke, lineWidth: 1))
			.overlay(
				RoundedRectangle(cornerRadius: 18)
					.stroke(Self.noteAccent.opacity(0.4), lineWidth: 2)
					.padding(1)
			)
		}
		.frame(height: 160)
		.clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
	}
}
