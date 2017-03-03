import Foundation
import CoreData

public final class GrantEntity: ManagedObject {
	@NSManaged private(set) public var grantID: Int64
	@NSManaged private(set) public var name: String

	public static func insert(into context: NSManagedObjectContext, object: Grant) -> GrantEntity {
		
		let grantEntity: GrantEntity = context.insertObject()
		
		if let grantID = object.grantID {
			grantEntity.grantID = Int64(grantID)
		}
		
		if let name = object.name {
			grantEntity.name = name
		}
		return grantEntity
	}
}

// MARK: - ManagedObjectType
extension GrantEntity: ManagedObjectType {
	public static var entityName: String {
		return "GrantEntity"
	}
}
