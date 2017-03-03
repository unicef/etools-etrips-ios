import Foundation
import CoreData

/// Wrapper around `NSManagedObjectContextObjectsDidChange` notification.
public struct ObjectsDidChangeNotification {
	private let notification: Notification
	
	init(notif: Notification) {
		assert(notif.name == Notification.Name.NSManagedObjectContextObjectsDidChange)
		notification = notif
	}
	
	public var insertedObjects: Set<ManagedObject> {
		return objects(for: NSInsertedObjectsKey)
	}
	
	public var updatedObjects: Set<ManagedObject> {
		return objects(for: NSUpdatedObjectsKey)
	}
	
	public var deletedObjects: Set<ManagedObject> {
		return objects(for: NSDeletedObjectsKey)
	}
	
	public var refreshedObjects: Set<ManagedObject> {
		return objects(for: NSRefreshedObjectsKey)
	}
	
	public var invalidatedObjects: Set<ManagedObject> {
		return objects(for: NSInvalidatedObjectsKey)
	}
	
	public var invalidatedAllObjects: Bool {
		return notification.userInfo?[NSInvalidatedAllObjectsKey] != nil
	}
	
	private func objects(for key: String) -> Set<ManagedObject> {
		return (notification.userInfo?[key] as? Set<ManagedObject>) ?? Set()
	}
}

extension NSManagedObjectContext {
	public func addObjectsDidChangeNotificationObserver(
		handler: @escaping (ObjectsDidChangeNotification) -> Void) -> NSObjectProtocol {
		
		let notificationCenter = NotificationCenter.default
		
		return notificationCenter.addObserver(
			forName: Notification.Name.NSManagedObjectContextObjectsDidChange,
			object: self,
			queue: nil,
			using: { notification in
				let wrappedNotificaton = ObjectsDidChangeNotification(notif: notification)
				return handler(wrappedNotificaton)
			}
		)
		
	}
}
