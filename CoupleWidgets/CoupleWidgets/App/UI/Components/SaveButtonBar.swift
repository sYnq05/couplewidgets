import SwiftUI

/// Bottom-centered save button: gray when no changes, blue when there are changes.
/// Call `onSave()` to persist; parent should show confirmation alert after saving.
/// Triggers light haptic when save is performed.
struct SaveButtonBar: View {
	let title: String
	let hasChanges: Bool
	let action: () -> Void

	init(title: String = "Save", hasChanges: Bool, action: @escaping () -> Void) {
		self.title = title
		self.hasChanges = hasChanges
		self.action = action
	}

	var body: some View {
		Button(action: {
			if hasChanges {
				UIImpactFeedbackGenerator(style: .light).impactOccurred()
			}
			action()
		}) {
			Text(title)
				.font(.body.weight(.semibold))
				.foregroundStyle(hasChanges ? .white : .secondary)
				.frame(maxWidth: .infinity)
				.frame(minHeight: 44)
		}
		.buttonStyle(.plain)
		.background(
			RoundedRectangle(cornerRadius: 14, style: .continuous)
				.fill(hasChanges ? Color.accentColor : Color(.systemGray5))
		)
		.disabled(!hasChanges)
		.padding(.horizontal, 20)
		.padding(.vertical, 12)
		.frame(maxWidth: .infinity)
		.background(Color(.systemGroupedBackground))
	}
}
