import UIKit

class TripActionPointsTableViewController: UITableViewController {

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.tableFooterView = UIView()

		tableView.register(UINib(nibName: String(describing: ActionPointTableViewCell.self), bundle: nil),
		                   forCellReuseIdentifier: String(describing: ActionPointTableViewCell.self))

		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 44

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

}

// MARK: - UITableViewDatasource
extension TripActionPointsTableViewController {

	override func numberOfSections(in tableView: UITableView) -> Int {
		let messageLabel =
			UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))

		messageLabel.text = "In Development"
		messageLabel.textColor = UIColor.black
		messageLabel.numberOfLines = 0
		messageLabel.textAlignment = .center
		messageLabel.sizeToFit()

		tableView.backgroundView = messageLabel
		tableView.separatorStyle = .none

		return 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 100
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ActionPointTableViewCell.self)) {
			return cell
		} else {
			fatalError()
		}
	}
}

// MARK: - UITableViewDelegate
extension TripActionPointsTableViewController {

	override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
