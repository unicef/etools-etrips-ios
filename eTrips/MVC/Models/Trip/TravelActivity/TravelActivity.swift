import Foundation
import ObjectMapper

public class TravelActivity: Mappable {
	var activityID: Int?
	var travelType: String?
	var partnerID: Int?
	var partnershipID: Int?
	var isPrimaryTraveler: Bool?

	public required init?(map: Map) {

	}

	public func mapping(map: Map) {
		activityID <- map["id"]
		travelType <- map["travel_type"]
		partnerID <- map["partner"]
		partnershipID <- map["partnership"]
		isPrimaryTraveler <- map["is_primary_traveler"]
	}
}
