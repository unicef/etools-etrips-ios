import UIKit
import HockeySDK
import AlamofireNetworkActivityLogger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication,
	                 didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		NetworkActivityLogger.shared.startLogging()
		
		#if DEBUG
			NetworkActivityLogger.shared.level = .debug
		#else
			NetworkActivityLogger.shared.level = .off
		#endif
		
		checkFirstLaunch()
		setupHockeySDK()
		
		ThemeManager.shared.customizeAppearance()
		
		if UserManager.shared.isLoggedIn {
			showTabBarController()
		} else {
			showLoginController()
		}
		return true
	}
	
	func applicationDidEnterBackground(_: UIApplication) {
		CoreDataStack.shared.saveContext()
	}
	
	func applicationWillTerminate(_: UIApplication) {
		CoreDataStack.shared.saveContext()
	}
	
	// MARK: - Helpers
	func setupHockeySDK() {
		// Hockey SDK With Production identifier
		BITHockeyManager.shared().configure(withIdentifier: "f847e4be96d24933bf6067e3399a982e")
		BITHockeyManager.shared().start()
		BITHockeyManager.shared().authenticator.authenticateInstallation()
	}
	
	/// Check first launch and make preparations, clean keychain.
	func checkFirstLaunch() {
		if UserDefaults.standard.bool(forKey: Constants.UserDefaults.FirstLaunchKey) == false {
			UserDefaults.standard.set(true, forKey: Constants.UserDefaults.FirstLaunchKey)
			UserManager.shared.token = nil
		}
	}
	
	// MARK: - Transitions
	/// Setups as root view controller `LoginViewController`.
	func showLoginController() {
		guard let loginViewController = LoginViewController.viewControllerFromStoryboard() else {
			return
		}
		
		window?.rootViewController = loginViewController
	}
	
	/// Setups as root view controller `TabBarController`.
	func showTabBarController() {
		guard let tabBarController = TabBarController.viewControllerFromStoryboard() else {
			fatalError("Wrong view controller type")
		}
		
		window?.rootViewController = tabBarController
	}
}
