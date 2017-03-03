import UIKit

protocol ActionPointStatusInputViewDelegate: class {
	func didSelectNewStatus(_ status: String)
	func didCancelSelection()
}

class ActionPointStatusInputView: UIView {
	
	@IBOutlet weak var pickerView: UIPickerView!
	
	var availableStatuses = ["open", "ongoing", "cancelled", "completed"] {
		didSet {
			pickerView.reloadAllComponents()
		}
	}
	
	var currentStatus: String? {
		didSet {
			
			if let status = currentStatus {
				guard let index = availableStatuses.find({ status == $0 }) else {
					return
				}
				pickerView.selectRow(index, inComponent: 0, animated: false)
			}
		}
	}
	
	weak var delegate: ActionPointStatusInputViewDelegate?
	
	fileprivate static let nibName = "\(ActionPointStatusInputView.self)"
	
	static func defaultView(withDelegate delegate: ActionPointStatusInputViewDelegate?) -> ActionPointStatusInputView {
		
		let defView =
			UINib(nibName: nibName, bundle: nil).instantiate(withOwner: nil, options: nil)[0]
			as! ActionPointStatusInputView
		defView.delegate = delegate
		return defView
	}
	
	deinit {
		delegate = nil
	}
	
}

// MARK: Actions
extension ActionPointStatusInputView {
	
	@IBAction func onDoneButtonTap() {
		
		let ind = pickerView.selectedRow(inComponent: 0)
		delegate?.didSelectNewStatus(availableStatuses[ind])
	}
	
	@IBAction func onCanceButtonTap() {
		delegate?.didCancelSelection()
	}
}

// MARK: UIPickerViewDataSource
extension ActionPointStatusInputView: UIPickerViewDataSource {
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return availableStatuses.count
	}
}

extension ActionPointStatusInputView: UIPickerViewDelegate {
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return availableStatuses[row].capitalized
	}
}
