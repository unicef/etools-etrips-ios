import UIKit
import Moya

/// Controller responsible for user sign in to the application. After
/// successfull sign in user moves to main screen of the application.
class LoginViewController: UIViewController {
	/// Outlets.
	@IBOutlet var emailTextField: UITextField!
	@IBOutlet var passwordTextField: UITextField!
	@IBOutlet var signInButton: UIButton!
	@IBOutlet var inputFieldsContainerView: UIView!
	@IBOutlet var scrollView: UIScrollView!

	/// Services.
	var loginService: LoginService = LoginService()
	var loginSOAPService: LoginSOAPService = LoginSOAPService()
	var profileService: ProfileService = ProfileService()
	var staticDataService: StaticDataService = StaticDataService()
	var staticDataT2FService: StaticDataT2FService = StaticDataT2FService()
	var usersService: UsersService = UsersService()

	/// Static Data.
	var staticDataEntity: StaticDataEntity?
	var staticDataT2FEntity: StaticDataT2FEntity?

	/// TextField currently edited by user.
	weak var activeTextField: UITextField?

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		customizeAppearance()
		registerForKeyboardNotifications()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: - IBActions
	@IBAction func signInButtonAction(_: UIButton) {
		guard var username = emailTextField.text, !username.isEmpty else {
			let alert = UIAlertController(title: "Error",
			                              message: "Username cannot be empty.",
			                              preferredStyle: .alert)
			let okAction = UIAlertAction(title: "OK",
			                             style: .cancel, handler: nil)

			alert.addAction(okAction)
			self.present(alert, animated: true, completion: nil)

			return
		}

		guard let password = passwordTextField.text, !password.isEmpty else {

			let alert = UIAlertController(title: "Error",
			                              message: "Password cannot be empty.",
			                              preferredStyle: .alert)
			let okAction = UIAlertAction(title: "OK",
			                             style: .cancel, handler: nil)

			alert.addAction(okAction)
			self.present(alert, animated: true, completion: nil)
			return
		}

		// If user enters username without `@unicef.org` suffix, add this suffix programmatically.
		if username.lowercased().range(of: "@unicef.org") == nil {
			username.append("@unicef.org")
		}

		ProgressHUD.shared.show()
		view.endEditing(true)
		
		#if PRODUCTION || RELEASE
			self.loginSOAP(username: username, password: password)
		#else
			self.login(username: username, password: password)
		#endif
	}

	@IBAction func languageButtonAction(_: UIButton) {
	}

	/// Hides keyboard when user taps on any free space on the screen.
	@IBAction func tapGestureRecognizerAction(_: Any) {
		view.endEditing(true)
	}

	// MARK: - Methods
	func loginSOAP(username: String, password: String) {
		loginSOAPService.login(username, password) { success, error in

			if let error = error {
				ProgressHUD.shared.dismiss()
				let alert = UIAlertController(title: error.title,
											  message: error.detail,
											  preferredStyle: .alert)
				let okAction = UIAlertAction(title: "OK",
											 style: .cancel, handler: nil)
				alert.addAction(okAction)
				self.present(alert, animated: true, completion: nil)
				return
			}

			if success {
				self.loadData()
			} else {
				ProgressHUD.shared.dismiss()
			}
		}
	}
	
	func login(username: String, password: String) {
		loginService.login(username, password) { success, error in

			if let error = error {
				ProgressHUD.shared.dismiss()
				let alert = UIAlertController(title: error.title,
											  message: error.detail,
											  preferredStyle: .alert)
				let okAction = UIAlertAction(title: "OK",
											 style: .cancel, handler: nil)

				alert.addAction(okAction)
				self.present(alert, animated: true, completion: nil)
				return
			}

			if success {
				self.loadData()
			} else {
				ProgressHUD.shared.dismiss()
			}
		}
	}
	
	func loadData() {
		let downloadGroup = DispatchGroup()

		var profileSuccess = false
		var staticDataSuccess = false
		var staticDataT2FSuccess = false
		var usersSuccess = false

		downloadGroup.enter()
		// 1. Download Profile.
		self.profileService.downloadProfile { success in
			profileSuccess = success
			downloadGroup.leave()
		}

		// 2. Download static data 1.
		downloadGroup.enter()
		self.staticDataService.downloadStaticData { success, _ in
			staticDataSuccess = success
			downloadGroup.leave()
		}

		// 3. Download static data 2.
		downloadGroup.enter()
		self.staticDataT2FService.downloadStaticDataT2F { success, _ in
			staticDataT2FSuccess = success
			downloadGroup.leave()
		}

		// 4. Download list of users.
		downloadGroup.enter()
		self.usersService.downloadUsers { success in
			usersSuccess = success
			downloadGroup.leave()
		}

		downloadGroup.notify(queue: DispatchQueue.main) {
			ProgressHUD.shared.dismiss()
			if profileSuccess && staticDataSuccess && staticDataT2FSuccess && usersSuccess {
				self.transitionToTabBar()
			}
		}

	}

	func registerForKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector:
			#selector(keyboardWasShown),
			name: NSNotification.Name.UIKeyboardDidShow,
			object: nil)

		NotificationCenter.default.addObserver(self, selector:
			#selector(keyboardWillBeHidden),
			name: NSNotification.Name.UIKeyboardWillHide,
			object: nil)
	}

	func customizeAppearance() {
		inputFieldsContainerView.layer.borderColor = UIColor.white.cgColor

		signInButton.layer.borderColor =
			ThemeManager.shared.theme.signInButtonBorderColor.cgColor
	}

	func transitionToTabBar() {
		guard let tabBar = TabBarController.viewControllerFromStoryboard() else {
			return
		}

		guard var navigationStack = navigationController?.viewControllers else {
			return
		}

		let index = navigationStack.index(of: self)
		navigationStack[index!] = tabBar

		navigationController?.viewControllers = navigationStack
	}

	// MARK: - Keyboard Notifications

	func keyboardWasShown(notification: NSNotification) {
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {

			let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)

			self.scrollView.contentInset = contentInsets
			self.scrollView.scrollIndicatorInsets = contentInsets

			// Scroll to show "Sign In" button hidden under keyboard.
			let signInButtonRect = signInButton.convert(signInButton.bounds, to: view)
			scrollView.scrollRectToVisible(signInButtonRect, animated: true)
		}
	}

	func keyboardWillBeHidden(notification _: NSNotification) {
		let contentInsets = UIEdgeInsets.zero
		self.scrollView.contentInset = contentInsets
		self.scrollView.scrollIndicatorInsets = contentInsets
	}
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
	func textFieldDidEndEditing(_: UITextField) {
		self.activeTextField = nil
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		self.activeTextField = textField
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {

		if textField == emailTextField {
			passwordTextField.becomeFirstResponder()
		} else if textField == passwordTextField {
			passwordTextField.resignFirstResponder()
		}

		return true
	}
}

// MARK: - ViewControllerFromStoryboard
extension LoginViewController: ViewControllerFromStoryboard {
	static func viewControllerFromStoryboard<T: UIViewController>() -> T? {
		let storyboard = UIStoryboard(name: Constants.Storyboard.Authentication, bundle: nil)
		return storyboard.instantiateInitialViewController() as! T?
	}
}
