import Foundation
import CoreData

public final class PartnershipEntity: ManagedObject {
	@NSManaged private(set) public var partnershipID: Int64
	@NSManaged private(set) public var name: String
	
	public static func insert(into context: NSManagedObjectContext, object: Partnership) -> PartnershipEntity {
		
		let partnershipEntity: PartnershipEntity = context.insertObject()
		
		if let partnershipID = object.partnershipID {
			partnershipEntity.partnershipID = Int64(partnershipID)
		}
		
		if let name = object.name {
			partnershipEntity.name = name
		}
		
		return partnershipEntity
	}
}

// MARK: - ManagedObjectType
extension PartnershipEntity: ManagedObjectType {
	public static var entityName: String {
		return "PartnershipEntity"
	}
}
