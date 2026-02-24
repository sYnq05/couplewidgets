import SwiftUI

/// Data for the Distance widget medium layout. Used by the app (preview) and the widget.
public struct DistancePreviewData {
	public let meInitials: String
	public let partnerInitials: String
	public let meCityLabel: String?
	public let partnerCityLabel: String?
	public let mainText: String
	public let meCountryCode: String?
	public let partnerCountryCode: String?
	/// Time difference in hours (me - partner). Nil when not available.
	public let timeDifferenceHours: Int?

	public init(
		meInitials: String,
		partnerInitials: String,
		meCityLabel: String?,
		partnerCityLabel: String?,
		mainText: String,
		meCountryCode: String?,
		partnerCountryCode: String?,
		timeDifferenceHours: Int? = nil
	) {
		self.meInitials = meInitials
		self.partnerInitials = partnerInitials
		self.meCityLabel = meCityLabel
		self.partnerCityLabel = partnerCityLabel
		self.mainText = mainText
		self.meCountryCode = meCountryCode
		self.partnerCountryCode = partnerCountryCode
		self.timeDifferenceHours = timeDifferenceHours
	}

	/// Maps country display name to ISO-style 2-letter code for badges.
	public static func countryCode(for countryName: String) -> String? {
		let map: [String: String] = [
			"China": "CN", "Deutschland": "DE", "Frankreich": "FR", "Großbritannien": "GB",
			"Italien": "IT", "Niederlande": "NL", "Österreich": "AT", "Schweiz": "CH",
			"Spanien": "ES", "USA": "US"
		]
		return map[countryName]
	}
}

private let dpPrimary = Color.white
private let dpSecondary = Color.white.opacity(0.85)
private let dpTertiary = Color.white.opacity(0.65)
private let dpStroke = Color.white.opacity(0.6)

/// Medium-size Distance widget layout (SwiftUI only). Use in app preview and in widget for .systemMedium.
public struct DistancePreviewContentView: View {
	let data: DistancePreviewData

	public init(data: DistancePreviewData) {
		self.data = data
	}

	public var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			HStack(alignment: .top) {
				HStack(spacing: 4) {
					Image(systemName: "paperplane")
						.font(.subheadline)
						.foregroundColor(dpPrimary)
					Text("Distance")
						.font(.subheadline.weight(.semibold))
						.foregroundColor(dpPrimary)
				}
			}
			.padding(.bottom, 10)

			HStack(alignment: .bottom, spacing: 8) {
				VStack(alignment: .center, spacing: 4) {
					badgeViewWithCountry(initials: data.meInitials, countryCode: data.meCountryCode, size: 20)
					Text(data.meCityLabel ?? "—")
						.font(.caption)
						.foregroundColor(dpSecondary)
						.lineLimit(2)
						.minimumScaleFactor(0.7)
						.multilineTextAlignment(.center)
				}
				.frame(minWidth: 36)
				Spacer(minLength: 0)
				VStack(spacing: 6) {
					Text(data.mainText)
						.font(.system(.title, design: .rounded).weight(.bold))
						.foregroundColor(dpPrimary)
						.lineLimit(1)
						.minimumScaleFactor(0.5)
						.multilineTextAlignment(.center)
					if let h = data.timeDifferenceHours {
						Text("\(h)h difference")
							.font(.caption2)
							.foregroundColor(dpTertiary)
					}
					dashedLineWithPlane
				}
				.frame(maxWidth: 80)
				Spacer(minLength: 0)
				VStack(alignment: .center, spacing: 4) {
					badgeViewWithCountry(initials: data.partnerInitials, countryCode: data.partnerCountryCode, size: 20)
					Text(data.partnerCityLabel ?? "—")
						.font(.caption)
						.foregroundColor(dpSecondary)
						.lineLimit(2)
						.minimumScaleFactor(0.7)
						.multilineTextAlignment(.center)
				}
				.frame(minWidth: 36)
			}
		}
		.padding(16)
		.overlay(RoundedRectangle(cornerRadius: 18).stroke(dpStroke, lineWidth: 1))
	}

	private func badgeViewWithCountry(initials: String, countryCode: String?, size: CGFloat) -> some View {
		VStack(spacing: 2) {
			Text(initials)
				.font(.system(size: size, weight: .bold))
				.foregroundColor(dpPrimary)
			if let code = countryCode {
				Text(code)
					.font(.system(size: size * 0.6))
					.foregroundColor(dpSecondary)
			}
		}
		.frame(minWidth: size * 1.8)
		.padding(8)
		.background(RoundedRectangle(cornerRadius: 10).stroke(dpStroke, lineWidth: 1))
	}

	private var dashedLineWithPlane: some View {
		HStack(spacing: 4) {
			Rectangle()
				.stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
				.foregroundColor(dpTertiary)
				.frame(height: 1)
				.layoutPriority(1)
			Image(systemName: "paperplane")
				.font(.system(size: 10))
				.foregroundColor(dpTertiary)
			Rectangle()
				.stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
				.foregroundColor(dpTertiary)
				.frame(height: 1)
				.layoutPriority(1)
		}
		.frame(maxWidth: 60)
	}
}
