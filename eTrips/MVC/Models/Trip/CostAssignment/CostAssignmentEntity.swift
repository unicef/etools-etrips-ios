import Foundation
import CoreData

public final class CostAssignmentEntity: ManagedObject {
	@NSManaged private(set) public var costAssignmentID: Int64
	@NSManaged private(set) public var wbsID: Int64
	@NSManaged private(set) public var share: Int64
	@NSManaged private(set) public var grantID: Int64
	@NSManaged private(set) public var fundID: Int64
	@NSManaged private(set) public var trip: TripEntity
	
	public static func insert(into context: NSManagedObjectContext, object: CostAssignment) -> CostAssignmentEntity {
		
		let costAssignmentEntity: CostAssignmentEntity = context.insertObject()
		
		// ID.
		if let costAssignmentID = object.costAssignmentID {
			costAssignmentEntity.costAssignmentID = Int64(costAssignmentID)
		}
		
		// WBS.
		if let wbsID = object.wbsID {
			costAssignmentEntity.wbsID = Int64(wbsID)
		}
		
		// Share.
		if let share = object.share {
			costAssignmentEntity.share = Int64(share)
		}
		
		// Grant.
		if let grantID = object.grantID {
			costAssignmentEntity.grantID = Int64(grantID)
		}

		// Fund.
		if let fundID = object.fundID {
			costAssignmentEntity.fundID = Int64(fundID)
		}
		
		return costAssignmentEntity
	}
}

// MARK: - ManagedObjectType
extension CostAssignmentEntity: ManagedObjectType {
	public static var entityName: String {
		return "CostAssignmentEntity"
	}
}
