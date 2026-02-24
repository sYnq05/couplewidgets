//
//  CoupleWidgetsApp.swift
//  CoupleWidgets
//
//  Created by Jakob Hartmann on 18.02.26.
//

import SwiftUI
import UIKit

@main
struct CoupleWidgetsApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

	init() {
		UINavigationBar.appearance().tintColor = .systemBlue
	}

	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}
