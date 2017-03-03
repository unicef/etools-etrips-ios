import Foundation

public class NetworkError: Error {
	public let title: String
	public let detail: String?
	
	init(title: String, detail: String?) {
		self.title = title
		self.detail = detail
	}
}
