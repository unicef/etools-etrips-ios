import Foundation
import CoreData

public final class ManagedObjectObserver {
	
	public enum ChangeType {
		case delete
		case update
	}
	
	private var token: NSObjectProtocol!
	private var objectHasBeenDeleted: Bool = false
	
	public init?(object: ManagedObjectType, changeHandler: @escaping (ChangeType) -> Void) {
		guard let moc = object.managedObjectContext else {
			return nil
		}
		
		objectHasBeenDeleted = type(of: object).defaultPredicate.evaluate(with: object)
		
		token = moc.addObjectsDidChangeNotificationObserver(handler: { [unowned self] notification in
			guard let changeType = self.changeType(of: object, in: notification) else { return }
			self.objectHasBeenDeleted = changeType == .delete
			changeHandler(changeType)
		})
	}
	
	deinit {
		NotificationCenter.default.removeObserver(token)
	}
	
	private func changeType(of object: ManagedObjectType,
	                        in notification: ObjectsDidChangeNotification) -> ChangeType? {
		
		let deleted = notification.deletedObjects.union(notification.invalidatedObjects)
		
		if notification.invalidatedAllObjects || deleted.containsObjectIdenticalTo(object) {
			return .delete
		}
		
		let updated = notification.updatedObjects.union(notification.refreshedObjects)
		
		if updated.containsObjectIdenticalTo(object) {
			let predicate = type(of: object).defaultPredicate
			
			if predicate.evaluate(with: object) {
				return .update
			} else if !objectHasBeenDeleted {
				return .delete
			}
		}
		return nil
	}
}
