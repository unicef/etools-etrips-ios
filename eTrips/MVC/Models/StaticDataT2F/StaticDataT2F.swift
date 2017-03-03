import Foundation
import ObjectMapper

public class StaticDataT2F: Mappable {
	var partners: [Partner]?
	var partnerships: [Partnership]?

	public required init?(map: Map) {

	}

	public func mapping(map: Map) {
		partners <- map["partners"]
		partnerships <- map["partnerships"]
	}
}
