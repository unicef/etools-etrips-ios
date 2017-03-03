import Foundation
import UIKit

enum ThemeTab {
	case tripsTab
	case supervisedTab
	case actionPointsTab
}

protocol Theme {
	/// Colors.
	var signInButtonBorderColor: UIColor { get }
	var navigationBarTintColor: UIColor { get }
	var buttonTintColor: UIColor { get }
	
	/// Trips Colors.
	var plannedTripColor: UIColor { get }
	var submittedTripColor: UIColor { get }
	var approvedTripColor: UIColor { get }
	var rejectedTripColor: UIColor { get }
	var canceledTripColor: UIColor { get }
	var sentForPaymentTripColor: UIColor { get }
	var completedTripColor: UIColor { get }
	var certifiedTripColor: UIColor { get }
	var certificationSubmittedTripColor: UIColor { get }
	var certificationRejectedTripColor: UIColor { get }
	var certificationApprovedTripColor: UIColor { get }
    
    /// Action Points Colors.
    var openActionPointColor: UIColor { get }
    var ongoingActionPointColor: UIColor { get }
    var cancelledActionPointColor: UIColor { get }
    var completedActionPointColor: UIColor { get }

	/// TabBar icons.
	func image(for tab: ThemeTab) -> UIImage
	func imageActive(for tab: ThemeTab) -> UIImage
}

/// Used for customization of UI.
class ThemeManager {
	static let shared = ThemeManager()

	public let theme: Theme

	private init() {
		self.theme = DefaultTheme()
	}

	func customizeAppearance() {
		// Status Bar should be white.
		UIApplication.shared.statusBarStyle = .lightContent

		// UINavigationBar Appearance.
		let navigationBarAppearance = UINavigationBar.appearance()
		navigationBarAppearance.isTranslucent = false
		navigationBarAppearance.barTintColor = theme.navigationBarTintColor
		navigationBarAppearance.tintColor = UIColor.white
		navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
	}

	func customize(item: UITabBarItem?, for tab: ThemeTab) {

		guard let tabItem = item else {
			return
		}

		tabItem.image = theme.image(for: tab)
		tabItem.selectedImage = theme.imageActive(for: tab)
	}

}
