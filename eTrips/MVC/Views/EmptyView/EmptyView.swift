import UIKit

public class EmptyView: UIView {
	
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var textLabel: UILabel!
	@IBOutlet var subtitleLabel: UILabel!
	
	static func instanceFromNib(with image: UIImage,
	                            text: String,
	                            subtitle: String) -> EmptyView {
		let emptyView =
			UINib(nibName: String(describing: EmptyView.self), bundle: nil)
			.instantiate(withOwner: nil, options: nil)[0] as! EmptyView
		
		emptyView.imageView.image = image
		emptyView.textLabel.text = text
		emptyView.subtitleLabel.text = subtitle
		
		return emptyView
	}
	
}
