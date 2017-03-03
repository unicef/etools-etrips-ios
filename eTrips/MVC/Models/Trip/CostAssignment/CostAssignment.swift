import Foundation
import ObjectMapper

public class CostAssignment: Mappable {
	var costAssignmentID: Int?
	var wbsID: Int?
	var share: Int?
	var grantID: Int?
	var fundID: Int?
	
	public required init?(map: Map) {

	}

	public func mapping(map: Map) {
		costAssignmentID <- map["id"]
		wbsID <- map["wbs"]
		share <- map["share"]
		grantID <- map["grant"]
		fundID <- map["fund"]
	}
}
