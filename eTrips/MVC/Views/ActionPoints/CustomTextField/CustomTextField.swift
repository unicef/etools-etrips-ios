import UIKit

class CustomTextField: UITextField {

	public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		return false
	}
}
