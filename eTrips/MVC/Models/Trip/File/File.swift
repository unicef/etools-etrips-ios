import Foundation
import ObjectMapper

public class File: Mappable {
	var fileID: Int?
	var fileURL: String?
	var caption: String?

	public required init?(map: Map) {

	}

	public func mapping(map: Map) {
		fileID <- map["id"]
		fileURL <- map["file"]
		caption <- map["name"]
	}
}
