import Foundation
import ObjectMapper

public class Currency: Mappable {
	var currencyID: Int?
	var name: String?
	var code: String?
	var iso4127: String?
	var exchangeToDollar: Double?
	
	public required init?(map: Map) {

	}

	public func mapping(map: Map) {
		currencyID <- map["id"]
		name <- map["name"]
		code <- map["code"]
		iso4127 <- map["iso_4217"]
		exchangeToDollar <- map["exchange_to_dollar"]
	}
}
