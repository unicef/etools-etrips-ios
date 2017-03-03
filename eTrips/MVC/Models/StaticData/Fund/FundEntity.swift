import Foundation
import CoreData

public final class FundEntity: ManagedObject {
	@NSManaged private(set) public var fundID: Int64
	@NSManaged private(set) public var name: String
	
	public static func insert(into context: NSManagedObjectContext, object: Fund) -> FundEntity {
		
		let fundEntity: FundEntity = context.insertObject()
		
		if let fundID = object.fundID {
			fundEntity.fundID = Int64(fundID)
		}
		
		if let name = object.name {
			fundEntity.name = name
		}
		
		return fundEntity
	}
}

// MARK: - ManagedObjectType
extension FundEntity: ManagedObjectType {
	public static var entityName: String {
		return "FundEntity"
	}
}
