import Foundation
import CoreData

public final class TravelItineraryEntity: ManagedObject {
	@NSManaged private(set) public var origin: String
	@NSManaged private(set) public var destination: String
	@NSManaged private(set) public var depart: Date
	@NSManaged private(set) public var arrive: Date
	@NSManaged private(set) public var modeOfTravel: String
	
	@NSManaged private(set) public var trip: TripEntity
	
	public static func insert(into context: NSManagedObjectContext, object: TravelItinerary) -> TravelItineraryEntity {
		let travelItinerary: TravelItineraryEntity = context.insertObject()
		
		if let origin = object.origin {
			travelItinerary.origin = origin
		}
		
		if let destination = object.destination {
			travelItinerary.destination = destination
		}
		
		if let depart = object.departureDate {
			travelItinerary.depart = depart
		}
		
		if let arrive = object.arrivalDate {
			travelItinerary.arrive = arrive
		}

		if let modeOfTravel = object.modeOfTravel {
			travelItinerary.modeOfTravel = modeOfTravel
		}
		
		return travelItinerary
	}
}

extension TravelItineraryEntity: ManagedObjectType {
	public static var entityName: String {
		return "TravelItineraryEntity"
	}
}
