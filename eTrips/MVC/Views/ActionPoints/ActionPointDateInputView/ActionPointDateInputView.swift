import UIKit

protocol ActionPointDateInputViewDelegate: class {
	func didSelectDate(_ date: Date)
	func didCancelSelection()
}

class ActionPointDateInputView: UIView {
	
	@IBOutlet weak var datePicker: UIDatePicker!
	
	weak var delegate: ActionPointDateInputViewDelegate?
	
	fileprivate static let nibName = String(describing: ActionPointDateInputView.self)
	
	static func defaultView(withDelegate delegate: ActionPointDateInputViewDelegate?) -> ActionPointDateInputView {
		let defView =
			UINib(nibName: nibName, bundle: nil).instantiate(withOwner: nil, options: nil)[0]
			as! ActionPointDateInputView
		defView.delegate = delegate
		return defView
	}
	
	deinit {
		delegate = nil
	}
}

// MARK: Actions
extension ActionPointDateInputView {
	
	@IBAction func onDoneButtonTap() {
		delegate?.didSelectDate(datePicker.date)
	}
	
	@IBAction func onCanceButtonTap() {
		delegate?.didCancelSelection()
	}
}
