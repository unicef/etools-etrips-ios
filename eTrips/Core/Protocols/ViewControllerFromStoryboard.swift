import Foundation
import UIKit

/// If view controller conforms to this protocol it should implement
/// method for instantiating itself from storyboard.
protocol ViewControllerFromStoryboard {

	/// Returns view controller instantiated from storyboard.
	static func viewControllerFromStoryboard<T: UIViewController>() -> T?
}
