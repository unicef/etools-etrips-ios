import Foundation
import ObjectMapper

public class StaticData: Mappable {
	var wbs: [WBS]?
	var grants: [Grant]?
	var funds: [Fund]?
	var currencies: [Currency]?

	public required init?(map: Map) {

	}

	public func mapping(map: Map) {
		wbs <- map["wbs"]
		grants <- map["grants"]
		funds <- map["funds"]
		currencies <- map["currencies"]
	}
}
