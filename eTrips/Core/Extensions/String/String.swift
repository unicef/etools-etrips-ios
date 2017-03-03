import Foundation

extension String {
    var utf8Data: Data? {
        return data(using: .utf8)
    }
	
	var isBlank: Bool {
		let trimmed = self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
		return trimmed.isEmpty
	}
}
