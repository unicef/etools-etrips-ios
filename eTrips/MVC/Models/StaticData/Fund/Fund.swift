import Foundation
import ObjectMapper

public class Fund: Mappable {
	var fundID: Int?
	var name: String?

	public required init?(map: Map) {

	}

	public func mapping(map: Map) {
		fundID <- map["id"]
		name <- map["name"]
	}
}
