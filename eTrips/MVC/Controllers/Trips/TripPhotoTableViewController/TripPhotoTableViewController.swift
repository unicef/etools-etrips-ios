import UIKit
import SKPhotoBrowser

class TripPhotoTableViewController: UITableViewController {
	public var image: UIImage?

	public var tripEntity: TripEntity!
	public var caption: String?

	fileprivate enum SectionType {
		case photoSection
		case captionSection
	}

	fileprivate enum Row {
		case photoRow
		case captionRow

		var reuseIdentifier: String {
			switch self {
			case .photoRow:
				return String(describing: TripAddPhotoTableViewCell.self)
			case .captionRow:
				return String(describing: TripAddPhotoCaptionTableViewCell.self)
			}
		}
	}

	fileprivate struct Section {
		var type: SectionType
		var rows: [Row]
	}

	fileprivate var sections = [Section]()

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		sections = [Section(type: .photoSection, rows: [.photoRow]),
		            Section(type: .captionSection, rows: [.captionRow])]

		setupNavigationBar()
		setupTableView()
		checkSaveButton()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: - IBActions
	func cancelBarButtonItemAction() {
		dismissKeyboard()
		dismiss(animated: true, completion: nil)
	}

	func saveBarButtonItemAction() {
		dismissKeyboard()

		let imageName = Date().timestamp()

		if let image = image {
			// Compression to 1MB.
			var compression: CGFloat = 1.0
			while compression >= 0.0 {
				if let imageData = UIImageJPEGRepresentation(image, compression) {
					if imageData.count < 1000000 {
						break
					}
					compression -= 0.1
				} else {
					break
				}
			}

			if let data = UIImageJPEGRepresentation(image, compression) {
				let filename = getDocumentsDirectory().appendingPathComponent(String(imageName))
				try? data.write(to: filename)

				let localFileEntity = LocalFileEntity.findOrCreate(in: CoreDataStack.shared.managedObjectContext,
				                                                   fileID: imageName,
				                                                   tripID: tripEntity.tripID,
				                                                   fileURL: filename.absoluteString,
				                                                   caption: caption ?? "No caption.")
				localFileEntity.trip = tripEntity
				tripEntity.mutableLocalFiles.add(localFileEntity)

				CoreDataStack.shared.saveContext()
			}
		}

		dismiss(animated: true, completion: nil)
	}

	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}

	// MARK: - Methods
	private func setupNavigationBar() {

		if caption != nil {
			title = "Photo"
		} else {
			title = "Add Photo"
		}

		// Cancel button.
		let cancelBarButtonItem =
			UIBarButtonItem(title: "Cancel",
			                style: .plain,
			                target: self,
			                action: #selector(TripPhotoTableViewController.cancelBarButtonItemAction))

		navigationItem.leftBarButtonItem = cancelBarButtonItem

		// Save button.
		let saveBarButtonItem =
			UIBarButtonItem(title: "Save",
			                style: .plain,
			                target: self,
			                action: #selector(TripPhotoTableViewController.saveBarButtonItemAction))

		if caption != nil {
			cancelBarButtonItem.title = "Close"
			navigationItem.rightBarButtonItem = nil
			navigationItem.leftBarButtonItem = cancelBarButtonItem
		} else {
			navigationItem.rightBarButtonItem = saveBarButtonItem
			navigationItem.leftBarButtonItem = cancelBarButtonItem

		}
	}

	func setupTableView() {
		tableView.tableFooterView = UIView()
		tableView.reloadData()
	}

	func dismissKeyboard() {
		self.view.endEditing(true)
	}

	func checkSaveButton() {
		if let caption = caption {

			navigationItem.rightBarButtonItem?.isEnabled = !caption.isBlank
		} else {
			navigationItem.rightBarButtonItem?.isEnabled = false
		}
	}
}

// MARK: - UITableViewDatasource
extension TripPhotoTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].rows.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]

		switch row {
		case .photoRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier)
				as? TripAddPhotoTableViewCell else {
				fatalError()
			}

			if let image = image {
				cell.configure(photo: image)
			}

			return cell

		case .captionRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier)
				as? TripAddPhotoCaptionTableViewCell else {
				fatalError()
			}

			if caption != nil {
				cell.configure(with: caption, delegate: self)
				cell.captionTextView.isEditable = false
			} else {
				cell.configure(with: "", delegate: self)
				cell.captionTextView.isEditable = true
				cell.captionTextView.becomeFirstResponder()
			}

			return cell
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		let section = sections[section].type

		switch section {
		case .captionSection:
			if tripEntity.isReportSubmitted {
				return nil
			} else {
				return "You can’t add photo without description"
			}

		default:
			return nil
		}
	}
}

// MARK: - UITableViewDelegate
extension TripPhotoTableViewController {
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]

		switch row {
		case .photoRow:
			return tableView.bounds.height / 3.0
		case .captionRow:
			return 120.0
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]

		switch row {
		case .photoRow:
			// Deselect text.
			self.view.endEditing(true)

			var images = [SKPhoto]()

			if let image = image {
				let photo = SKPhoto.photoWithImage(image)
				images.append(photo)
			}

			SKPhotoBrowserOptions.displayAction = false
			SKPhotoBrowserOptions.displayDeleteButton = false
			let browser = SKPhotoBrowser(photos: images)

			browser.initializePageIndex(0)
			present(browser, animated: true, completion: {})

		case .captionRow:
			break
		}

		tableView.deselectRow(at: indexPath, animated: true)
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNonzeroMagnitude
	}

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		let section = sections[section].type

		switch section {
		case .captionSection:
			if image != nil {
				return 30
			} else {
				return CGFloat.leastNonzeroMagnitude
			}
		default:
			return CGFloat.leastNonzeroMagnitude
		}
	}
}

// MARK: - UITextViewDelegate
extension TripPhotoTableViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		caption = textView.text
		checkSaveButton()
	}

	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		return textView.text.characters.count + (text.characters.count - range.length) <= 255
	}

}

// MARK: - ViewControllerFromStoryboard
extension TripPhotoTableViewController: ViewControllerFromStoryboard {
	static func viewControllerFromStoryboard<T: UIViewController>() -> T? {
		let storyboard = UIStoryboard(name: Constants.Storyboard.Trips, bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? T
	}
}
