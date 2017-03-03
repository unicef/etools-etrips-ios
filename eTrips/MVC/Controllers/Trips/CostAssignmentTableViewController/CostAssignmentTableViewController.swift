import UIKit

class CostAssignmentTableViewController: UITableViewController {
	public var costAssignments: [CostAssignmentEntity]?
	public var staticDataEntity: StaticDataEntity!

	fileprivate enum Row: Int {
		case WBSRow = 0
		case grantRow
		case fundRow
		case shareRow

		var reuseIdentifier: String {
			switch self {
			case .WBSRow:
				return "WBSRowCell"
			case .grantRow:
				return "GrantRowCell"
			case .fundRow:
				return "FundRowCell"
			case .shareRow:
				return "ShareRowCell"
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
		// Dispose of any resources that can be recreated.
	}

	// MARK: - IBActions

	func closeBarButtonItemAction() {
		dismiss(animated: true, completion: nil)
	}

	// MARK: - Private

	func setupNavigationBar() {
		title = "Cost Assignment"
		
		let closeBarButtonItem =
			UIBarButtonItem(title: "Close",
							style: .plain,
			                target: self,
			                action: #selector(CostAssignmentTableViewController.closeBarButtonItemAction))
		
		navigationItem.rightBarButtonItem = closeBarButtonItem
	}
}

// MARK: - UITableViewDatasource
extension CostAssignmentTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {

		if let count = costAssignments?.count {
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

		let costAssignment = costAssignments?[indexPath.section]

		switch row {
		case .WBSRow:
			let wbs = staticDataEntity.findWBS(with: (costAssignment?.wbsID)!)
			cell.detailTextLabel?.text = wbs?.name
		case .grantRow:
			let grant = staticDataEntity.findGrant(with: (costAssignment?.grantID)!)
			cell.detailTextLabel?.text = grant?.name
		case .fundRow:
			let fund = staticDataEntity.findFund(with: (costAssignment?.fundID)!)
			cell.detailTextLabel?.text = fund?.name
		case .shareRow:
			cell.detailTextLabel?.text = "\((costAssignment?.share)!)%"

		}

		return cell
	}
}

// MARK: - ViewControllerFromStoryboard
extension CostAssignmentTableViewController: ViewControllerFromStoryboard {
	static func viewControllerFromStoryboard<T: UIViewController>() -> T? {
		let storyboard = UIStoryboard(name: Constants.Storyboard.Trips, bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? T
	}
}
