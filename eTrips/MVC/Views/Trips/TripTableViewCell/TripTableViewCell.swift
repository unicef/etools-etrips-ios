import UIKit

class TripTableViewCell: UITableViewCell {
	@IBOutlet var tripIDLabel: UILabel!
	@IBOutlet var purposeOfTravelLabel: UILabel!
	@IBOutlet var fromDateToDateLabel: UILabel!
	@IBOutlet var statusLabel: UILabel!
	@IBOutlet var statusColorView: UIView!
	@IBOutlet var travelerNameLabel: UILabel!
	@IBOutlet var draftImageView: UIImageView!
}

// MARK: - ConfigurableCell
extension TripTableViewCell: ConfigurableCell {
	func configureForObject(object: TripEntity) {
		tripIDLabel.text = object.referenceNumber
		purposeOfTravelLabel.text = object.purposeOfTravel
		fromDateToDateLabel.text = object.fromDateToDateString
		statusLabel.text = object.formattedStatus
		
		if object.type == .myTrip {
			travelerNameLabel.isHidden = true
			travelerNameLabel.text = ""
		} else {
			travelerNameLabel.isHidden = false
			travelerNameLabel.text = object.travelerName
		}
		
		if object.isDraft {
			draftImageView.isHidden = false
		} else {
			draftImageView.isHidden = true
		}
		
		// Status.
		switch object.status {
		case "planned":
			statusColorView.backgroundColor = ThemeManager.shared.theme.plannedTripColor
		case "submitted":
			statusColorView.backgroundColor = ThemeManager.shared.theme.submittedTripColor
		case "approved":
			statusColorView.backgroundColor = ThemeManager.shared.theme.approvedTripColor
		case "rejected":
			statusColorView.backgroundColor = ThemeManager.shared.theme.rejectedTripColor
		case "cancelled":
			statusColorView.backgroundColor = ThemeManager.shared.theme.canceledTripColor
		case "certification_submitted":
			statusColorView.backgroundColor = ThemeManager.shared.theme.certificationSubmittedTripColor
		case "certified":
			statusColorView.backgroundColor = ThemeManager.shared.theme.certifiedTripColor
		case "sent_for_payment":
			statusColorView.backgroundColor = ThemeManager.shared.theme.sentForPaymentTripColor
		case "certification_rejected":
			statusColorView.backgroundColor = ThemeManager.shared.theme.certificationRejectedTripColor
		case "completed":
			statusColorView.backgroundColor = ThemeManager.shared.theme.completedTripColor
		case "certification_approved":
			statusColorView.backgroundColor = ThemeManager.shared.theme.certificationApprovedTripColor
		default:
			statusColorView.backgroundColor = UIColor.white
		}
	}
}
