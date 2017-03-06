import Foundation

extension String {
    var utf8Data: Data? {
        return data(using: .utf8)
    }
	
	var isBlank: Bool {
		let trimmed = self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
		return trimmed.isEmpty
	}
	
	/// Base64 decoding a string.
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
