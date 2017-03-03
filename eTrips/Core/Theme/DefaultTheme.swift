import Foundation
import UIKit

class DefaultTheme {
	/// Colors System.
	fileprivate var darkBlueGreyColor: UIColor {
		return UIColor(colorLiteralRed: 35.0 / 255.0,
		               green: 57.0 / 255.0,
		               blue: 68.0 / 255.0,
		               alpha: 1.0)
	}
	
	fileprivate var azureColor: UIColor {
		return UIColor(colorLiteralRed: 0.0 / 255.0,
		               green: 153.0 / 255.0,
		               blue: 255.0 / 255.0,
		               alpha: 1.0)
	}
	
	fileprivate var lightYellowColor: UIColor {
		return UIColor(colorLiteralRed: 252.0 / 255.0,
		               green: 243.0 / 255.0,
		               blue: 154.0 / 255.0,
		               alpha: 1.0)
	}
	
	fileprivate var darkYellowColor: UIColor {
		return UIColor(colorLiteralRed: 220.0 / 255.0,
		               green: 208.0 / 255.0,
		               blue: 81.0 / 255.0,
		               alpha: 1.0)
	}
	
	fileprivate var lightBlueColor: UIColor {
		return UIColor(colorLiteralRed: 140.0 / 255.0,
		               green: 190.0 / 255.0,
		               blue: 221.0 / 255.0,
		               alpha: 1.0)
	}
	
	fileprivate var lightGreenColor: UIColor {
		return UIColor(colorLiteralRed: 192.0 / 255.0,
		               green: 228.0 / 255.0,
		               blue: 132.0 / 255.0,
		               alpha: 1.0)
	}
	
	fileprivate var redColor: UIColor {
		return UIColor(colorLiteralRed: 222.0 / 255.0,
		               green: 38.0 / 255.0,
		               blue: 24.0 / 255.0,
		               alpha: 1.0)
	}
	
	fileprivate var warmGreyColor: UIColor {
		return UIColor(colorLiteralRed: 132.0 / 255.0,
		               green: 132.0 / 255.0,
		               blue: 132.0 / 255.0,
		               alpha: 1.0)
	}
	
	fileprivate var darkGreenColor: UIColor {
		return UIColor(colorLiteralRed: 104.0 / 255.0,
		               green: 186.0 / 255.0,
		               blue: 0.0 / 255.0,
		               alpha: 1.0)
	}
}

// MARK: - Theme
extension DefaultTheme: Theme {
	
	var signInButtonBorderColor: UIColor {
		return darkBlueGreyColor
	}
	
	var navigationBarTintColor: UIColor {
		return azureColor
	}
	
	var buttonTintColor: UIColor {
		return azureColor
	}
	
	/// Trips Colors.
	var plannedTripColor: UIColor {
		return lightYellowColor
	}
	
	var submittedTripColor: UIColor {
		return darkYellowColor
	}
	
	var approvedTripColor: UIColor {
		return lightGreenColor
	}
	
	var rejectedTripColor: UIColor {
		return redColor
	}
	
	var canceledTripColor: UIColor {
		return warmGreyColor
	}
	
	var sentForPaymentTripColor: UIColor {
		return lightBlueColor
	}
	
	var completedTripColor: UIColor {
		return darkGreenColor
	}
	
	var certifiedTripColor: UIColor {
		return lightBlueColor
	}
	
	var certificationSubmittedTripColor: UIColor {
		return darkYellowColor
	}
	
	var certificationRejectedTripColor: UIColor {
		return redColor
	}
	
	var certificationApprovedTripColor: UIColor {
		return lightGreenColor
	}
	
	/// Action Points Colors.
    var openActionPointColor: UIColor {
        return lightYellowColor
    }
    
    var ongoingActionPointColor: UIColor {
        return darkYellowColor
    }
    
    var cancelledActionPointColor: UIColor {
        return warmGreyColor
    }
    
	var completedActionPointColor: UIColor {
		return darkGreenColor
	}
	
	func image(for tab: ThemeTab) -> UIImage {
		let identifier: UIImage.AssetIdentifier
		
		switch tab {
		case .tripsTab:
			identifier = .tripsTabIcon
		case .supervisedTab:
			identifier = .supervisedTabIcon
		case .actionPointsTab:
			identifier = .actionPointsTabIcon
		}
		
		return UIImage(assetIdentifier: identifier).withRenderingMode(.alwaysOriginal)
	}
	
	func imageActive(for tab: ThemeTab) -> UIImage {
		let identifier: UIImage.AssetIdentifier
		
		switch tab {
		case .tripsTab:
			identifier = .tripsTabIconSelected
		case .supervisedTab:
			identifier = .supervisedTabIconSelected
		case .actionPointsTab:
			identifier = .actionPointsTabIconSelected
		}
		return UIImage(assetIdentifier: identifier).withRenderingMode(.alwaysOriginal)
		
	}
}
