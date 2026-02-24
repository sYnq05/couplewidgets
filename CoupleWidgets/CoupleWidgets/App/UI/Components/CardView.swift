import SwiftUI

struct CardView<Content: View>: View {
	let title: String
	let icon: String?
	let content: Content

	init(title: String, icon: String? = nil, @ViewBuilder content: () -> Content) {
		self.title = title
		self.icon = icon
		self.content = content()
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack(spacing: 8) {
				if let icon {
					Image(systemName: icon)
						.font(.subheadline.weight(.semibold))
						.foregroundStyle(.secondary)
				}
				Text(title)
					.font(.subheadline.weight(.semibold))
					.foregroundStyle(.secondary)
			}
			content
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

