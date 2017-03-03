import Foundation
import ObjectMapper

public class ActionPoint: Mappable {
    var pointID: Int
    var personResponsibleID: Int
	var personResponsibleName: String?
    var assignedByPersonID: Int
	var assignedByName: String

    var actionPointNumber: String
    var tripReferenceNumber: String
    
    var pointDescription: String
    var comments: String?
    var status: String
    var actionsTaken: String?
    
    var createdAtString: String?
    var completedAtString: String?
    var dueDateString: String?

    var followUp: Bool
    var tripID: Int
    
    var createdAtDate: Date? {
        return getDateFromDateString(dateString: createdAtString)
    }
    
    var completedAtDate: Date? {
        return getDateFromDateString(dateString: completedAtString)
    }
    
    var dueDate: Date? {
        return getDateFromDateString(dateString: dueDateString)
    }
    
    public required init?(map: Map) {
        pointID = 0
        personResponsibleID = 0
        assignedByPersonID = 0
        actionPointNumber = ""
        tripReferenceNumber = ""
        pointDescription = ""
		personResponsibleName = ""
        status = ""
        followUp = false
        tripID = 0
		assignedByName = ""
    }
    
    public func mapping(map: Map) {
        pointID <- map["id"]
        personResponsibleID <- map["person_responsible"]
		personResponsibleName <- map["person_responsible_name"]
        assignedByPersonID <- map["assigned_by"]
        actionPointNumber <- map["action_point_number"]
        tripReferenceNumber <- map["trip_reference_number"]
        pointDescription <- map["description"]
        comments <- map["comments"]
        status <- map["status"]
        actionsTaken <- map["actions_taken"]
        createdAtString <- map["created_at"]
        completedAtString <- map["completed_at"]
        dueDateString <- map["due_date"]
        followUp <- map["follow_up"]
        tripID <- map["trip_id"]
		assignedByName <- map["assigned_by_name"]
    }
    
    private func getDateFromDateString(dateString: String?) -> Date? {
        guard var s = dateString else {
            return nil
        }
        
        if s.contains(".") {
            s = s.substring(to: s.range(of: ".")!.lowerBound)
            s.append("Z")
        }
        return DateFormatter.iso8601DateFormatter.date(from: s)
    }
}
