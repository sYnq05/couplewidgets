import WidgetKit
import SwiftUI

struct CountdownWidget: Widget {
	static let kind = "CountdownWidget"

	var body: some WidgetConfiguration {
		StaticConfiguration(kind: Self.kind, provider: Provider()) { entry in
			CountdownWidgetView(entry: entry)
		}
		.configurationDisplayName("Countdown")
		.description("Shows your countdown.")
		.supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular, .systemSmall, .systemMedium])
	}
}

private struct CountdownEntry: TimelineEntry {
	let date: Date
	/// Display title (e.g. "Wiedersehen" or "Countdown").
	let titleText: String
	let mainText: String
	/// Event date for rectangular widget subtitle (e.g. "Mar 15").
	let eventDateUTC: Date?
	let widgetURL: URL
	/// True for CTA states (Connect, Set date) so the view can use subtler styling.
	let isPlaceholder: Bool
}

private enum AppURL {
	static func scheme(_ path: String) -> URL { URL(string: "app://\(path)") ?? URL(string: "app://")! }
}

private struct Provider: TimelineProvider {
	private let cache = CacheService()

	func placeholder(in context: Context) -> CountdownEntry {
		CountdownEntry(date: Date(), titleText: "Countdown", mainText: "Set date", eventDateUTC: nil, widgetURL: AppURL.scheme("countdown"), isPlaceholder: true)
	}

	func getSnapshot(in context: Context, completion: @escaping (CountdownEntry) -> Void) {
		if context.isPreview {
			completion(placeholder(in: context))
			return
		}
		let snapshot = cache.readSnapshot()
		completion(makeEntry(from: snapshot, date: Date()))
	}

	func getTimeline(in context: Context, completion: @escaping (Timeline<CountdownEntry>) -> Void) {
		let snapshot = cache.readSnapshot()
		let now = Date()
		let entries = TimelineHelpers.datesEvery30MinutesFor12Hours(from: now).map { date in
			makeEntry(from: snapshot, date: date)
		}
		completion(Timeline(entries: entries, policy: .atEnd))
	}

	private func makeEntry(from snapshot: CacheSnapshot, date: Date) -> CountdownEntry {
		let titleText = snapshot.countdown.displayTitle()
		let lockedOrNotPaired = !snapshot.couple.paired
		if lockedOrNotPaired {
			return CountdownEntry(date: date, titleText: titleText, mainText: "Connect", eventDateUTC: nil, widgetURL: AppURL.scheme("pairing"), isPlaceholder: true)
		}

		guard let eventAt = snapshot.countdown.eventAtUTC else {
			return CountdownEntry(date: date, titleText: titleText, mainText: "Set date", eventDateUTC: nil, widgetURL: AppURL.scheme("countdown"), isPlaceholder: true)
		}

		let display = CountdownFormatter.displayString(eventAtUTC: snapshot.countdown.eventAtUTC, nowUTC: date)
		return CountdownEntry(date: date, titleText: titleText, mainText: display, eventDateUTC: eventAt, widgetURL: AppURL.scheme("countdown"), isPlaceholder: false)
	}
}

private struct CountdownWidgetView: View {
	@Environment(\.widgetFamily) private var family
	let entry: CountdownEntry

	/// Title for display; source is always ≤ Countdown.labelMaxLength.
	private var displayTitle: String {
		let t = entry.titleText
		return t.count > Countdown.labelMaxLength ? String(t.prefix(Countdown.labelMaxLength)).trimmingCharacters(in: .whitespaces) + "…" : t
	}

	/// Parses mainText into number + unit (e.g. "23 days" → ("23", "days"), "5 h" → ("5", "h")).
	private var mainTextParts: (number: String, unit: String) {
		let parts = entry.mainText.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
		if parts.count == 2, !String(parts[1]).isEmpty {
			return (String(parts[0]), String(parts[1]))
		}
		return (entry.mainText, "")
	}

	/// Short event date string for rectangular widget (e.g. "Mar 15").
	private var eventDateShort: String {
		guard let event = entry.eventDateUTC else { return "" }
		let f = DateFormatter()
		f.dateFormat = "MMM d"
		return f.string(from: event)
	}

	private var isAccessoryFamily: Bool {
		switch family {
		case .accessoryCircular, .accessoryInline, .accessoryRectangular: return true
		default: return false
		}
	}

	var body: some View {
		Group {
			switch family {
			case .accessoryCircular: circularView
			case .accessoryInline: inlineView
			case .accessoryRectangular: rectangularView
			case .systemSmall: smallView
			case .systemMedium: mediumView
			default: rectangularView
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.widgetContainerBackground(transparentForAccessory: isAccessoryFamily)
		.widgetURL(entry.widgetURL)
	}

	/// Figma: large number center, unit below (e.g. "23" / "days"). Lock Screen: transparent + white.
	private var circularView: some View {
		VStack(spacing: 2) {
			Text(mainTextParts.number)
				.font(.system(size: 30, weight: .bold, design: .rounded))
				.foregroundColor(entry.isPlaceholder ? WidgetStyle.secondary : WidgetStyle.primary)
				.lineLimit(1)
				.minimumScaleFactor(0.5)
			if !mainTextParts.unit.isEmpty {
				Text(mainTextParts.unit)
					.font(.system(size: 12))
					.foregroundColor(WidgetStyle.secondary)
					.lineLimit(1)
			}
		}
		.padding(4)
	}

	/// Figma: calendar icon + "23 days to Reunion". Lock Screen: transparent + white.
	private var inlineView: some View {
		HStack(spacing: 8) {
			Image(systemName: "calendar")
				.font(.system(size: 12))
				.foregroundColor(WidgetStyle.primary)
			Text(entry.isPlaceholder ? entry.mainText : "\(entry.mainText) to \(displayTitle)")
				.font(.system(size: 14, weight: .semibold))
				.foregroundColor(entry.isPlaceholder ? WidgetStyle.secondary : WidgetStyle.primary)
				.lineLimit(1)
				.minimumScaleFactor(0.6)
		}
		.padding(.horizontal, 8)
		.padding(.vertical, 4)
	}

	/// Figma: left = big number + unit stacked; right = title + date (e.g. "Our Reunion" / "Mar 15"). Lock Screen: transparent + white.
	private var rectangularView: some View {
		HStack(alignment: .center, spacing: 12) {
			VStack(spacing: 2) {
				Text(mainTextParts.number)
					.font(.system(size: 28, weight: .bold, design: .rounded))
					.foregroundColor(entry.isPlaceholder ? WidgetStyle.secondary : WidgetStyle.primary)
					.lineLimit(1)
					.minimumScaleFactor(0.5)
				if !mainTextParts.unit.isEmpty {
					Text(mainTextParts.unit)
						.font(.system(size: 12))
						.foregroundColor(WidgetStyle.secondary)
						.lineLimit(1)
				}
			}
			.frame(minWidth: 36, alignment: .leading)
			VStack(alignment: .leading, spacing: 4) {
				Text(displayTitle)
					.font(.system(size: 15, weight: .semibold))
					.foregroundColor(WidgetStyle.primary)
					.lineLimit(1)
					.minimumScaleFactor(0.7)
				if !eventDateShort.isEmpty {
					HStack(spacing: 4) {
						Image(systemName: "calendar")
							.font(.system(size: 10))
							.foregroundColor(WidgetStyle.secondary)
						Text(eventDateShort)
							.font(.system(size: 12))
							.foregroundColor(WidgetStyle.secondary)
							.lineLimit(1)
					}
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.padding(10)
	}

	private var smallView: some View {
		VStack(alignment: .leading, spacing: 6) {
			HStack {
				Image(systemName: "calendar")
					.font(.caption)
					.foregroundColor(WidgetStyle.secondary)
				Text("Countdown")
					.font(.caption.weight(.semibold))
					.foregroundColor(WidgetStyle.primary)
				Spacer(minLength: 0)
			}
			Text(entry.titleText)
				.font(.caption2)
				.foregroundColor(WidgetStyle.secondary)
			Text(entry.mainText)
				.font(.system(.title3, design: .rounded).weight(.bold))
				.foregroundColor(entry.isPlaceholder ? WidgetStyle.secondary : WidgetStyle.primary)
				.lineLimit(1)
				.minimumScaleFactor(0.5)
		}
		.padding(14)
		.overlay(RoundedRectangle(cornerRadius: 16).stroke(WidgetStyle.stroke, lineWidth: 1))
	}

	private var mediumView: some View {
		VStack(alignment: .leading, spacing: 0) {
			HStack(alignment: .top) {
				HStack(spacing: 4) {
					Image(systemName: "calendar")
						.font(.subheadline)
						.foregroundColor(WidgetStyle.primary)
					Text("Countdown")
						.font(.subheadline.weight(.semibold))
						.foregroundColor(WidgetStyle.primary)
				}
				Spacer(minLength: 0)
				Text(entry.mainText)
					.font(.system(.title2, design: .rounded).weight(.bold))
					.foregroundColor(entry.isPlaceholder ? WidgetStyle.secondary : WidgetStyle.primary)
					.lineLimit(1)
					.minimumScaleFactor(0.5)
			}
			.padding(.bottom, 8)
			Text(entry.titleText)
				.font(.caption)
				.foregroundColor(WidgetStyle.secondary)
		}
		.padding(16)
		.overlay(RoundedRectangle(cornerRadius: 18).stroke(WidgetStyle.stroke, lineWidth: 1))
	}
}

