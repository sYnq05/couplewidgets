import WidgetKit
import SwiftUI

struct NoteWidget: Widget {
	static let kind = "NoteWidget"

	var body: some WidgetConfiguration {
		StaticConfiguration(kind: Self.kind, provider: Provider()) { entry in
			NoteWidgetView(entry: entry)
		}
		.configurationDisplayName("Note")
		.description("Shows your latest note.")
		.supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular, .systemSmall, .systemMedium])
	}
}

private struct NoteEntry: TimelineEntry {
	let date: Date
	let mainText: String
	let widgetURL: URL
	/// True for CTA states (Connect, Tap to write) so the view can use subtler styling.
	let isPlaceholder: Bool
	/// Author initials for circular and rectangular "— JH" footer. Nil when placeholder.
	let authorInitials: String?
	/// Note message only (no "Author: " prefix) for rectangular first line. Nil when placeholder.
	let noteText: String?
}

private enum AppURL {
	static func scheme(_ path: String) -> URL { URL(string: "app://\(path)") ?? URL(string: "app://")! }
}

private struct Provider: TimelineProvider {
	private let cache = CacheService()

	func placeholder(in context: Context) -> NoteEntry {
		NoteEntry(date: Date(), mainText: "Tap to write", widgetURL: AppURL.scheme("note"), isPlaceholder: true, authorInitials: nil, noteText: nil)
	}

	func getSnapshot(in context: Context, completion: @escaping (NoteEntry) -> Void) {
		if context.isPreview {
			completion(placeholder(in: context))
			return
		}
		let snapshot = cache.readSnapshot()
		completion(makeEntry(from: snapshot, date: Date()))
	}

	func getTimeline(in context: Context, completion: @escaping (Timeline<NoteEntry>) -> Void) {
		let snapshot = cache.readSnapshot()
		let now = Date()
		let entries = TimelineHelpers.datesEvery30MinutesFor12Hours(from: now).map { date in
			makeEntry(from: snapshot, date: date)
		}
		completion(Timeline(entries: entries, policy: .atEnd))
	}

	private func makeEntry(from snapshot: CacheSnapshot, date: Date) -> NoteEntry {
		let lockedOrNotPaired = !snapshot.couple.paired
		if lockedOrNotPaired {
			return NoteEntry(date: date, mainText: "Connect", widgetURL: AppURL.scheme("pairing"), isPlaceholder: true, authorInitials: nil, noteText: nil)
		}

		let trimmed = snapshot.note.text.trimmingCharacters(in: .whitespacesAndNewlines)
		let initials = snapshot.note.authorInitials
		if trimmed.isEmpty {
			return NoteEntry(date: date, mainText: "Tap to write", widgetURL: AppURL.scheme("note"), isPlaceholder: true, authorInitials: nil, noteText: nil)
		}

		let text = "\(initials): \(trimmed)"
		return NoteEntry(date: date, mainText: text, widgetURL: AppURL.scheme("note"), isPlaceholder: false, authorInitials: initials, noteText: trimmed)
	}
}

private struct NoteWidgetView: View {
	@Environment(\.widgetFamily) private var family
	let entry: NoteEntry

	private var isAccessoryFamily: Bool {
		switch family {
		case .accessoryCircular, .accessoryInline, .accessoryRectangular: return true
		default: return false
		}
	}

	private static let noteIcon = "bubble.left.fill"
	/// Outline style for Lock Screen rectangular to match design.
	private static let noteIconOutline = "bubble.left"

	var body: some View {
		Group {
			switch family {
			case .accessoryCircular: circularView
			case .accessoryRectangular: rectangularView
			case .accessoryInline: inlineView
			case .systemSmall: smallView
			case .systemMedium: mediumView
			default: rectangularView
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.widgetContainerBackground(transparentForAccessory: isAccessoryFamily)
		.widgetURL(entry.widgetURL)
	}

	private var circularView: some View {
		VStack(spacing: 2) {
			Image(systemName: Self.noteIcon)
				.font(.system(size: 12))
				.foregroundColor(WidgetStyle.secondary)
			Text(entry.authorInitials ?? "…")
				.font(.system(.caption2, design: .rounded).weight(.bold))
				.foregroundColor(entry.isPlaceholder ? WidgetStyle.tertiary : WidgetStyle.primary)
				.lineLimit(1)
				.minimumScaleFactor(0.6)
		}
		.padding(3)
	}

	/// Lock Screen: transparent + white; speech bubble outline left, note line 1 + "— Initials" line 2 (design match).
	private var rectangularView: some View {
		HStack(alignment: .center, spacing: 10) {
			Image(systemName: Self.noteIconOutline)
				.font(.system(size: 16))
				.foregroundColor(WidgetStyle.primary)
			VStack(alignment: .leading, spacing: 4) {
				Text(entry.noteText ?? entry.mainText)
					.font(.system(size: 14, weight: .medium))
					.foregroundColor(entry.isPlaceholder ? WidgetStyle.secondary : WidgetStyle.primary)
					.lineLimit(2)
					.minimumScaleFactor(0.7)
				if let initials = entry.authorInitials, !initials.isEmpty {
					Text("— \(initials)")
						.font(.system(size: 12))
						.foregroundColor(WidgetStyle.tertiary)
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.padding(12)
	}

	private var inlineView: some View {
		HStack(spacing: 6) {
			Image(systemName: Self.noteIcon)
				.font(.system(size: 10))
				.foregroundColor(WidgetStyle.tertiary)
			Text(entry.mainText)
				.font(.caption.weight(.medium))
				.foregroundColor(entry.isPlaceholder ? WidgetStyle.secondary : WidgetStyle.primary)
				.lineLimit(1)
				.minimumScaleFactor(0.5)
		}
		.padding(.horizontal, 8)
		.padding(.vertical, 4)
	}

	private static let noteAccent = Color(red: 0.06, green: 0.73, blue: 0.51) // Emerald

	private var smallView: some View {
		VStack(alignment: .leading, spacing: 6) {
			HStack {
				Image(systemName: Self.noteIcon)
					.font(.caption)
					.foregroundColor(Self.noteAccent)
				Text("Note")
					.font(.caption.weight(.semibold))
					.foregroundColor(WidgetStyle.primary)
				Spacer(minLength: 0)
			}
			Text(entry.noteText ?? entry.mainText)
				.font(.system(.caption, design: .rounded).weight(.medium))
				.foregroundColor(entry.isPlaceholder ? WidgetStyle.secondary : WidgetStyle.primary)
				.lineLimit(4)
				.minimumScaleFactor(0.7)
			if let initials = entry.authorInitials, !initials.isEmpty {
				Text("— \(initials)")
					.font(.caption2)
					.foregroundColor(WidgetStyle.tertiary)
			}
		}
		.padding(14)
		.overlay(RoundedRectangle(cornerRadius: 16).stroke(WidgetStyle.stroke, lineWidth: 1))
	}

	private var mediumView: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack(spacing: 4) {
				Image(systemName: Self.noteIcon)
					.font(.subheadline)
					.foregroundColor(Self.noteAccent)
				Text("Note")
					.font(.subheadline.weight(.semibold))
					.foregroundColor(WidgetStyle.primary)
			}
			Text(entry.noteText ?? entry.mainText)
				.font(.system(.subheadline, design: .rounded).weight(.medium))
				.foregroundColor(entry.isPlaceholder ? WidgetStyle.secondary : WidgetStyle.primary)
				.lineLimit(5)
				.minimumScaleFactor(0.8)
			if let initials = entry.authorInitials, !initials.isEmpty {
				Text("— \(initials)")
					.font(.caption)
					.foregroundColor(WidgetStyle.tertiary)
			}
		}
		.padding(16)
		.overlay(RoundedRectangle(cornerRadius: 18).stroke(WidgetStyle.stroke, lineWidth: 1))
		.overlay(
			RoundedRectangle(cornerRadius: 18)
				.stroke(Self.noteAccent.opacity(0.4), lineWidth: 2)
				.padding(1)
		)
	}
}

