import UIKit

protocol ActionPointDateCellDelegate: class {
    func didChangeDate(_ newDate: Date, inDateCell cell: ActionPointDateCell)
}

class ActionPointDateCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateTextField: CustomTextField! {
        didSet {
            dateInputView = ActionPointDateInputView.defaultView(withDelegate: self)
            dateTextField.inputView = dateInputView
        }
    }
	
    weak var delegate: ActionPointDateCellDelegate?
    
    private var dateInputView: ActionPointDateInputView? 
    
    func applyDate(_ date: Date?) {
        
        guard  let date = date else {
            dateTextField.text = "Not set"
            return
        }
        
        dateTextField.text = date.mediumDateStyleString()
        dateInputView?.datePicker.date = date
    }
}

// MARK: - ActionPointDateCellDelegate
extension ActionPointDateCell: ActionPointDateInputViewDelegate {
    
    func didSelectDate(_ date: Date) {
        delegate?.didChangeDate(date, inDateCell: self)
        dateTextField.resignFirstResponder()
    }
    
    func didCancelSelection() {
        dateTextField.resignFirstResponder()
    }
}
