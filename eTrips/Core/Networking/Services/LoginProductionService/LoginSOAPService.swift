import Foundation

typealias LoginSOAPServiceCompletionHandler = (Bool, NetworkError?) -> Void

class LoginSOAPService {
	let adfsEndpoint = "https://login.unicef.org/adfs/services/trust/13/UsernameMixed"
	let resourceEndpoint = "https://etools.unicef.org/API"
	
	func login(_ username: String, _ password: String,
	           completion: @escaping LoginSOAPServiceCompletionHandler) {
		
		let request = NSMutableURLRequest(url: URL(string: adfsEndpoint)!)
		let session = URLSession.shared
		
		request.httpMethod = "POST"
		request.httpBody = soapBody(username: username, password: password).data(using: String.Encoding.utf8)
		request.addValue("application/soap+xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
		
		let task = session.dataTask(with: request as URLRequest) { data, response, error in
			guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
				DispatchQueue.main.async {
					completion(false, NetworkError(title: "Error", detail: "Network Error"))
				}
				return
			}
			
			guard error == nil else {
				DispatchQueue.main.async {
					completion(false, NetworkError(title: "Error", detail: error.debugDescription))
				}
				return
			}
			
			guard data != nil else {
				DispatchQueue.main.async {
					completion(false, NetworkError(title: "Error", detail: "No Data."))
				}
				return
			}
			
			guard let input =
				String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) else {
				completion(false, nil)
				return
			}
			UserManager.shared.token = self.parsedToken(input)
			
			DispatchQueue.main.async {
				completion(true, nil)
			}
		}
		task.resume()
	}
	
	func soapBody(username: String, password: String) -> String {
		return "<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:a=\"http://www.w3.org/2005/08/addressing\" xmlns:u=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\"><s:Header><a:Action s:mustUnderstand=\"1\">http://docs.oasis-open.org/ws-sx/ws-trust/200512/RST/Issue</a:Action><a:To s:mustUnderstand=\"1\">\(adfsEndpoint)</a:To><o:Security s:mustUnderstand=\"1\" xmlns:o=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\"><o:UsernameToken u:Id=\"uuid-6a13a244-dac6-42c1-84c5-cbb345b0c4c4-1\"><o:Username>\(username)</o:Username><o:Password Type=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText\">\(password)</o:Password></o:UsernameToken></o:Security></s:Header><s:Body><trust:RequestSecurityToken xmlns:trust=\"http://docs.oasis-open.org/ws-sx/ws-trust/200512\"><wsp:AppliesTo xmlns:wsp=\"http://schemas.xmlsoap.org/ws/2004/09/policy\"><a:EndpointReference><a:Address>\(resourceEndpoint)</a:Address></a:EndpointReference></wsp:AppliesTo><trust:KeyType>http://docs.oasis-open.org/ws-sx/ws-trust/200512/Bearer</trust:KeyType><trust:RequestType>http://docs.oasis-open.org/ws-sx/ws-trust/200512/Issue</trust:RequestType></trust:RequestSecurityToken></s:Body></s:Envelope>"
	}
	
	// MARK: - Helpers
	func parsedToken(_ input: String) -> String? {
		guard let binarySecurityTokenTagIndex =
			input.range(of: "BinarySecurityToken")?.lowerBound else {
			return nil
		}
		
		let binarySecurityTokenSubstring = input.substring(from: binarySecurityTokenTagIndex)
		
		guard let binarySecurityTokenClosingBracketIndex =
			binarySecurityTokenSubstring.range(of: ">")?.lowerBound else {
			return nil
		}
		
		let encodedTokenWithBracketsSubstring =
			binarySecurityTokenSubstring.substring(from: binarySecurityTokenClosingBracketIndex)
		
		guard let binarySecurityTokenClosingTagOpeningBracketIndex =
			encodedTokenWithBracketsSubstring.range(of: "<")?.lowerBound else {
			return nil
		}
		
		let range = Range(uncheckedBounds:
			(encodedTokenWithBracketsSubstring.index(after: encodedTokenWithBracketsSubstring.startIndex),
			 binarySecurityTokenClosingTagOpeningBracketIndex))
		
		let encodedTokenSubstring = encodedTokenWithBracketsSubstring.substring(with: range)
		return urlBase64Decode(encodedTokenSubstring)
	}
	
	func urlBase64Decode(_ input: String) -> String? {
		
		var output = input.replacingOccurrences(of: "-", with: "+")
		output = output.replacingOccurrences(of: "_", with: "/")
		switch output.characters.count % 4 {
		case 0:
			break
		case 2:
			output += "=="
			break
		case 3:
			output += "="
			break
		default:
			return nil
		}
		return output.base64Decoded()
	}
}
