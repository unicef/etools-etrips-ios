import Foundation
import CoreData

public final class PartnerEntity: ManagedObject {
	@NSManaged private(set) public var partnerID: Int64
	@NSManaged private(set) public var name: String
	
	public static func insert(into context: NSManagedObjectContext, object: Partner) -> PartnerEntity {
		
		let partnerEntity: PartnerEntity = context.insertObject()
		
		if let partnerID = object.partnerID {
			partnerEntity.partnerID = Int64(partnerID)
		}
		
		if let name = object.name {
			partnerEntity.name = name
		}
		
		return partnerEntity
	}
}

// MARK: - ManagedObjectType
extension PartnerEntity: ManagedObjectType {
	public static var entityName: String {
		return "PartnerEntity"
	}
}
