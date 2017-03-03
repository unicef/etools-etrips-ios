import Foundation
import ObjectMapper

public class ActionPointFeed: Mappable {
    var pageCount: Int?
    var actionPoints: [ActionPoint]?
    var totalCount: Int?
    
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        pageCount <- map["page_count"]
        actionPoints <- map["data"]
        totalCount <- map["total_count"]
    }
}
