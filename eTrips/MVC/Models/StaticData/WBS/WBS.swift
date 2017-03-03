import Foundation
import ObjectMapper

public class WBS: Mappable {
	var wbsID: Int?
	var name: String?

	public required init?(map: Map) {

	}

	public func mapping(map: Map) {
		wbsID <- map["id"]
		name <- map["name"]
	}
}
