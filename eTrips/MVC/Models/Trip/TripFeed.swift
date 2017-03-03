import Foundation
import ObjectMapper

public class TripFeed: Mappable {
	var pageCount: Int?
	var trips: [Trip]?
	var totalCount: Int?

	public required init?(map: Map) {

	}

	public func mapping(map: Map) {
		pageCount <- map["page_count"]
		trips <- map["data"]
		totalCount <- map["total_count"]
	}
}
