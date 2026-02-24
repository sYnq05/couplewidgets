import SwiftUI

/// Home screen widget card per Figma: icon in rounded square, title, description, "Configure >" gradient button.
struct HomeWidgetCardView: View {
	@EnvironmentObject private var languageManager: LanguageManager
	let gradientColors: [Color]
	let iconName: String
	let title: String
	let description: String
	let route: AppRoute

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack(alignment: .top, spacing: 16) {
				RoundedRectangle(cornerRadius: 12)
					.fill(
						LinearGradient(
							colors: gradientColors,
							startPoint: .topLeading,
							endPoint: .bottomTrailing
						)
					)
					.frame(width: 48, height: 48)
					.overlay(
						Image(systemName: iconName)
							.font(.system(size: 22, weight: .semibold))
							.foregroundStyle(.white)
					)

				VStack(alignment: .leading, spacing: 4) {
					Text(title)
						.font(.headline.weight(.bold))
						.foregroundStyle(.primary)
					Text(description)
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
				.frame(maxWidth: .infinity, alignment: .leading)
			}

			NavigationLink(value: route) {
				HStack {
					Text(L10n.tr(.generalConfigure, language: languageManager.resolvedCode))
						.font(.system(size: 16, weight: .semibold))
					Image(systemName: "chevron.right")
						.font(.system(size: 14, weight: .semibold))
				}
				.foregroundStyle(.white)
				.frame(maxWidth: .infinity)
				.padding(.vertical, 12)
				.background(
					RoundedRectangle(cornerRadius: 12, style: .continuous)
						.fill(
							LinearGradient(
								colors: gradientColors,
								startPoint: .leading,
								endPoint: .trailing
							)
						)
				)
			}
			.buttonStyle(.plain)
		}
		.padding(18)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(
			RoundedRectangle(cornerRadius: 20, style: .continuous)
				.fill(Color(.systemBackground))
				.shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
		)
	}
}

struct WidgetCardView: View {
	let gradientColors: [Color]
	let iconName: String
	let title: String
	let description: String
	let mainText: String

	var body: some View {
		HStack(alignment: .top, spacing: 16) {
			ZStack {
				Circle()
					.fill(
						LinearGradient(
							colors: gradientColors,
							startPoint: .topLeading,
							endPoint: .bottomTrailing
						)
					)
					.frame(width: 48, height: 48)
				Image(systemName: iconName)
					.font(.system(size: 22, weight: .semibold))
					.foregroundStyle(.white)
			}

			VStack(alignment: .leading, spacing: 6) {
				Text(title)
					.font(.headline.weight(.semibold))
					.foregroundStyle(.primary)
				Text(description)
					.font(.subheadline)
					.foregroundStyle(.secondary)
				Text(mainText)
					.font(.system(size: 28, weight: .bold, design: .rounded))
					.foregroundStyle(
						LinearGradient(
							colors: gradientColors,
							startPoint: .leading,
							endPoint: .trailing
						)
					)
					.lineLimit(2)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.padding(18)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(
			RoundedRectangle(cornerRadius: 20, style: .continuous)
				.fill(Color(.systemBackground))
				.shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
		)
	}
}
