import UIKit
import MBProgressHUD

class TripReportTableViewController: UITableViewController {
	private var tripObserver: ManagedObjectObserver?

	var profileEntity: ProfileEntity?

	public var tripEntity: TripEntity! {
		didSet {
			tripObserver = ManagedObjectObserver(object: tripEntity, changeHandler: { [unowned self] type in
				if type == .update {
					self.setupSections()

					// If report already submitted we use report from server
					// else use our localy saved report.
					if self.tripEntity.isReportSubmitted {
						self.reportText = self.tripEntity.report
					} else {
						self.reportText = self.tripEntity.localReport?.report
					}

					self.tableView.reloadData()
				}
			})
		}
	}

	/// Networking services.
	let tripService = TripService()
	let tripReportService = TripReportService()
	let tripPhotoService = TripPhotoService()

	fileprivate enum SectionType {
		case draftSection
		case reportSection
		case addPhotoSection
		case photosSection
		case submitSection
	}

	fileprivate enum Row {
		case draftRow
		case reportRow
		case addPhotoRow
		case photoRow
		case submitRow

		var reuseIdentifier: String {
			switch self {
			case .draftRow:
				return "DraftRowCell"
			case .reportRow:
				return String(describing: TripTextReportTableViewCell.self)
			case .addPhotoRow:
				return "AddPhotoRowCell"
			case .photoRow:
				return String(describing: TripPhotoTableViewCell.self)
			case .submitRow:
				return "SubmitRowCell"
			}
		}
	}

	fileprivate struct Section {
		var type: SectionType
		var rows: [Row]
	}

	fileprivate var sections = [Section]()

	/// Picker for choosing images for report.
	fileprivate let picker = UIImagePickerController()

	var reportText: String?

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		if let profile = ProfileEntity.profileEntityForLoggedInUser(in: CoreDataStack.shared.managedObjectContext) {
			profileEntity = profile

			setupTableView()
			setupImagePickerController()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		reportText = tripEntity.localReport?.report
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Save local report only if report is not submitted yet.
		if !tripEntity.isReportSubmitted {
			tripEntity.localReport?.report = reportText
			tripEntity.lastModified = Date() as NSDate
		}

		CoreDataStack.shared.saveContext()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: - IBActions
	@IBAction func tapGestureRecognizerAction(_: UITapGestureRecognizer) {
		view.endEditing(true)
	}

	func addPhotoAction(at indexPath: IndexPath) {
		let alert =
			UIAlertController(title: "How would you like to set your photos?",
			                  message: nil,
			                  preferredStyle: .actionSheet)

		alert.modalPresentationStyle = .none

		if let popoverPresentationController = alert.popoverPresentationController {
			popoverPresentationController.sourceView =
				tableView.cellForRow(at: indexPath)
			popoverPresentationController.sourceRect = (tableView.cellForRow(at: indexPath)?.bounds)!
			popoverPresentationController.permittedArrowDirections = .any
		}

		// Take Photo.
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			let takePhotoAction = UIAlertAction(title: "Take Photo With Camera",
			                                    style: .default,
			                                    handler: { _ in self.takePhoto() })
			alert.addAction(takePhotoAction)
		}

		// Choose photo from library.
		if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
			let choosePhotoAction = UIAlertAction(title: "Choose Photo From Library",
			                                      style: .default,
			                                      handler: { _ in self.choosePhoto() })
			alert.addAction(choosePhotoAction)
		}

		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

		alert.addAction(cancelAction)

		present(alert, animated: true, completion: nil)
	}

	func submitReportAction() {
		guard let trip = tripEntity else {
			return
		}

		guard let report = reportText, !report.isBlank else {
			return
		}

		let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
		hud.mode = .determinateHorizontalBar
		hud.label.text = "Submitting..."

		let downloadGroup = DispatchGroup()

		var sendReportError: NetworkError?
		var uploadPhotoError: NetworkError?

		downloadGroup.enter()
		// 1. Sent text report.
		tripReportService.sendReport(report, for: trip) { success, error in
			downloadGroup.leave()
			if success {
				hud.progress += 0.2
			} else if let error = error {
				sendReportError = error
			}
		}

		if let localFiles = tripEntity.localFiles {

			// 2. Upload array of photos.
			for file in localFiles {

				if file.fileURL.contains("http") {
					continue
				}

				let url = NSURL(string: file.fileURL)
				let data = NSData(contentsOf: url! as URL)
				print("Upload data \((data?.length)! / 1000) KB")

				downloadGroup.enter()
				self.tripPhotoService.upload(photo: data! as Data, caption: file.caption, for: trip) { success, error in
					hud.progress += 0.8 / Float(localFiles.count)
					downloadGroup.leave()
					if success {
						print("PHOTO UPLOADED")
					} else if let error = error {
						uploadPhotoError = error
					}
				}

			}
		}

		downloadGroup.notify(queue: DispatchQueue.main) {
			if sendReportError != nil || uploadPhotoError != nil {

				hud.hide(animated: true)

				let error = sendReportError != nil ? sendReportError : uploadPhotoError
				let alert = UIAlertController(title: error?.title,
				                              message: error?.detail,
				                              preferredStyle: .alert)
				let okAction = UIAlertAction(title: "OK",
				                             style: .cancel,
				                             handler: nil)

				alert.addAction(okAction)

				self.present(alert, animated: true, completion: nil)
				return
			}

			// Delete local report and local files for the trip.
			self.tripEntity.deleteLocalReport()

			CoreDataStack.shared.saveContext()

			// 3. Re-download updated trips.
			self.tripService.downloadTrip(tripID: Int(self.tripEntity.tripID)) { _ in

				hud.hide(animated: true)
				CoreDataStack.shared.saveContext()

				let alert = UIAlertController(title: "Report Submitted",
				                              message: "Report has been successfully submitted.",
				                              preferredStyle: .alert)
				let okAction = UIAlertAction(title: "OK",
				                             style: .cancel,
				                             handler: nil)

				alert.addAction(okAction)
				self.present(alert, animated: true, completion: nil)

			}
		}
	}

	// MARK: - Private
	private func setupTableView() {
		setupSections()
		tableView.reloadData()
	}

	private func setupImagePickerController() {
		picker.delegate = self
		picker.allowsEditing = false
	}

	private func setupSections() {
		sections.removeAll()

		// "Draft" section.
		if tripEntity.isDraft && !tripEntity.isReportSubmitted {
			sections.append(Section(type: .draftSection, rows: [.draftRow]))
		}

		// "Report" section.
		sections.append(Section(type: .reportSection, rows: [.reportRow]))

		// "Add Photo" section.
		if !tripEntity.isReportSubmitted && tripEntity.type != .supervised {
			sections.append(Section(type: .addPhotoSection, rows: [.addPhotoRow]))
		}

		// "List of photos" section.
		if !tripEntity.isReportSubmitted {
			if let localFiles = tripEntity.localFiles {
				if !localFiles.isEmpty {
					sections.append(Section(type: .photosSection,
					                        rows: Array(repeating: .photoRow, count: localFiles.count)))
				}
			}
		} else {
			if let files = tripEntity.files {
				if !files.isEmpty {
					sections.append(Section(type: .photosSection, rows: Array(repeating: .photoRow, count: files.count)))
				}
			}
		}

		// "Submit Report" section.
		if !tripEntity.isReportSubmitted && tripEntity.type != .supervised {
			sections.append(Section(type: .submitSection, rows: [.submitRow]))
		}
	}

	private func takePhoto() {
		picker.sourceType = .camera
		picker.cameraCaptureMode = .photo
		present(picker, animated: true, completion: nil)
	}

	private func choosePhoto() {
		picker.sourceType = .photoLibrary
		present(picker, animated: true, completion: nil)
	}

}

// MARK: - UINavigationControllerDelegate
extension TripReportTableViewController: UINavigationControllerDelegate {
}

// MARK: - UIImagePickerControllerDelegate
extension TripReportTableViewController: UIImagePickerControllerDelegate {

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
		picker.dismiss(animated: true, completion: nil)

		var image = info[UIImagePickerControllerEditedImage] as? UIImage

		if image == nil {
			image = info[UIImagePickerControllerOriginalImage] as? UIImage
		}

		guard let newImage = image else { return }

		guard let tripPhotoTableViewController = TripPhotoTableViewController.viewControllerFromStoryboard()
			as? TripPhotoTableViewController else { return }

		tripPhotoTableViewController.image = newImage
		tripPhotoTableViewController.tripEntity = tripEntity
		let navigationController = UINavigationController(rootViewController: tripPhotoTableViewController)
		present(navigationController, animated: true, completion: nil)
	}
}

// MARK: - UITableViewDatasource
extension TripReportTableViewController {

	override func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].rows.count
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch sections[section].type {
		case .reportSection:
			return "REPORT"
		case .addPhotoSection:
			return "PHOTOS"
		default:
			return nil
		}
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch sections[section].type {
		case .addPhotoSection:
			return "The photos below will be uploaded when the trip report is submitted."
		default:
			return nil

		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]

		switch row {
		case .draftRow:
			guard let cell =
				tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
				fatalError()
			}

			cell.backgroundView = UIView()
			return cell
		case .reportRow:
			guard let cell =
				tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier)
				as? TripTextReportTableViewCell else {

				fatalError()
			}

			cell.configure(with: reportText,
			               delegate: self,
			               isSupervised: tripEntity.type == .supervised,
			               isEditable: tripEntity.type == .myTrip && !tripEntity.isReportSubmitted)
			return cell
		case .addPhotoRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
				fatalError()
			}
			return cell

		case .photoRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier)
				as? TripPhotoTableViewCell else {

				fatalError()
			}

			if tripEntity.isReportSubmitted {
				if let files = tripEntity.files {
					let fileEntity = Array(files)[indexPath.row]
					cell.configure(photo: fileEntity)
				}
			} else {
				if let localFiles = tripEntity.localFiles {
					let localFileEntity = Array(localFiles)[indexPath.row]
					cell.configure(localPhoto: localFileEntity)
				}
			}
			return cell
		case .submitRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
				fatalError()
			}
			return cell
		}
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if tripEntity.isReportSubmitted {
			return false
		}

		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]

		switch row {
		case .photoRow:
			return true
		default:
			return false
		}
	}
}

// MARK: - UITableViewDelegate
extension TripReportTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]

		switch row {
		case .addPhotoRow:
			addPhotoAction(at: indexPath)
		case .photoRow:
			if tripEntity.isReportSubmitted {
				let fileEntity = Array(tripEntity.files!)[indexPath.row]

				guard let tripPhotoTableViewController = TripPhotoTableViewController.viewControllerFromStoryboard()
					as? TripPhotoTableViewController else { return }

				tripPhotoTableViewController.fileEntity = fileEntity
				let navigationController = UINavigationController(rootViewController: tripPhotoTableViewController)
				present(navigationController, animated: true, completion: nil)
			} else {
				let localFileEntity = Array(tripEntity.localFiles!)[indexPath.row]

				guard let tripPhotoTableViewController = TripPhotoTableViewController.viewControllerFromStoryboard()
					as? TripPhotoTableViewController else { return }

				tripPhotoTableViewController.localFileEntity = localFileEntity
				let navigationController = UINavigationController(rootViewController: tripPhotoTableViewController)
				present(navigationController, animated: true, completion: nil)
			}
		case .submitRow:
			submitReportAction()
		default:
			break
		}

		tableView.deselectRow(at: indexPath, animated: true)
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 0 {
			return 34.0
		} else {
			return tableView.sectionHeaderHeight
		}
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]

		switch row {
		case .reportRow:
			return 156.0
		case .photoRow:
			return 100.0
		default:
			return 44.0
		}
	}

	override func tableView(_: UITableView,
	                        commit editingStyle: UITableViewCellEditingStyle,
	                        forRowAt indexPath: IndexPath) {
		if editingStyle == UITableViewCellEditingStyle.delete {

			guard !tripEntity.isReportSubmitted, let localFiles = tripEntity.localFiles else {
				return
			}

			let localFileEntity = Array(localFiles)[indexPath.row]
			tripEntity.mutableLocalFiles.remove(localFileEntity)
			CoreDataStack.shared.managedObjectContext.delete(localFileEntity)

			CoreDataStack.shared.saveContext()
		}
	}
}

// MARK: - UITextViewDelegate
extension TripReportTableViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		reportText = textView.text
	}

	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		return textView.text.characters.count + (text.characters.count - range.length) <= 5000
	}
}
