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
						if let json = try response.mapJSON() as? NSDictionary {
							if let token = json["token"] as? String {
								UserManager.shared.token = token
								completion(true, nil)
							}
						} else {
							completion(false, nil)
						}
					} catch {
						completion(false, nil)
					}
				default:
					do {
						if let json = try response.mapJSON() as? NSDictionary {
							if let messages = json.allValues.first as? [String] {
								completion(false, NetworkError(title: "Error", detail: messages.first))
							} else {
								completion(false, nil)
							}
						} else {
							completion(false, nil)
						}
					} catch {
						completion(false, nil)
					}
				}
				
			case let .failure(error):
				switch error {
				case .underlying(let nsError as NSError?):
					completion(false, NetworkError(title: "Error", detail: nsError?.localizedDescription))
				default:
					completion(false, nil)
				}
			}
			
		}
	}
}
