import UIKit

protocol ActionPointFollowUpCellDelegate: class {
    func didChangeFollowUpValue(_ newValue: Bool)
}

class ActionPointFollowUpCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switcher: UISwitch!
    
    weak var delegate: ActionPointFollowUpCellDelegate?
    
    deinit {
        delegate = nil
    }
    
    @IBAction func switcherDidChangeValue() {
        delegate?.didChangeFollowUpValue(switcher.isOn)
    }
}
