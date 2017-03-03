import Foundation
import CoreData

public final class TravelActivityEntity: ManagedObject {
	@NSManaged private(set) public var activityID: Int64
	@NSManaged private(set) public var travelType: String
	@NSManaged private(set) public var partnerID: Int64
	@NSManaged private(set) public var partnershipID: Int64
	@NSManaged private(set) public var isPrimaryTraveler: Bool
	
	@NSManaged private(set) public var trip: TripEntity
	
	public static func insert(into context: NSManagedObjectContext, object: TravelActivity) -> TravelActivityEntity {
		let travelActivityEntity: TravelActivityEntity = context.insertObject()
		
		if let activityID = object.activityID {
			travelActivityEntity.activityID = Int64(activityID)
		}
		
		if let travelType = object.travelType {
			travelActivityEntity.travelType = travelType
		}
		
		if let partnerID = object.partnerID {
			travelActivityEntity.partnerID = Int64(partnerID)
		}
		
		if let partnershipID = object.partnershipID {
			travelActivityEntity.partnershipID = Int64(partnershipID)
		}
		
		if let isPrimaryTraveler = object.isPrimaryTraveler {
			travelActivityEntity.isPrimaryTraveler = isPrimaryTraveler
		}
		
		return travelActivityEntity
	}
}

extension TravelActivityEntity: ManagedObjectType {
	public static var entityName: String {
		return "TravelActivityEntity"
	}
}
