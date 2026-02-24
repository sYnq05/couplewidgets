import UIKit
import UserNotifications

/// Handles remote (CloudKit) push registration and showing a local notification when the couple record is updated (e.g. partner saved a note).
/// Requires: Push Notifications capability and Background Modes → Remote notifications in the app target.
final class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
		application.registerForRemoteNotifications()
		return true
	}

	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		// Token is used by CloudKit automatically for subscriptions.
	}

	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		#if DEBUG
		print("[AppDelegate] Remote notification registration failed: \(error)")
		#endif
	}

	func application(
		_ application: UIApplication,
		didReceiveRemoteNotification userInfo: [AnyHashable: Any],
		fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
	) {
		Task {
			await handleCloudKitPush(completionHandler: completionHandler)
		}
	}

	private func handleCloudKitPush(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) async {
		let cache = CacheService()
		let cloudKit = CloudKitSyncService()
		let appleAuth = AppleAuthService()
		let snapshot = cache.readSnapshot()
		guard snapshot.couple.paired,
		      let code = snapshot.couple.inviteCode,
		      !code.isEmpty,
		      snapshot.couple.role == .owner || snapshot.couple.role == .partner,
		      let appleId = appleAuth.currentUserIdentifier else {
			completionHandler(.noData)
			return
		}
		guard let updated = await cloudKit.pull(role: snapshot.couple.role, current: snapshot, currentAppleId: appleId) else {
			completionHandler(.noData)
			return
		}
		cache.writeSnapshot(updated, nowUTC: Date())
		// Only show "new note" when the note actually changed (record can update for countdown/cities too).
		let noteChanged = updated.note.updatedAtUTC != snapshot.note.updatedAtUTC && updated.note.updatedAtUTC != nil
		if noteChanged {
			let partnerName = updated.partner.name.isEmpty ? updated.partner.initials : updated.partner.name
			let lang = Locale.current.identifier.hasPrefix("de") ? "de" : "en"
			let title = L10n.tr(.notePushNotificationTitle, language: lang)
			let body = String(format: L10n.tr(.notePushNotificationBody, language: lang), partnerName)
			let content = UNMutableNotificationContent()
			content.title = title
			content.body = body
			content.sound = .default
			let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
			UNUserNotificationCenter.current().add(request)
		}
		completionHandler(.newData)
	}
}
