import UIKit

class TripAddPhotoCaptionTableViewCell: UITableViewCell {
	@IBOutlet var captionTextView: UITextView!
}

extension TripAddPhotoCaptionTableViewCell {
	
	func configure(with caption: String?, delegate: UITextViewDelegate) {
		captionTextView.text = caption
		captionTextView.delegate = delegate
	}
}
