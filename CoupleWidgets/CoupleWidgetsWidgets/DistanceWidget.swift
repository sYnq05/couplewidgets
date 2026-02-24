import WidgetKit
import SwiftUI

struct DistanceWidget: Widget {
	static let kind = "DistanceWidget"

	var body: some WidgetConfiguration {
		StaticConfiguration(kind: Self.kind, provider: Provider()) { entry in
			DistanceWidgetView(entry: entry)
		}
		.configurationDisplayName("Distance")
		.description("Shows your distance in km.")
		.supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular, .systemSmall, .systemMedium])
	}
}

private struct DistanceEntry: TimelineEntry {
	let date: Date
	let miniLabel: String
	let mainText: String
	let widgetURL: URL
	/// True for CTA states (Connect, Set city) so the view can use subtler styling.
	let isPlaceholder: Bool
	/// Initials and city labels for badge/layout (nil when no city set).
	let meInitials: String
	let partnerInitials: String
	let meCityLabel: String?
	let partnerCityLabel: String?
	let meCountryCode: String?
	let partnerCountryCode: String?
	/// Raw km for compact formatting (e.g. "6k"); nil when placeholder.
	let kmValue: Double?
	/// Time difference in hours (me - partner); nil when not available.
	let timeDifferenceHours: Int?
}

private enum AppURL {
	static func scheme(_ path: String) -> URL { URL(string: "app://\(path)") ?? URL(string: "app://")! }
}

private struct Provider: TimelineProvider {
	private let cache = CacheService()

	func placeholder(in context: Context) -> DistanceEntry {
		DistanceEntry(
			date: Date(),
			miniLabel: "A ↔ B",
			mainText: "Connect",
			widgetURL: AppURL.scheme("pairing"),
			isPlaceholder: true,
			meInitials: "A",
			partnerInitials: "B",
			meCityLabel: nil,
			partnerCityLabel: nil,
			meCountryCode: nil,
			partnerCountryCode: nil,
			kmValue: nil,
			timeDifferenceHours: nil
		)
	}

	func getSnapshot(in context: Context, completion: @escaping (DistanceEntry) -> Void) {
		if context.isPreview {
			completion(placeholder(in: context))
			return
		}
		let snapshot = cache.readSnapshot()
		completion(makeEntry(from: snapshot, date: Date()))
	}

	func getTimeline(in context: Context, completion: @escaping (Timeline<DistanceEntry>) -> Void) {
		let snapshot = cache.readSnapshot()
		let now = Date()
		let entries = TimelineHelpers.datesEvery30MinutesFor12Hours(from: now).map { date in
			makeEntry(from: snapshot, date: date)
		}
		completion(Timeline(entries: entries, policy: .atEnd))
	}

	private func makeEntry(from snapshot: CacheSnapshot, date: Date) -> DistanceEntry {
		let meInits = snapshot.me.initials
		let partnerInits = snapshot.partner.initials
		let mini = snapshot.miniLabel
		let lockedOrNotPaired = !snapshot.couple.paired
		if lockedOrNotPaired {
			return DistanceEntry(
				date: date, miniLabel: mini, mainText: "Connect", widgetURL: AppURL.scheme("pairing"),
				isPlaceholder: true,
				meInitials: meInits, partnerInitials: partnerInits,
				meCityLabel: nil, partnerCityLabel: nil, meCountryCode: nil, partnerCountryCode: nil,
				kmValue: nil,
				timeDifferenceHours: nil
			)
		}
		guard let me = snapshot.meCity, let partner = snapshot.partnerCity else {
			return DistanceEntry(
				date: date, miniLabel: mini, mainText: "Set city", widgetURL: AppURL.scheme("distance"),
				isPlaceholder: true,
				meInitials: meInits, partnerInitials: partnerInits,
				meCityLabel: nil, partnerCityLabel: nil, meCountryCode: nil, partnerCountryCode: nil,
				kmValue: nil,
				timeDifferenceHours: nil
			)
		}
		let km = DistanceCalculator.haversineKm(lat1: me.lat, lon1: me.lon, lat2: partner.lat, lon2: partner.lon)
		let timeDiff = TimeZoneDifference.hoursDifference(
			meCityName: me.name, meLat: me.lat, meLon: me.lon,
			partnerCityName: partner.name, partnerLat: partner.lat, partnerLon: partner.lon,
			at: date
		)
		return DistanceEntry(
			date: date, miniLabel: mini, mainText: "\(km) km", widgetURL: AppURL.scheme("distance"),
			isPlaceholder: false,
			meInitials: meInits, partnerInitials: partnerInits,
			meCityLabel: me.name, partnerCityLabel: partner.name,
			meCountryCode: DistancePreviewData.countryCode(for: me.country), partnerCountryCode: DistancePreviewData.countryCode(for: partner.country),
			kmValue: Double(km),
			timeDifferenceHours: timeDiff
		)
	}
}

// MARK: - White transparent styling
private let wPrimary = Color.white
private let wSecondary = Color.white.opacity(0.85)
private let wTertiary = Color.white.opacity(0.65)
private let wStroke = Color.white.opacity(0.6)

private struct DistanceWidgetView: View {
	@Environment(\.widgetFamily) private var family
	let entry: DistanceEntry

	private var isAccessoryFamily: Bool {
		switch family {
		case .accessoryCircular, .accessoryInline, .accessoryRectangular: return true
		default: return false
		}
	}

	var body: some View {
		Group {
			switch family {
			case .accessoryCircular:
				circularView
			case .accessoryInline:
				inlineView
			case .accessoryRectangular:
				rectangularView
			case .systemSmall:
				smallView
			case .systemMedium:
				DistancePreviewContentView(data: DistancePreviewData(
					meInitials: entry.meInitials,
					partnerInitials: entry.partnerInitials,
					meCityLabel: entry.meCityLabel,
					partnerCityLabel: entry.partnerCityLabel,
					mainText: entry.mainText,
					meCountryCode: entry.meCountryCode,
					partnerCountryCode: entry.partnerCountryCode,
					timeDifferenceHours: entry.timeDifferenceHours
				))
			default:
				rectangularView
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.widgetContainerBackground(transparentForAccessory: isAccessoryFamily)
		.widgetURL(entry.widgetURL)
	}

	// MARK: - accessoryCircular: initials + distance (V3), transparent, no outline on lock screen
	private var circularView: some View {
		VStack(spacing: 2) {
				HStack(spacing: 2) {
					Text(entry.meInitials)
						.font(.system(size: 9, weight: .semibold))
						.foregroundColor(wSecondary)
					Text(" • ")
						.font(.system(size: 8))
						.foregroundColor(wTertiary)
					Text(entry.partnerInitials)
						.font(.system(size: 9, weight: .semibold))
						.foregroundColor(wSecondary)
				}
				.lineLimit(1)
				.minimumScaleFactor(0.6)
				if let km = entry.kmValue {
					Text("\(Int(km))")
						.font(.system(.body, design: .rounded).weight(.bold))
						.foregroundColor(wPrimary)
						.lineLimit(1)
						.minimumScaleFactor(0.5)
					Text("km")
						.font(.caption2)
						.foregroundColor(wSecondary)
				} else {
					Text(entry.mainText)
						.font(.caption.weight(.medium))
						.foregroundColor(wSecondary)
						.lineLimit(1)
						.minimumScaleFactor(0.6)
				}
			}
		.padding(3)
	}

	// MARK: - accessoryInline: one line JH • 8,642 km • DY (transparent, white lines)
	private var inlineView: some View {
		HStack(spacing: 4) {
			Text(entry.meInitials)
				.font(.caption.weight(.semibold))
				.foregroundColor(wPrimary)
			Text(" • ")
				.font(.caption.weight(.medium))
				.foregroundColor(wTertiary)
			Text(entry.mainText)
				.font(.caption.weight(.semibold))
				.foregroundColor(entry.isPlaceholder ? wSecondary : wPrimary)
				.lineLimit(1)
				.minimumScaleFactor(0.5)
			Text(" • ")
				.font(.caption.weight(.medium))
				.foregroundColor(wTertiary)
			Text(entry.partnerInitials)
				.font(.caption.weight(.semibold))
				.foregroundColor(wPrimary)
		}
		.padding(.horizontal, 8)
		.padding(.vertical, 4)
	}

	// MARK: - accessoryRectangular: initials left | number | initials right (transparent, no outline)
	private var rectangularView: some View {
		HStack(spacing: 8) {
			badgeView(initials: entry.meInitials, size: 14)
			Spacer(minLength: 4)
			VStack(spacing: 2) {
				if let km = entry.kmValue {
					Text("\(Int(km))")
						.font(.system(.body, design: .rounded).weight(.bold))
						.foregroundColor(wPrimary)
						.lineLimit(1)
						.minimumScaleFactor(0.5)
				} else {
					Text(entry.mainText)
						.font(.system(.caption, design: .rounded).weight(.bold))
						.foregroundColor(entry.isPlaceholder ? wSecondary : wPrimary)
						.lineLimit(1)
						.minimumScaleFactor(0.5)
				}
			}
			.layoutPriority(1)
			Spacer(minLength: 4)
			badgeView(initials: entry.partnerInitials, size: 14)
		}
		.padding(8)
	}

	// MARK: - systemSmall: header + dark pill with initials + distance (cooler home screen)
	private static let smallAccentBg = Color(white: 0.18)

	private var smallView: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Image(systemName: "paperplane")
					.font(.caption)
					.foregroundColor(wSecondary)
				Text("Distance")
					.font(.caption.weight(.semibold))
					.foregroundColor(wPrimary)
				Spacer(minLength: 0)
			}
			HStack(spacing: 6) {
				Text(entry.meInitials)
					.font(.caption.weight(.semibold))
					.foregroundColor(wPrimary)
				Text(" • ")
					.font(.caption)
					.foregroundColor(wTertiary)
				Text(entry.mainText)
					.font(.system(.subheadline, design: .rounded).weight(.bold))
					.foregroundColor(wPrimary)
					.lineLimit(1)
					.minimumScaleFactor(0.5)
				Text(" • ")
					.font(.caption)
					.foregroundColor(wTertiary)
				Text(entry.partnerInitials)
					.font(.caption.weight(.semibold))
					.foregroundColor(wPrimary)
			}
			.padding(.horizontal, 12)
			.padding(.vertical, 10)
			.frame(maxWidth: .infinity, alignment: .leading)
			.background(
				RoundedRectangle(cornerRadius: 12, style: .continuous)
					.fill(Self.smallAccentBg)
			)
		}
		.padding(14)
		.overlay(RoundedRectangle(cornerRadius: 16).stroke(wStroke, lineWidth: 1))
	}

	private func badgeView(initials: String, size: CGFloat) -> some View {
		Text(initials)
			.font(.system(size: size, weight: .bold))
			.foregroundColor(wPrimary)
			.frame(width: size * 2, height: size * 2)
	}

}
