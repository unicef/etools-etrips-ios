import Foundation

/// Display `Travel Activities`.
class TravelActiviesTableViewController: UITableViewController {
	public var travelActivities: [TravelActivityEntity]!
	public var staticDataT2FEntity: StaticDataT2FEntity!
	
	fileprivate enum Row: Int {
		case travelTypeRow = 0
		case partnerRow
		case partnershipRow
		case primaryTravelerRow

		var reuseIdentifier: String {
			switch self {
			case .travelTypeRow:
				return "TravelTypeRowCell"
			case .partnerRow:
				return "PartnerRowCell"
			case .partnershipRow:
				return "PartnershipRowCell"
			case .primaryTravelerRow:
				return "PrimaryTravelerRowCell"
			}
		}
	}
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		setupNavigationBar()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: - IBActions
	func closeBarButtonItemAction() {
		dismiss(animated: true, completion: nil)
	}

	// MARK: - Private
	func setupNavigationBar() {
		title = "Travel Activities"

		let closeBarButtonItem =
			UIBarButtonItem(title: "Close",
			                style: .plain,
			                target: self,
			                action: #selector(TravelActiviesTableViewController.closeBarButtonItemAction))

		navigationItem.rightBarButtonItem = closeBarButtonItem
	}
}

// MARK: - UITableViewDatasource
extension TravelActiviesTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		if let count = travelActivities?.count {
			return count
		}
		return 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 4
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = Row(rawValue: indexPath.row)!

		guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
			fatalError()
		}

		let activity = travelActivities[indexPath.section]

		switch row {
		case .travelTypeRow:
			cell.detailTextLabel?.text = activity.travelType.capitalized
		case .partnerRow:
			if let partner = staticDataT2FEntity.findPartner(with: activity.partnerID) {
				cell.detailTextLabel?.text = partner.name
			} else {
				cell.detailTextLabel?.text = ""
			}
		case .partnershipRow:
			if let partnership = staticDataT2FEntity.findPartnership(with: activity.partnershipID) {
				cell.detailTextLabel?.text = partnership.name
			} else {
				cell.detailTextLabel?.text = ""
			}
		case .primaryTravelerRow:
			if activity.isPrimaryTraveler {
				cell.detailTextLabel?.text = "✓"
			} else {
				cell.detailTextLabel?.text = ""
			}
		}

		return cell
	}

	/// Returns title for section with its number starting from 1.
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "\(section + 1)"
	}
}

// MARK: - UITableViewDelegate
extension TravelActiviesTableViewController {
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 0 {
			return 34.0
		} else {
			return tableView.sectionHeaderHeight
		}
	}
}

// MARK: - ViewControllerFromStoryboard
extension TravelActiviesTableViewController: ViewControllerFromStoryboard {
	static func viewControllerFromStoryboard<T: UIViewController>() -> T? {
		let storyboard = UIStoryboard(name: Constants.Storyboard.Trips, bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? T
	}
}
