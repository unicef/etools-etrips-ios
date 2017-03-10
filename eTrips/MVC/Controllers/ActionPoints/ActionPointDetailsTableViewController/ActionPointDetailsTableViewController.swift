import UIKit
import CoreData
import MBProgressHUD

protocol ActionPointDetailsTableViewControllerDelegate: class {
	func didUpdateActionPoint(_ actionPoint: ActionPointEntity)
	func didAddNewActionPoint()
}

class ActionPointDetailsTableViewController: UITableViewController {
	var isNewPoint = false
	var scratchpadContext = CoreDataStack.shared.stratchpadManagedObjectContext
	
	func scratchpad(with actionPoint: ActionPointEntity?) -> ActionPointEntity? {
		guard let actionPoint = actionPoint else {
			return nil
		}
		let pointEntity = ActionPointEntity.findAndUpdateOrCreate(in: scratchpadContext, object: actionPoint)
		return pointEntity
	}
	
	public var actionPoint: ActionPointEntity! {
		didSet {
			actionPoint = self.scratchpad(with: actionPoint)
		}
	}
	
	var tripEntity: TripEntity?
	
	fileprivate enum SectionType {
		case personResponsibleSection
		case actionPointDetailsSection
	}
	
	fileprivate enum Row {
		case personResponsibleRow
		case descriptionRow
		case dueDateRow
		case completedDateRow
		case statusRow
		case actionsTakenRow
		case followUpRow
		
		var reuseIdentifier: String {
			switch self {
			case .personResponsibleRow:
				return "PersonResponsibleRowCell"
			case .descriptionRow:
				return "DescriptionRowCell"
			case .dueDateRow:
				return "DueDateRowCell"
			case .completedDateRow:
				return "CompletedDateRowCell"
			case .statusRow:
				return "StatusRowCell"
			case .actionsTakenRow:
				return "ActionsTakenRowCell"
			case .followUpRow:
				return "FollowUpRowCell"
			}
		}
	}
	
	fileprivate struct Section {
		var type: SectionType
		var rows: [Row]
	}
	
	fileprivate var sections = [Section]()
	
	let userID = UserManager.shared.userID
	public weak var delegate: ActionPointDetailsTableViewControllerDelegate?
	
	/// Network Service.
	private var actionPointsService: ActionPointsService = ActionPointsService()
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupSections()
		setupTableView()
		subsribeToNotifications()
		
		if isNewPoint { // Adding new action point.
			navigationItem.title = "Add Action Point"
			
			setupSaveButton()
			setupCancelButton()
			
			if let uID = userID {
				actionPoint = ActionPointEntity.createNewDraftEntity(in: scratchpadContext,
				                                                     withCreatorID: uID)
			}
			// `Supervised` action points viewing.
		} else if actionPoint.trip?.type == .supervised {
			
			if let uID = userID {
				if uID == Int(actionPoint.assignedByPersonID) {
					setupSaveButton()
				}
			}
			
			navigationItem.title = "Action Point"
		} else { // `My Action Points` viewing and editing.
			setupSaveButton()
			navigationItem.title = "My Action Point"
		}
		
		self.tableView.reloadData()
	}
	
	// MARK: - IBActions
	@IBAction func tapGestureRecognizerAction(_: UITapGestureRecognizer) {
		view.endEditing(true)
	}
	
	func saveButtonAction() {
		view.endEditing(true)
		
		guard let pointToSave = actionPoint else {
			_ = navigationController?.popViewController(animated: true)
			return
		}
		
		if isNewPoint {
			addNewActionPoint(point: pointToSave)
		} else {
			
			updateActionPoint(point: pointToSave)
		}
	}
	
	func cancelButtonAction() {
		dismiss(animated: true, completion: nil)
	}
	
	// MARK: - Methods
	private func addNewActionPoint(point: ActionPointEntity) {
		
		let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
		guard let tripEntity = tripEntity else {
			return
		}
		
		var actionPoints = [ActionPointEntity]()
		
		if let storedActionPoints = tripEntity.actionPoints {
			let storedActionPointsArray = Array(storedActionPoints)
			actionPoints.append(contentsOf: storedActionPointsArray)
		}
		
		actionPoints.append(point)
		
		actionPointsService.addActionPoint(actionPoints, forTripID: Int(tripEntity.tripID)) { success, error in
			
			hud.hide(animated: true)
			
			if success {
				self.delegate?.didAddNewActionPoint()
				self.closeScreen()
			} else if let error = error {
				let alert = UIAlertController(title: error.title,
				                              message: error.detail,
				                              preferredStyle: .alert)
				let okAction = UIAlertAction(title: "OK",
				                             style: .cancel,
				                             handler: nil)
				
				alert.addAction(okAction)
				
				self.present(alert, animated: true, completion: nil)
			} else {
				self.closeScreen()
			}
		}
	}
	
	private func updateActionPoint(point: ActionPointEntity) {
		let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
		actionPointsService.updateActionPoint(point) { success, error in
			
			hud.hide(animated: true)
			
			if success {
				if let point = self.actionPoint {
					self.delegate?.didUpdateActionPoint(point)
				}
				self.closeScreen()
			} else if let error = error {
				let alert = UIAlertController(title: error.title,
				                              message: error.detail,
				                              preferredStyle: .alert)
				let okAction = UIAlertAction(title: "OK",
				                             style: .cancel,
				                             handler: { _ in
				})
				
				alert.addAction(okAction)
				
				self.present(alert, animated: true, completion: nil)
				
			} else {
				self.closeScreen()
			}
			
		}
	}
	
	private func closeScreen() {
		if self.isNewPoint {
			self.dismiss(animated: true, completion: nil)
		} else {
			_ = self.navigationController?.popViewController(animated: true)
		}
	}
	
	private func setupTableView() {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 44
	}
	
	private func setupSections() {
		sections = [Section(type: .personResponsibleSection, rows: [.personResponsibleRow]),
		            Section(type: .actionPointDetailsSection,
		                    rows: [.descriptionRow, .dueDateRow, .completedDateRow,
		                           .statusRow, .actionsTakenRow, .followUpRow])]
	}
	
	private func setupSaveButton() {
		let selector = #selector(saveButtonAction)
		let saveButton = UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: selector)
		navigationItem.setRightBarButton(saveButton, animated: false)
		checkSaveButtonState()
	}
	
	private func setupCancelButton() {
		let selector = #selector(cancelButtonAction)
		let button = UIBarButtonItem.init(title: "Cancel", style: .plain, target: self, action: selector)
		navigationItem.setLeftBarButton(button, animated: false)
	}
	
	private func subsribeToNotifications() {
		
		let notificationName = NSNotification.Name.NSManagedObjectContextObjectsDidChange
		let selector = #selector(managedObjectContextObjectsDidChange)
		
		NotificationCenter.default.addObserver(self,
		                                       selector: selector,
		                                       name: notificationName,
		                                       object: scratchpadContext)
	}
	
	func checkSaveButtonState() {
		let isPersonAssigned: Bool
		let isDescriptionSet: Bool
		let isActionsTakenSet: Bool
		let canSaveChanges: Bool
		
		if let personID = actionPoint?.personResponsibleID {
			isPersonAssigned = personID > 0
		} else {
			isPersonAssigned = false
		}
		
		if let description = actionPoint?.pointDescription {
			isDescriptionSet = !description.isBlank
		} else {
			isDescriptionSet = false
		}
		
		if let actionsTaken = actionPoint?.actionsTaken {
			isActionsTakenSet = !actionsTaken.isBlank
		} else {
			isActionsTakenSet = false
		}
		
		if let status = actionPoint?.status {
			if status == "completed" {
				canSaveChanges = isPersonAssigned && isDescriptionSet && isActionsTakenSet
			} else {
				canSaveChanges = isPersonAssigned && isDescriptionSet
			}
		} else {
			canSaveChanges = false
		}
		
		navigationItem.rightBarButtonItem?.isEnabled = canSaveChanges
	}
}

// MARK: - UITableViewDataSource
extension ActionPointDetailsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].rows.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch sections[section].type {
		case .personResponsibleSection:
			return "PERSON RESPONSIBLE"
		case .actionPointDetailsSection:
			return "ACTION POINT DETAILS"
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]
		
		switch row {
		case .personResponsibleRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
				fatalError()
			}
			
			if let userID = userID {
				if actionPoint.assignedByPersonID == Int64(userID) {
					cell.isUserInteractionEnabled = true
				} else {
					cell.isUserInteractionEnabled = false
				}
			}
			
			if let personResponsibleName = actionPoint.personResponsibleName {
				cell.textLabel?.text = personResponsibleName
			} else {
				cell.textLabel?.text = "Select from list"
			}
			
			return cell
		case .descriptionRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier)
				as? ActionPointTextInputCell else {
				fatalError()
			}
			cell.inputTextView.text = actionPoint.pointDescription
			cell.delegate = self
			
			if let userID = userID {
				if actionPoint.assignedByPersonID == Int64(userID) {
					cell.inputTextView.isUserInteractionEnabled = true
				} else {
					cell.inputTextView.isUserInteractionEnabled = false
				}
			}
			return cell
		case .dueDateRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier)
				as? ActionPointDateCell else {
				fatalError()
			}
			cell.applyDate(actionPoint.dueDate as Date)
			
			if let userID = userID {
				if actionPoint.assignedByPersonID == Int64(userID) {
					cell.dateTextField.isUserInteractionEnabled = true
				} else {
					cell.dateTextField.isUserInteractionEnabled = false
				}
			}
			cell.delegate = self
			return cell
		case .completedDateRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier)
				as? ActionPointDateCell else {
				fatalError()
			}
			
			cell.applyDate(actionPoint.completedAt as? Date)
			
			if let userID = userID {
				if actionPoint.trip?.type == .supervised && actionPoint.assignedByPersonID != Int64(userID) {
					cell.dateTextField.isUserInteractionEnabled = false
				} else {
					cell.dateTextField.isUserInteractionEnabled = true
				}
			}
			cell.delegate = self
			return cell
		case .statusRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier)
				as? ActionPointsStatusCell else {
				fatalError()
			}
			cell.applyStatus(actionPoint.status)
			if let userID = userID {
				if actionPoint.assignedByPersonID == Int64(userID) {
					cell.statusTextField.isUserInteractionEnabled = true
				} else {
					cell.statusTextField.isUserInteractionEnabled = false
				}
			}
			cell.delegate = self
			return cell
		case .actionsTakenRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier)
				as? ActionPointTextInputCell else {
				fatalError()
			}
			
			cell.charactersLimit = 254
			
			if let userID = userID {
				if actionPoint.trip?.type == .supervised && actionPoint.assignedByPersonID != Int64(userID) {
					cell.inputTextView.isUserInteractionEnabled = false
				} else {
					cell.inputTextView.isUserInteractionEnabled = true
				}
			}
			
			cell.inputTextView.text = actionPoint.actionsTaken
			cell.delegate = self
			return cell
		case .followUpRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier)
				as? ActionPointFollowUpCell else {
				fatalError()
			}
			
			if let userID = userID {
				if actionPoint.trip?.type == .supervised && actionPoint.assignedByPersonID != Int64(userID) {
					cell.switcher.isUserInteractionEnabled = false
				} else {
					cell.switcher.isUserInteractionEnabled = true
				}
			}
			cell.switcher.isOn = actionPoint.followUp
			cell.delegate = self
			return cell
		}
	}
}

// MARK: - UITableViewDelegate
extension ActionPointDetailsTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]
		
		switch row {
		case .personResponsibleRow:
			if let usersListController =
				PersonSelectionTableViewController.viewControllerFromStoryboard()
				as? PersonSelectionTableViewController {
				usersListController.delegate = self
				usersListController.selectedPersonId = actionPoint?.personResponsibleID
				navigationController?.pushViewController(usersListController, animated: true)
			}
		default:
			break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

// MARK: - PersonSelectionTableViewControllerDelegate
extension ActionPointDetailsTableViewController: PersonSelectionTableViewControllerDelegate {
	func didSelectPerson(_ person: UserEntity) {
		actionPoint?.updatePerson(with: person.userID, name: person.fullName)
	}
}

// MARK: - ActionPointsStatusCellDelegate
extension ActionPointDetailsTableViewController: ActionPointsStatusCellDelegate {
	func didChangeStatus(_ newStatus: String) {
		if newStatus.lowercased() == "completed" && actionPoint?.completedAt == nil {
			actionPoint?.updateCompletedAtDate(newDate: Date())
		} else if newStatus.lowercased() != "completed" {
			actionPoint?.updateCompletedAtDate(newDate: nil)
		}
		actionPoint?.updateStatus(newStatus: newStatus)
	}
}

// MARK: - ActionPointDateCellDelegate
extension ActionPointDetailsTableViewController: ActionPointDateCellDelegate {
	func didChangeDate(_ newDate: Date, inDateCell cell: ActionPointDateCell) {
		guard let reuseIdentifier = cell.reuseIdentifier else {
			return
		}
		
		switch reuseIdentifier {
		case Row.dueDateRow.reuseIdentifier:
			actionPoint.updateDueDate(newDate: newDate)
		case Row.completedDateRow.reuseIdentifier:
			actionPoint.updateCompletedAtDate(newDate: newDate)
		default:
			return
		}
	}
}

// MARK: - ActionPointFollowUpCellDelegate
extension ActionPointDetailsTableViewController: ActionPointFollowUpCellDelegate {
	func didChangeFollowUpValue(_ newValue: Bool) {
		actionPoint?.updateFollowUp(flag: newValue)
	}
}

// MARK: - ActionPointTextInputCellDelegate
extension ActionPointDetailsTableViewController: ActionPointTextInputCellDelegate {
	func didChange(text: String, in cell: ActionPointTextInputCell) {
		// Handle sizing of table view cell with growing text view.
		let currentOffset = tableView.contentOffset
		UIView.setAnimationsEnabled(false)
		tableView.beginUpdates()
		tableView.endUpdates()
		UIView.setAnimationsEnabled(true)
		tableView.setContentOffset(currentOffset, animated: false)
	}
	
	func didEndEditing(text: String, in cell: ActionPointTextInputCell) {
		guard let reuseIdentifier = cell.reuseIdentifier else {
			return
		}
		
		switch reuseIdentifier {
		case Row.descriptionRow.reuseIdentifier:
			actionPoint.updatePointDescription(newDescription: text)
		case Row.actionsTakenRow.reuseIdentifier:
			actionPoint.updateActionsTaken(newAction: text)
		default:
			return
		}
	}
}

// MARK: - ViewControllerFromStoryboard
extension ActionPointDetailsTableViewController: ViewControllerFromStoryboard {
	static func viewControllerFromStoryboard<T: UIViewController>() -> T? {
		let storyboard = UIStoryboard(name: Constants.Storyboard.ActionPoints, bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? T
	}
}

// MARK: - NSManagedObjectContext Notifications
extension ActionPointDetailsTableViewController {
	func managedObjectContextObjectsDidChange(notification: NSNotification) {
		guard let userInfo = notification.userInfo else { return }
		
		if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
			tableView.reloadData()
			checkSaveButtonState()
		}
	}
}
