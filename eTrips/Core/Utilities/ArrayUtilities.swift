import Foundation

extension Array {
    
    mutating func shuffle() {
        for _ in 0..<count {
            sort { (_, _) in arc4random() < arc4random() }
        }
    }
    
    var mapToAny: [Any] { return self.map { $0 as Any } }
    
    func mapWithCast<T>() -> [T] {
        return self.map { $0 as! T }
    }
}

extension Array {
    func find(_ includedElement: (Element) -> Bool) -> Int? {
        for (idx, element) in enumerated() {
            if includedElement(element) {
                return idx
            }
        }
        return nil
    }
}
