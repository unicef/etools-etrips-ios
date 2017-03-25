import UIKit

class TripInfoTableViewController: UITableViewController {
	private var observer: ManagedObjectObserver?
	public var tripEntity: TripEntity! {
		didSet {
			observer = ManagedObjectObserver(object: tripEntity, changeHandler: { [unowned self] type in
				if type == .update {
					self.dataSource.setupSections()
					self.dataSource.updateCurrency()
					self.tableView.reloadData()
				}
			})
		}
	}

	var rejectionNote: String?

	/// Static Data.
	public var staticDataEntity: StaticDataEntity!
	public var staticDataT2FEntity: StaticDataT2FEntity!

	var dataSource: TripInfoTableViewDataSource!

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		setupTableView()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: - IBActions
	@IBAction func tapGestureRecognizerAction(_: UITapGestureRecognizer) {
		view.endEditing(true)
	}

	// MARK: - Methods
	func setupTableView() {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 44

		dataSource = TripInfoTableViewDataSource(controller: self,
		                                         tripEntity: tripEntity,
		                                         staticData: staticDataEntity,
		                                         staticDataT2F: staticDataT2FEntity)

		tableView.dataSource = dataSource
		tableView.delegate = dataSource

		tableView.reloadData()
	}

	func showTravelActivities() {
		guard let travelActivitiesTableViewController =
			TravelActiviesTableViewController.viewControllerFromStoryboard() as? TravelActiviesTableViewController
		else {
			return
		}

		guard let travelActivities = tripEntity?.travelActivities, travelActivities.count > 0 else {
			return
		}

		travelActivitiesTableViewController.travelActivities = Array(travelActivities)
		travelActivitiesTableViewController.staticDataT2FEntity = staticDataT2FEntity

		let navigationController =
			UINavigationController(rootViewController: travelActivitiesTableViewController)

		present(navigationController, animated: true, completion: nil)
	}

	func showTravelItinerary() {
		guard let travelItineraryTableViewController =
			TravelItineraryTableViewController.viewControllerFromStoryboard() as? TravelItineraryTableViewController
		else {
			return
		}

		guard let travelItinerary = tripEntity?.travelItinerary, travelItinerary.count > 0 else {
			return
		}

		travelItineraryTableViewController.travelItinerary = Array(travelItinerary)

		let navigationController =
			UINavigationController(rootViewController: travelItineraryTableViewController)

		present(navigationController, animated: true, completion: nil)
	}

	func showCostAssignment() {
		guard let costAssignmentTableViewController =
			CostAssignmentTableViewController.viewControllerFromStoryboard() as? CostAssignmentTableViewController
		else {
			return
		}

		guard let costAssignments = tripEntity?.costAssignments, costAssignments.count > 0 else {
			return
		}

		costAssignmentTableViewController.costAssignments = Array(costAssignments)
		costAssignmentTableViewController.staticDataEntity = staticDataEntity

		let navigationController =
			UINavigationController(rootViewController: costAssignmentTableViewController)

		present(navigationController, animated: true, completion: nil)
	}
}

// MARK: - UITextViewDelegate
extension TripInfoTableViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		rejectionNote = textView.text
		tableView.beginUpdates()
		tableView.endUpdates()
	}
}
