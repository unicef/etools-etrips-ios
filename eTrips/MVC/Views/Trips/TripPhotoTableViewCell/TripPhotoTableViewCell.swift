import UIKit
import Kingfisher

class TripPhotoTableViewCell: UITableViewCell {
	@IBOutlet var photoImageView: UIImageView!
	@IBOutlet var captionLabel: UILabel!
}

extension TripPhotoTableViewCell {
	func configure(photo: FileEntity) {
		photoImageView.kf.indicatorType = .activity
		
		if let url = URL(string: photo.fileURL) {
			photoImageView.kf.setImage(with: url)
		}
		captionLabel.text = !photo.caption.isEmpty ? photo.caption: "No description"
	}
	
	func configure(localPhoto: LocalFileEntity) {
		photoImageView.kf.indicatorType = .activity
		
		if let url = URL(string: localPhoto.fileURL) {
			photoImageView.kf.setImage(with: url)
		}
		captionLabel.text = !localPhoto.caption.isEmpty ? localPhoto.caption: "No description"
	}
}
