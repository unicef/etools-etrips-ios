import Foundation
import ObjectMapper

public class TravelItinerary: Mappable {
	var itineraryID: Int?
	var origin: String?
	var destination: String?
	var departureDateString: String?
	var arrivalDateString: String?
	var modeOfTravel: String?
	
	var departureDate: Date? {
		guard var dateString = departureDateString else {
			return nil
		}
		if dateString.contains(".") {
			dateString = dateString.substring(to: dateString.range(of: ".")!.lowerBound)
			dateString.append("Z")
		}
		return DateFormatter.iso8601DateFormatter.date(from: dateString)
	}

	var arrivalDate: Date? {
		guard var dateString = arrivalDateString else {
			return nil
		}
		if dateString.contains(".") {
			dateString = dateString.substring(to: dateString.range(of: ".")!.lowerBound)
			dateString.append("Z")
		}
		return DateFormatter.iso8601DateFormatter.date(from: dateString)
	}

	public required init?(map: Map) {

	}

	public func mapping(map: Map) {
		origin <- map["origin"]
		destination <- map["destination"]
		departureDateString <- map["departure_date"]
		arrivalDateString <- map["arrival_date"]
		modeOfTravel <- map["mode_of_travel"]
	}
}
