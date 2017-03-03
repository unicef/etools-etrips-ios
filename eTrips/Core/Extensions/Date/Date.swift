import Foundation

extension Date {

	func mediumDateStyleString() -> String {
		return DateFormatter.mediumDateStyleDateFormatter.string(from: self)
	}

	func timestamp() -> Int {
		return Int(self.timeIntervalSince1970)
	}
    
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
    
        var isGreater = false
        
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        return isGreater
    }
    
    func isLessThanDate(_ dateToCompare: Date) -> Bool {
        var isLess = false
        
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        return isLess
    }
    
    func equalToDate(_ dateToCompare: Date) -> Bool {

        var isEqualTo = false
        
        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        return isEqualTo
    }

    func isToday() -> Bool {
        
        let order = (Calendar.current as NSCalendar).compare(self, to: Date(), toUnitGranularity: .day)
        switch order {
        case .orderedSame:
            return true
            
        default:
            return false
        }
    }
}
