import WidgetKit
import SwiftUI

@main
struct CoupleWidgetsWidgetBundle: WidgetBundle {
	var body: some Widget {
		DistanceWidget()
		CountdownWidget()
		NoteWidget()
	}
}
