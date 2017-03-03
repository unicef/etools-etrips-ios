import UIKit

/// Displays `Supervised` trips.
class SupervisedTableViewController: TripsBaseTableViewController {

	// MARK: - Lifecycle
	override func awakeFromNib() {
		super.awakeFromNib()

		ThemeManager.shared.customize(item: navigationController?.tabBarItem, for: .supervisedTab)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		setupTableViewDataSource(with: .supervised)
		setupPaginator(with: .supervised)
		self.tripsPaginator.fetchFirstPage()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: - Methods
	override func displayEmptyView() {
		let emptyView =
			EmptyView.instanceFromNib(with: UIImage(assetIdentifier: .supervisedEmptyStateIcon),
			                          text: "You're not currently supervising any trips.",
			                          subtitle: "Trips you're supervising will be displayed here when created.")
		emptyView.frame = self.tableView.bounds
		self.tableView.backgroundView = emptyView
	}
}
