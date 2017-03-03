import Foundation
import ObjectMapper

public class CostSummary: Mappable {
	var dsaTotal: String?
	var expensesTotal: String?
	var deductionsTotal: String?

	public required init?(map: Map) {

	}

	public func mapping(map: Map) {
		dsaTotal <- map["dsa_total"]
		expensesTotal <- map["expenses_total"]
		deductionsTotal <- map["deductions_total"]
	}
}
