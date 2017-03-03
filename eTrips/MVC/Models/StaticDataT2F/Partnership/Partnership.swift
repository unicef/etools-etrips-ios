import Foundation
import ObjectMapper

public class Partnership: Mappable {
	var partnershipID: Int?
	var name: String?

	public required init?(map: Map) {

	}

	public func mapping(map: Map) {
		partnershipID <- map["id"]
		name <- map["name"]
	}
}
