import Foundation
import ObjectMapper

public class Profile: Mappable {
	var profileID: Int?
	var firstName: String?
	var lastName: String?
	var country: String?
	var username: String?
	var office: String?
	var jobTitle: String?
    var businessArea: Int?

	public required init?(map: Map) {

	}

	public func mapping(map: Map) {
		profileID <- map["id"]
		firstName <- map["first_name"]
		lastName <- map["last_name"]
		country <- map["profile.country_name"]
		username <- map["username"]
		office <- map["profile.office"]
		jobTitle <- map["profile.job_title"]
        businessArea <- map["t2f.business_area"]
	}
}
