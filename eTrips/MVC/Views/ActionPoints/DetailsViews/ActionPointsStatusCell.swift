import UIKit

protocol ActionPointsStatusCellDelegate: class {
    func didChangeStatus(_ newStatus: String)
}

class ActionPointsStatusCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusTextField: CustomTextField! {
        didSet {
            statusInputView = ActionPointStatusInputView.defaultView(withDelegate: self)
            statusTextField.inputView = statusInputView
        }
    }
    
    weak var delegate: ActionPointsStatusCellDelegate?
    
    private var statusInputView: ActionPointStatusInputView?
    
    func applyStatus(_ status: String?) {
        statusTextField.text = status?.capitalized
        statusInputView?.currentStatus = status
    }
    
    func applyAvailableStatuses(_ statuses: [String]) {
        statusInputView?.availableStatuses = statuses
    }
}

extension ActionPointsStatusCell: ActionPointStatusInputViewDelegate {
    
    func didSelectNewStatus(_ status: String) {
        delegate?.didChangeStatus(status)
        statusTextField.resignFirstResponder()
    }
    
    func didCancelSelection() {
        statusTextField.resignFirstResponder()
    }
}
