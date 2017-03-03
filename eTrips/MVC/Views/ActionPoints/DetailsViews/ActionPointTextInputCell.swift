import UIKit
import KMPlaceholderTextView

protocol ActionPointTextInputCellDelegate: class {
	func didChange(text: String, in cell: ActionPointTextInputCell)
	func didEndEditing(text: String, in cell: ActionPointTextInputCell)
}

class ActionPointTextInputCell: UITableViewCell {
	@IBOutlet weak var inputTextView: KMPlaceholderTextView! {
		didSet {
			inputTextView.delegate = self
		}
	}
	
	public weak var delegate: ActionPointTextInputCellDelegate?
	var charactersLimit: Int?
}

// MARK: - UITextViewDelegate
extension ActionPointTextInputCell: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		delegate?.didChange(text: textView.text, in: self)
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		delegate?.didEndEditing(text: textView.text, in: self)
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if let limit = charactersLimit {
			return textView.text.characters.count + (text.characters.count - range.length) <= limit
		} else {
			return true
		}
	}
}
