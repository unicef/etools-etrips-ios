import Foundation
import ObjectMapper

public class Grant: Mappable {
	var grantID: Int?
	var name: String?

	public required init?(map: Map) {

	}

	public func mapping(map: Map) {
		grantID <- map["id"]
		name <- map["name"]
	}
}
