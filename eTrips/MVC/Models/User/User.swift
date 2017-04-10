import Foundation
import ObjectMapper

public class User: Mappable {
  var userID: Int?
  var firstName: String?
  var lastName: String?
  var name: String?

  public required init?(map: Map) {
  }

  public func mapping(map: Map) {
    userID <- map["id"]
    firstName <- map["first_name"]
    lastName <- map["last_name"]
    name <- map["name"]
  }
}
