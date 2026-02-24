import SwiftUI

struct HomeView: View {
	@EnvironmentObject private var model: AppModel
	@EnvironmentObject private var languageManager: LanguageManager

	private var snapshot: CacheSnapshot { model.snapshot }
	private var lang: String { languageManager.resolvedCode }

	private static let distanceGradient = [Color(hex: "A855F7"), Color(hex: "EC4899")]
	private static let countdownGradient = [Color.orange, Color.red]
	private static let noteGradient = [Color(hex: "10B981"), Color(hex: "14B8A6")]

	var body: some View {
		ZStack {
			Color(UIColor.systemGroupedBackground)
				.ignoresSafeArea()
			ScrollView {
				VStack(alignment: .leading, spacing: 20) {
					VStack(alignment: .leading, spacing: 4) {
						Text(L10n.tr(.appTitle, language: lang))
							.font(.largeTitle.weight(.bold))
							.foregroundStyle(.primary)
						Text(L10n.tr(.yourWidgets, language: lang))
							.font(.subheadline)
							.foregroundStyle(.secondary)
					}
					.padding(.bottom, 4)

					if model.isUsingStandardFallback {
						Text(L10n.tr(.homeAppGroupWarning, language: lang))
							.font(.footnote.weight(.semibold))
							.foregroundStyle(.primary)
							.padding(14)
							.frame(maxWidth: .infinity, alignment: .leading)
							.background(
								RoundedRectangle(cornerRadius: 14, style: .continuous)
									.fill(Color(.secondarySystemFill))
							)
					}

					if !snapshot.couple.paired {
						NavigationLink(value: AppRoute.pairing) {
							HStack(spacing: 12) {
								Image(systemName: "link.circle.fill")
									.font(.title2)
									.foregroundStyle(.white)
								Text(L10n.tr(.homeConnectNow, language: lang))
									.font(.subheadline.weight(.semibold))
									.foregroundStyle(.white)
								Spacer()
								Image(systemName: "chevron.right")
									.font(.caption.weight(.semibold))
									.foregroundStyle(.white.opacity(0.8))
							}
							.padding(16)
							.frame(maxWidth: .infinity, alignment: .leading)
							.background(
								RoundedRectangle(cornerRadius: 16, style: .continuous)
									.fill(LinearGradient(colors: [Color(hex: "A855F7"), Color(hex: "EC4899")], startPoint: .leading, endPoint: .trailing))
							)
						}
						.buttonStyle(.plain)
					}

					HomeWidgetCardView(
						gradientColors: Self.distanceGradient,
						iconName: "paperplane",
						title: L10n.tr(.distance, language: lang),
						description: L10n.tr(.distanceDescription, language: lang),
						route: .distance
					)

					HomeWidgetCardView(
						gradientColors: Self.countdownGradient,
						iconName: "calendar",
						title: snapshot.countdown.displayTitle(),
						description: L10n.tr(.countdownDescription, language: lang),
						route: .countdown
					)

					HomeWidgetCardView(
						gradientColors: Self.noteGradient,
						iconName: "doc.text",
						title: L10n.tr(.note, language: lang),
						description: L10n.tr(.noteDescription, language: lang),
						route: .note
					)

					statusCard

					Text(String(format: L10n.tr(.homeByFor, language: lang), snapshot.me.initials, snapshot.partner.initials))
						.font(.footnote)
						.foregroundStyle(.tertiary)
						.frame(maxWidth: .infinity)
						.padding(.top, 8)
						.padding(.bottom, 4)
				}
				.padding(.horizontal, 16)
				.padding(.vertical, 20)
			}
		}
		.scrollContentBackground(.hidden)
		.navigationTitle(L10n.tr(.appTitle, language: lang))
		.navigationBarTitleDisplayMode(.inline)
		.toolbarBackground(.visible, for: .navigationBar)
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Menu {
					NavigationLink(value: AppRoute.pairing) { Text(L10n.tr(.pairing, language: lang)) }
					NavigationLink(value: AppRoute.settings) { Text(L10n.tr(.settingsTitle, language: lang)) }
				} label: {
					Image(systemName: "ellipsis")
						.font(.system(size: 17, weight: .medium))
						.foregroundColor(.primary)
						.frame(width: 44, height: 44)
						.contentShape(Rectangle())
				}
				.accessibilityLabel(L10n.tr(.settingsTitle, language: lang))
			}
		}
	}

	private var statusCard: some View {
		HStack(alignment: .center, spacing: 16) {
			Image(systemName: "heart.fill")
				.font(.title2)
				.foregroundStyle(.pink)
			VStack(alignment: .leading, spacing: 6) {
				HStack {
					Text(L10n.tr(.homePairingLabel, language: lang))
						.font(.subheadline)
						.foregroundStyle(.secondary)
					Spacer()
					Text(pairingStatusText)
						.font(.subheadline)
						.foregroundStyle(snapshot.couple.paired ? .green : .secondary)
				}
				HStack {
					Text(L10n.tr(.homeLastSync, language: lang))
						.font(.subheadline)
						.foregroundStyle(.secondary)
					Spacer()
					Text(lastCacheWriteText())
						.font(.subheadline)
						.foregroundStyle(.primary)
				}
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

	private var pairingStatusText: String {
		snapshot.couple.paired ? L10n.tr(.homePaired, language: lang) : L10n.tr(.homeNotPaired, language: lang)
	}

	private func lastCacheWriteText() -> String {
		guard let date = snapshot.lastCacheWriteAtUTC else { return "—" }
		let df = DateFormatter()
		df.dateStyle = .none
		df.timeStyle = .short
		return df.string(from: date)
	}
}

