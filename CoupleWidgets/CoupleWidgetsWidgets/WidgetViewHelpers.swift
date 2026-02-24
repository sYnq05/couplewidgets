import SwiftUI
import WidgetKit

/// Shared white/transparent styling for Lock Screen and Home Screen widgets (Distance, Countdown, Note).
enum WidgetStyle {
	static let primary = Color.white
	static let secondary = Color.white.opacity(0.85)
	static let tertiary = Color.white.opacity(0.65)
	static let stroke = Color.white.opacity(0.6)
}

/// Dark gradient used as widget container background so white text is visible on Home Screen (light mode) and Lock Screen.
private let widgetBackgroundGradient = LinearGradient(
	colors: [Color(white: 0.18), Color(white: 0.10)],
	startPoint: .topLeading,
	endPoint: .bottomTrailing
)

extension View {
	/// Adopts the container background API on iOS 17+. Use transparentForAccessory: true for Lock Screen (accessory) families so the widget is transparent with white content; use false for Home Screen (systemSmall/systemMedium) so content is visible on light backgrounds.
	@ViewBuilder
	func widgetContainerBackground(transparentForAccessory: Bool = false) -> some View {
		if #available(iOSApplicationExtension 17.0, *) {
			self.containerBackground(for: .widget) {
				if transparentForAccessory {
					Color.clear
				} else {
					widgetBackgroundGradient
				}
			}
		} else {
			self.background(
				Group {
					if transparentForAccessory {
						Color.clear
					} else {
						widgetBackgroundGradient
					}
				}
			)
		}
	}
}
