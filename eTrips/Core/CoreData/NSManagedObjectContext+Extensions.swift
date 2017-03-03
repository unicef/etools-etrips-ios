import Foundation
import CoreData

extension NSManagedObjectContext {
	public func insertObject<A: ManagedObject>() -> A where A: ManagedObjectType {
		guard let object = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else {
			fatalError("Wrong object type")
		}
		return object
	}
	
	public func saveOrRollback() -> Bool {
		do {
			try save()
			return true
		} catch {
			rollback()
			return false
		}
	}
	
	public func performSaveOrRollback() {
        perform {
            _ = self.saveOrRollback()
        }
    }
	
	public func performChanges(block: @escaping () -> Void) {
		perform {
			block()
			_ = self.saveOrRollback()
		}
	}
}

private let SingleObjectCacheKey = "SingleObjectCache"
private typealias SingleObjectCache = [String: NSManagedObject]

extension NSManagedObjectContext {
	public func set(object: NSManagedObject?, forSingleObjectCacheKey key: String) {
		var cache = userInfo[SingleObjectCacheKey] as? SingleObjectCache ?? [:]
		cache[key] = object
		userInfo[SingleObjectCacheKey] = cache
	}
	
	public func object(for key: String) -> NSManagedObject? {
		guard let cache = userInfo[SingleObjectCacheKey] as? [String: NSManagedObject] else { return nil }
		return cache[key]
	}
}
