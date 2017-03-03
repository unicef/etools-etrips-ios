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
		
		travelItinerary.origin = object.origin!
		travelItinerary.destination = object.destination!
		travelItinerary.depart = object.departureDate!
		travelItinerary.arrive = object.arrivalDate!
		travelItinerary.modeOfTravel = object.modeOfTravel!
		
		return travelItinerary
	}
}

extension TravelItineraryEntity: ManagedObjectType {
	public static var entityName: String {
		return "TravelItineraryEntity"
	}
}
