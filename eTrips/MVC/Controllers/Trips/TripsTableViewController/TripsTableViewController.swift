import UIKit

/// Displays `My Trips` trips.
class TripsTableViewController: TripsBaseTableViewController {

	// MARK: - Lifecycle
	override func awakeFromNib() {
		super.awakeFromNib()

		ThemeManager.shared.customize(item: navigationController?.tabBarItem, for: .tripsTab)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		setupTableViewDataSource(with: .myTrip)
		setupPaginator(with: .myTrip)
		self.tripsPaginator.fetchFirstPage()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: - Methods
	override func displayEmptyView() {
		let emptyView = EmptyView.instanceFromNib(with: UIImage(assetIdentifier: .tripsEmptyStateIcon),
		                                          text: "You don’t have any trips.",
		                                          subtitle: "All your trips will be displayed here.")
		emptyView.frame = self.tableView.bounds
		self.tableView.backgroundView = emptyView
	}
}
