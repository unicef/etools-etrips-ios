import UIKit

class ProfileTableViewController: UITableViewController {
	var profileEntity: ProfileEntity?

	fileprivate enum SectionType {
		case profileSection
		case infoSection
		case generalSettingsSection
		case logOutSection
	}

	fileprivate enum Row {
		case profileRow
		case usernameRow
		case countryRow
		case officeRow
		case positionRow
		case languageRow
		case logOutRow

		var reuseIdentifier: String {
			switch self {
			case .profileRow:
				return String(describing: ProfileTableViewCell.self)
			case .usernameRow:
				return "UsernameRowCell"
			case .countryRow:
				return "CountryRowCell"
			case .officeRow:
				return "OfficeRowCell"
			case .positionRow:
				return "PositionRowCell"
			case .languageRow:
				return "LanguageRowCell"
			case .logOutRow:
				return "LogOutRowCell"
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

		if let profile = ProfileEntity.profileEntityForLoggedInUser(in: CoreDataStack.shared.managedObjectContext) {
			profileEntity = profile

			sections = [Section(type: .profileSection, rows: [.profileRow]),
			            Section(type: .infoSection, rows: [.usernameRow, .countryRow, .officeRow, .positionRow]),
			            Section(type: .generalSettingsSection, rows: [.languageRow]),
			            Section(type: .logOutSection, rows: [.logOutRow])]
			tableView.reloadData()
		}

		setupNavigationBar()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: - IBActions
	@IBAction func doneBarButtonItemAction(_: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}

	func showLogOutActionSheet(at indexPath: IndexPath) {
		let alert = UIAlertController(title: "",
		                              message: "Are you sure you want to log out?",
		                              preferredStyle: UIAlertControllerStyle.actionSheet)

		alert.modalPresentationStyle = .popover

		let logOutAction = UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
			self?.dismiss(animated: true, completion: {
				NotificationCenter.default.post(name: Notification.Name.UserDidLogOutNotification, object: self)
				return
			})
		})

		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

		alert.addAction(logOutAction)
		alert.addAction(cancelAction)

		if let popoverPresentationController = alert.popoverPresentationController {
			popoverPresentationController.sourceView = tableView.cellForRow(at: indexPath)
			popoverPresentationController.sourceRect = (tableView.cellForRow(at: indexPath)?.bounds)!
			popoverPresentationController.permittedArrowDirections = .any
		}

		present(alert, animated: true, completion: nil)
	}

	// MARK: - Private
	func setupNavigationBar() {
		title = "Profile"

		let doneBarButtonItem =
			UIBarButtonItem(title: "Close",
			                style: .plain,
			                target: self,
			                action: #selector(ProfileTableViewController.doneBarButtonItemAction))

		navigationItem.rightBarButtonItem = doneBarButtonItem
	}
}

// MARK: - UITableViewDatasource
extension ProfileTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].rows.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]

		guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
			fatalError()
		}

		switch row {
		case .profileRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier)
				as? ProfileTableViewCell else {
				fatalError()
			}
			cell.fullNameLabel.text = profileEntity?.fullName
			return cell
		case .usernameRow:
			cell.detailTextLabel?.text = profileEntity?.username
			return cell
		case .countryRow:
			cell.detailTextLabel?.text = profileEntity?.country
			return cell
		case .officeRow:
			cell.detailTextLabel?.text = profileEntity?.office
			return cell
		case .positionRow:
			cell.detailTextLabel?.text = profileEntity?.jobTitle
			return cell
		case .languageRow:
			return cell
		case .logOutRow:
			return cell
		}
	}
}

// MARK: - UITableViewDelegate
extension ProfileTableViewController {
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]

		switch row {
		case .profileRow:
			return 100.0
		default:
			return 44.0
		}
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 0 {
			return CGFloat.leastNonzeroMagnitude
		} else {
			return tableView.sectionHeaderHeight
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]

		switch row {
		case .logOutRow:
			showLogOutActionSheet(at: indexPath)
		default:
			break
		}
	}
}

// MARK: - ViewControllerFromStoryboard
extension ProfileTableViewController: ViewControllerFromStoryboard {
	static func viewControllerFromStoryboard<T: UIViewController>() -> T? {
		let storyboard = UIStoryboard(name: Constants.Storyboard.Profile, bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? T
	}
}
