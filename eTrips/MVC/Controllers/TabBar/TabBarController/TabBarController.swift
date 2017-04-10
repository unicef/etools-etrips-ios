import UIKit
import CoreData

class TabBarController: UITabBarController {

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(TabBarController.userDidLogOutNotification(_:)),
		                                       name: Notification.Name.UserDidLogOutNotification, object: nil)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: - Notifications
	/// Processes Log Out notifcation, cleans user token and Core Data, moves to the Login screen.
	func userDidLogOutNotification(_: Notification) {
		UserManager.shared.token = nil
		CoreDataStack.shared.cleanData()
		transitionToLogin()
	}

	// MARK: - Methods
	/// Setups as root view controller `LoginViewController`.
	private func transitionToLogin() {
		guard let loginViewController = LoginViewController.viewControllerFromStoryboard() else {
			return
		}

		UIApplication.shared.keyWindow?.rootViewController = loginViewController
	}
}

// MARK: - ViewControllerFromStoryboard
extension TabBarController: ViewControllerFromStoryboard {
	static func viewControllerFromStoryboard<T: UIViewController>() -> T? {
		let storyboard = UIStoryboard(name: Constants.Storyboard.TabBar, bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? T
	}
}
