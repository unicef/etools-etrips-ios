import UIKit
import KMPlaceholderTextView

class TripTextReportTableViewCell: UITableViewCell {
	@IBOutlet var reportTextView: KMPlaceholderTextView!
}

// MARK: - Configure
extension TripTextReportTableViewCell {
	func configure(with report: String?, delegate: UITextViewDelegate, isSupervised: Bool, isEditable: Bool) {
		if let report = report {
			reportTextView.text = report.utf8Data?.attributedString?.string
		} else {
			reportTextView.text = ""
		}
		
		reportTextView.delegate = delegate
		reportTextView.isEditable = isEditable
		
		if !isSupervised {
			reportTextView.placeholder = "Add report here"
		} else {
			reportTextView.placeholder = "No report"
		}
	}
}
