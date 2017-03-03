import Foundation
import CoreData

public final class WBSEntity: ManagedObject {
	@NSManaged private(set) public var wbsID: Int64
	@NSManaged private(set) public var name: String
	
	public static func insert(into context: NSManagedObjectContext, object: WBS) -> WBSEntity {
		
		let wbsEntity: WBSEntity = context.insertObject()
		
		if let wbsID = object.wbsID {
			wbsEntity.wbsID = Int64(wbsID)
		}
		
		if let name = object.name {
			wbsEntity.name = name
		}
		
		return wbsEntity
	}
}

// MARK: - ManagedObjectType
extension WBSEntity: ManagedObjectType {
	public static var entityName: String {
		return "WBSEntity"
	}
}
