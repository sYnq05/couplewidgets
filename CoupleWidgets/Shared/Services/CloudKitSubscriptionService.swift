import Foundation
import CloudKit

private let subscriptionIDUserDefaultsKey = "CloudKitSubscriptionService.subscriptionID"

/// Manages CloudKit subscription for the couple record so the app receives a push when the record is updated (e.g. partner saves a note).
final class CloudKitSubscriptionService {
	static let shared = CloudKitSubscriptionService()

	private static let recordType = "Couple"
	private static let subscriptionIDPrefix = "couple-"

	private let container: CKContainer
	private let database: CKDatabase
	private let defaults = UserDefaults.standard

	init(containerIdentifier: String = CloudKitSyncService.containerID) {
		container = CKContainer(identifier: containerIdentifier)
		database = container.publicCloudDatabase
	}

	/// Call when paired with a code to subscribe to record changes; call with nil when unlinked to remove the subscription.
	func setupSubscription(inviteCode: String?) {
		guard let code = inviteCode, !code.isEmpty else {
			removeStoredSubscription()
			return
		}
		let normalized = InviteCodeGenerator.normalize(code)
		guard !normalized.isEmpty else { return }
		let recordName = normalized.replacingOccurrences(of: "-", with: "")
		guard !recordName.isEmpty else { return }
		let subscriptionID = Self.subscriptionIDPrefix + recordName

		Task {
			do {
				try await database.deleteSubscription(withID: subscriptionID)
			} catch let ckError as CKError where ckError.code == .unknownItem {
				// No existing subscription
			} catch {
				#if DEBUG
				print("[CloudKitSubscription] delete existing failed: \(error)")
				#endif
			}
			let predicate = NSPredicate(format: "inviteCode == %@", normalized)
			let subscription = CKQuerySubscription(recordType: Self.recordType, predicate: predicate, options: [.firesOnRecordUpdate])
			subscription.subscriptionID = subscriptionID
			let info = CKSubscription.NotificationInfo()
			info.shouldSendContentAvailable = true
			subscription.notificationInfo = info
			do {
				try await database.save(subscription)
				defaults.set(subscriptionID, forKey: subscriptionIDUserDefaultsKey)
			} catch {
				#if DEBUG
				print("[CloudKitSubscription] save failed: \(error)")
				#endif
			}
		}
	}

	private func removeStoredSubscription() {
		guard let subscriptionID = defaults.string(forKey: subscriptionIDUserDefaultsKey) else { return }
		defaults.removeObject(forKey: subscriptionIDUserDefaultsKey)
		Task {
			do {
				try await database.deleteSubscription(withID: subscriptionID)
			} catch let ckError as CKError where ckError.code == .unknownItem {
				// Already gone
			} catch {
				#if DEBUG
				print("[CloudKitSubscription] remove failed: \(error)")
				#endif
			}
		}
	}
}
