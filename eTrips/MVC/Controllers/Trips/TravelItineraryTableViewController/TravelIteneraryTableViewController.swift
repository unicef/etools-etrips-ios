import UIKit

/// Displays "Travel Itinerary".
class TravelItineraryTableViewController: UITableViewController {
	public var travelItinerary: [TravelItineraryEntity]?

	fileprivate enum Row: Int {
		case originRow = 0
		case destinationRow
		case departRow
		case arriveRow
		case modeOfTravelRow

		var reuseIdentifier: String {
			switch self {
			case .originRow:
				return "OriginRowCell"
			case .destinationRow:
				return "DestinationRowCell"
			case .departRow:
				return "DepartRowCell"
			case .arriveRow:
				return "ArriveRowCell"
			case .modeOfTravelRow:
				return "ModeOfTravelRowCell"
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
		title = "Travel Itinerary"

		let closeBarButtonItem =
			UIBarButtonItem(title: "Close",
			                style: .plain,
			                target: self,
			                action: #selector(TravelItineraryTableViewController.closeBarButtonItemAction))

		navigationItem.rightBarButtonItem = closeBarButtonItem
	}
}

// MARK: - UITableViewDatasource
extension TravelItineraryTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		if let count = travelItinerary?.count {
			return count
		}
		return 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = Row(rawValue: indexPath.row)!

		guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
			fatalError()
		}

		let travel = travelItinerary?[indexPath.section]

		switch row {
		case .originRow:
			cell.detailTextLabel?.text = travel?.origin
		case .destinationRow:
			cell.detailTextLabel?.text = travel?.destination
		case .departRow:
			cell.detailTextLabel?.text = travel?.depart.mediumDateStyleString()
		case .arriveRow:
			cell.detailTextLabel?.text = travel?.arrive.mediumDateStyleString()
		case .modeOfTravelRow:
			cell.detailTextLabel?.text = travel?.modeOfTravel.capitalized
		}

		return cell
	}

	/// Returns title for section with its number starting from 1.
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "\(section + 1)"
	}
}

// MARK: - UITableViewDelegate
extension TravelItineraryTableViewController {
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 0 {
			return 34.0
		} else {
			return tableView.sectionHeaderHeight
		}
	}
}

// MARK: - ViewControllerFromStoryboard
extension TravelItineraryTableViewController: ViewControllerFromStoryboard {
	static func viewControllerFromStoryboard<T: UIViewController>() -> T? {
		let storyboard = UIStoryboard(name: Constants.Storyboard.Trips, bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? T
	}
}
