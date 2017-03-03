import Foundation
import ObjectMapper

public class Trip: Mappable {
	var tripID: Int?
	var referenceNumber: String?
	var supervisorID: Int?
	var status: String?
	var purposeOfTravel: String?
	var supervisorName: String?
	var createdDateString: String?
	var startDateString: String?
	var endDateString: String?
	var travelerName: String?
	var rejectionNote: String?
	var report: String?
	var files: [File]?
	var costSummary: CostSummary?
	var costAssignments: [CostAssignment]?
	var travelItinerary: [TravelItinerary]?
	var actionPoints: [ActionPoint]?
	var travelActivities: [TravelActivity]?
	var currencyID: Int?

	var startDate: Date? {
		guard var dateString = startDateString else {
			return nil
		}
		if dateString.contains(".") {
			dateString = dateString.substring(to: dateString.range(of: ".")!.lowerBound)
			dateString.append("Z")
		}
		return DateFormatter.iso8601DateFormatter.date(from: dateString)
	}

	var endDate: Date? {
		guard var dateString = endDateString else {
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
		tripID <- map["id"]
		referenceNumber <- map["reference_number"]
		supervisorID <- map["supervisor"]
		status <- map["status"]
		purposeOfTravel <- map["purpose"]
		createdDateString <- map["created_date"]
		startDateString <- map["start_date"]
		endDateString <- map["end_date"]
		supervisorName <- map["supervisor_name"]
		travelerName <- map["traveler"]
		report <- map["report"]
		files <- map["attachments"]
		costSummary <- map["cost_summary"]
		costAssignments <- map["cost_assignments"]
		travelItinerary <- map["itinerary"]
		actionPoints <- map["action_points"]
		travelActivities <- map["activities"]
		rejectionNote <- map["rejection_note"]
		currencyID <- map["currency"]
	}
}
