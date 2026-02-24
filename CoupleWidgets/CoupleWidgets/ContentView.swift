//
//  ContentView.swift
//  CoupleWidgets
//
//  Created by Jakob Hartmann on 18.02.26.
//

import SwiftUI

struct ContentView: View {
	@StateObject private var model = AppModel()
	@StateObject private var languageManager = LanguageManager()
	@StateObject private var locationService = LocationService()
	@State private var path: [AppRoute] = []
	@State private var showSyncFailedAlert: Bool = false
	@Environment(\.scenePhase) private var scenePhase

	var body: some View {
		NavigationStack(path: $path) {
			HomeView()
				.navigationDestination(for: AppRoute.self) { route in
					switch route {
					case .distance:
						CitiesView()
					case .countdown:
						CountdownEditorView()
					case .note:
						NoteEditorView()
					case .pairing:
						PairingView()
					case .cities:
						CitiesView()
					case .settings:
						SettingsView()
					}
				}
		}
		.tint(Color.blue)
		.environmentObject(model)
		.environmentObject(model.appleAuth)
		.environmentObject(languageManager)
		.environmentObject(locationService)
		.onOpenURL { url in
			handleDeepLink(url)
		}
		.onAppear {
			model.refreshFromCache()
			Task { await model.syncPull() }
			locationService.startBackgroundMonitoringIfAuthorized()
			let code = model.snapshot.couple.paired ? model.snapshot.couple.inviteCode : nil
			CloudKitSubscriptionService.shared.setupSubscription(inviteCode: code)
		}
		.onReceive(NotificationCenter.default.publisher(for: .locationCacheDidUpdate)) { _ in
			model.refreshFromCache()
		}
		.onChange(of: scenePhase) { _, newPhase in
			if newPhase == .active {
				model.refreshFromCache()
				Task {
					let result = await model.syncPush()
					await MainActor.run {
						if case .saveFailed = result {
							showSyncFailedAlert = true
						}
					}
					await model.syncPull()
					await model.retryPendingRecordDeletes()
				}
			}
		}
		.alert(L10n.tr(.pairingSyncFailedTitle, language: languageManager.resolvedCode), isPresented: $showSyncFailedAlert) {
			Button("OK", role: .cancel) {}
		} message: {
			Text(L10n.tr(.pairingSyncFailedMessage, language: languageManager.resolvedCode))
		}
	}

	private func handleDeepLink(_ url: URL) {
		guard url.scheme == "app" else { return }
		let destination = url.host ?? url.path.replacingOccurrences(of: "/", with: "")
		let route: AppRoute?
		switch destination.lowercased() {
		case "distance": route = .distance
		case "countdown": route = .countdown
		case "note": route = .note
		case "pairing": route = .pairing
		default: route = nil
		}
		guard let route else { return }
		path = [route]
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
