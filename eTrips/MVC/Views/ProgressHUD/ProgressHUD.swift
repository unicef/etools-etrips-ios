import Foundation
import UIKit

/// Class used for displaying progress loading view.
class ProgressHUD {
	
	static let shared = ProgressHUD()
	
	private var activityIndicatorView: UIActivityIndicatorView?
	private var mainView: UIView?
	
	public func show() {
		createCustomView()
		activityIndicatorView?.startAnimating()
		
		UIApplication.shared.delegate?.window??.addSubview(mainView!)
	}
	
	public func dismiss() {
		activityIndicatorView?.stopAnimating()
		mainView?.removeFromSuperview()
	}
	
	private func createCustomView() {
		if mainView == nil {
			mainView = UIView.init(frame: UIScreen.main.bounds)
			mainView?.backgroundColor = UIColor(
				colorLiteralRed: 69.0 / 255.0,
				green: 69.0 / 255.0,
				blue: 69.0 / 255.0,
				alpha: 0.5
			)
		}
		
		activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
		activityIndicatorView?.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
		activityIndicatorView?.center = (mainView?.center)!
		mainView?.addSubview(activityIndicatorView!)
		activityIndicatorView?.bringSubview(toFront: mainView!)
		
	}
}
