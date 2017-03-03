import Foundation
import Alamofire

class NetworkConnection {
	private let manager = NetworkReachabilityManager(host: "www.apple.com")
	func isNetworkReachable() -> Bool {
		return manager?.isReachable ?? false
	}
}
