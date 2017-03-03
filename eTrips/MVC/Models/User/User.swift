import Foundation
import ObjectMapper

public class User: Mappable {
	var userID: Int?
	var fullName: String?
	var username: String?
	var email: String?

	public required init?(map: Map) {

	}

	public func mapping(map: Map) {
		userID <- (map["user_id"], TransformOf<Int, String>(fromJSON: { $0 == nil ? nil : Int($0!) },
		                                                   toJSON: { $0.map { String($0) } }))
		fullName <- map["full_name"]
		username <- map["username"]
		email <- map["email"]
	}
}
