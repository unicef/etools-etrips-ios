import Foundation
import UIKit

extension UIImage {
	enum AssetIdentifier: String {
		case tripsTabIcon = "ic_trips_tab"
		case supervisedTabIcon = "ic_superviced_tab"
		case actionPointsTabIcon = "ic_action_points_tab"

		case tripsTabIconSelected = "ic_trips_tab_selected"
		case supervisedTabIconSelected = "ic_superviced_tab_selected"
		case actionPointsTabIconSelected = "ic_action_points_tab_selected"
		
		case tripsEmptyStateIcon = "img_empty_mytrips"
		case supervisedEmptyStateIcon = "img_empty_supervised"
		case actionPointsEmptyStateIcon = "img_empty_action_points"
		
		case errorStateIcon = "img_error"
	}

	convenience init!(assetIdentifier: AssetIdentifier) {
		self.init(named: assetIdentifier.rawValue)
	}
}
