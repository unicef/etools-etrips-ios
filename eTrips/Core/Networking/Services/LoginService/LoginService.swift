import Foundation

typealias LoginServiceCompletionHandler = (Bool, NetworkError?) -> Void

// Class responsible for user login request to the REST API and saving authorization token.
class LoginService {
	func login(_ username: String, _ password: String,
	           completion: @escaping LoginServiceCompletionHandler) {
		
		eTripsAPIProvider.request(.login(username: username, password: password)) { result in
			
			switch result {
			case let .success(response):
				let statusCode = response.statusCode
				
				switch statusCode {
				case 200...299:
					do {
						guard let json = try response.mapJSON() as? NSDictionary else {
							completion(false, nil)
							return
						}
						
						guard let token = json["token"] as? String else {
							completion(false, nil)
							return
						}
						UserManager.shared.token = token
						completion(true, nil)
					} catch {
						completion(false, nil)
					}
				default:
					do {
						guard let json = try response.mapJSON() as? NSDictionary else {
							completion(false, nil)
							return
						}
						
						guard let messages = json.allValues.first as? [String] else {
							completion(false, nil)
							return
						}
						
						completion(false, NetworkError(title: "Error", detail: messages.first))
					} catch {
						completion(false, nil)
					}
				}
				
			case let .failure(error):
				switch error {
				case .underlying(let nsError):
					completion(false, NetworkError(title: "Error", detail: nsError.localizedDescription))
				default:
					completion(false, nil)
				}
			}
			
		}
	}
}
