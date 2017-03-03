import Foundation
import ObjectMapper

public class Partner: Mappable {
	var partnerID: Int?
	var name: String?

	public required init?(map: Map) {

	}

	public func mapping(map: Map) {
		partnerID <- map["id"]
		name <- map["name"]
	}
}
