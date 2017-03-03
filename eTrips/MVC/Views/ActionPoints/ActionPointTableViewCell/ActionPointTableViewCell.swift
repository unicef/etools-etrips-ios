import UIKit

class ActionPointTableViewCell: UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var assignedByLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusColorView: UIView!
}

// MARK: - ConfigurableCell
extension ActionPointTableViewCell: ConfigurableCell {
    func configureForObject(object: ActionPointEntity) {
        
        descriptionLabel.text = object.pointDescription
        
        if let createrName = object.assignedByName {
            assignedByLabel.text = "Assigned by \(createrName)"
        } else {
            assignedByLabel.text = "Assigned by Unknown"
        }
        
        dueLabel.text = "Due \(object.dueDateString)"
        statusLabel.text = object.status.capitalized
        
        switch object.status {
        case "open":
            statusColorView.backgroundColor = ThemeManager.shared.theme.openActionPointColor
        case "ongoing":
            statusColorView.backgroundColor = ThemeManager.shared.theme.ongoingActionPointColor
        case "cancelled":
            statusColorView.backgroundColor = ThemeManager.shared.theme.cancelledActionPointColor
        case "completed":
            statusColorView.backgroundColor = ThemeManager.shared.theme.completedActionPointColor
        default:
            statusColorView.backgroundColor = UIColor.white
        }
    }
}
