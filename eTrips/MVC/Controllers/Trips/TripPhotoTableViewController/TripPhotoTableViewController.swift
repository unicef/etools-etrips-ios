import UIKit
import SKPhotoBrowser

/// Controller responsible for adding info about photo and photo preview from trip report screen.
class TripPhotoTableViewController: UITableViewController {
	/// Entity of the report in the CoreData. Contains all info about trip with report and photos.
	public var tripEntity: TripEntity!
	
	/// Mode of the screen `add`, `preview`, `undefined`.
	public var mode: Mode = .undefined
	enum Mode {
		case add(UIImage)
		case preview(UIImage, String)
		case undefined
	}

	/// Caption for the photo that user enters.
	fileprivate var caption: String?

	/// Section Type for describing and configuring table view controller.
	fileprivate enum SectionType {
		case photoSection
		case captionSection
	}
	
	/// Row enum for describing each row in the table view controller for easy configuring screen on the fly.
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
	
	/// Section struct describes each section with `SectionType` and list of rows in the table view controller.
	fileprivate struct Section {
		var type: SectionType
		var rows: [Row]
	}
	fileprivate var sections = [Section]()
	
	var managedObjectContext = CoreDataStack.shared.managedObjectContext

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

		switch mode {
		case Mode.add(let photo):
			compressPhotoAndSaveToCoreData(photo)
		default:
			break
		}

		dismiss(animated: true, completion: nil)
	}

	// MARK: - Methods
	private func compressPhotoAndSaveToCoreData(_ photo: UIImage) {
		let imageName = Date().timestamp()
		// Compression to 1MB.
		var compression: CGFloat = 1.0
		while compression >= 0.0 {
			if let imageData = UIImageJPEGRepresentation(photo, compression) {
				if imageData.count < 1000000 {
					break
				}
				compression -= 0.1
			} else {
				break
			}
		}

		if let data = UIImageJPEGRepresentation(photo, compression) {
			let filename = documentsDirectory().appendingPathComponent(String(imageName))
			try? data.write(to: filename)

			let localFileEntity = LocalFileEntity.findOrCreate(in: managedObjectContext,
			                                                   fileID: imageName,
			                                                   tripID: tripEntity.tripID,
			                                                   fileURL: filename.absoluteString,
			                                                   caption: caption ?? "No Caption.")
			localFileEntity.trip = tripEntity
			tripEntity.mutableLocalFiles.add(localFileEntity)

			CoreDataStack.shared.saveContext()
		}
	}
	
	/// Returns a documents directory in the file system.
	private func documentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}

	private func setupNavigationBar() {
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

		switch mode {
		case .add:
			title = "Add Photo"
			navigationItem.rightBarButtonItem = saveBarButtonItem
			navigationItem.leftBarButtonItem = cancelBarButtonItem
		case .preview:
			title = "Photo"
			cancelBarButtonItem.title = "Close"
			navigationItem.rightBarButtonItem = nil
			navigationItem.leftBarButtonItem = cancelBarButtonItem
		default:
			break
		}

	}

	private func setupTableView() {
		tableView.tableFooterView = UIView()
		tableView.reloadData()
	}

	private func dismissKeyboard() {
		self.view.endEditing(true)
	}

	/// Checks the state of the "Save" button. If caption is not entered "Save" button is disabled.
	fileprivate func checkSaveButton() {
		switch mode {
		case .add:
			guard let caption = caption else {
				navigationItem.rightBarButtonItem?.isEnabled = false
				return
			}
			navigationItem.rightBarButtonItem?.isEnabled = !caption.isBlank
		case .preview:
			navigationItem.rightBarButtonItem?.isEnabled = false
		default:
			break
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

			switch mode {
			case .add(let photo):
				cell.configure(photo: photo)
			case .preview(let photo, _):
				cell.configure(photo: photo)
			default:
				break
			}

			return cell

		case .captionRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier)
				as? TripAddPhotoCaptionTableViewCell else {
				fatalError()
			}

			switch mode {
			case .add:
				cell.configure(with: caption, delegate: self)
				cell.captionTextView.isEditable = true
				cell.captionTextView.becomeFirstResponder()
			case .preview(_, let caption):
				cell.configure(with: caption, delegate: self)
				cell.captionTextView.isEditable = false
			default:
				break
			}
			return cell
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		let section = sections[section].type

		switch section {
		case .captionSection:
			switch mode {
			case .add:
				return "You can’t add photo without description"
			default:
				return nil
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

			switch mode {
			case let .add(photo):
				let skPhoto = SKPhoto.photoWithImage(photo)
				images.append(skPhoto)
			case let .preview(photo, _):
				let skPhoto = SKPhoto.photoWithImage(photo)
				images.append(skPhoto)
			default:
				return
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
			switch mode {
			case .add:
				return 30.0
			case .preview:
				return CGFloat.leastNonzeroMagnitude
			default:
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
