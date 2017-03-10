import Foundation
import Alamofire

class DefaultAlamofireManager: Alamofire.SessionManager {
    static let shared: DefaultAlamofireManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 120
        configuration.timeoutIntervalForResource = 120
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return DefaultAlamofireManager(configuration: configuration)
    }()    
}
