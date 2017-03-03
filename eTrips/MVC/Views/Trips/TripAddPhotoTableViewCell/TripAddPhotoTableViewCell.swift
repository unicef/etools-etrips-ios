import UIKit
import Kingfisher

class TripAddPhotoTableViewCell: UITableViewCell {
	@IBOutlet var photoImageView: UIImageView!
}

extension TripAddPhotoTableViewCell {

	func configure(photo: UIImage) {
		photoImageView.image = photo
	}
	
	func configure(stringURL: String) {
		photoImageView.kf.indicatorType = .activity
		
		if let url = URL(string: stringURL) {
			photoImageView.kf.setImage(with: url)
		}
	}
}
