import Foundation
import UIKit

class TableViewDataSource<Delegate: DataSourceDelegate, Data: DataProvider, Cell: UITableViewCell>
	: NSObject, UITableViewDataSource
	where Delegate.Object == Data.Object, Cell: ConfigurableCell, Cell.DataSource == Data.Object {

	private let tableView: UITableView
	private weak var delegate: Delegate!
	private let dataProvider: Data

	required init(tableView: UITableView, dataProvider: Data, delegate: Delegate) {
		self.tableView = tableView
		self.dataProvider = dataProvider
		self.delegate = delegate
		super.init()
		tableView.dataSource = self
		tableView.reloadData()
	}
	
	var selectedObject: Data.Object? {
        guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
        return dataProvider.objectAtIndexPath(indexPath: indexPath)
    }

	func processUpdates() {
		tableView.reloadData()
	}

	// MARK: - UITableViewDataSource
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataProvider.numberOfItemsInSection(section: section)
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let object = dataProvider.objectAtIndexPath(indexPath: indexPath)
		let identifier = delegate.cellIdentifierForObject(object: object)
		guard let cell =
			tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Cell else {
			fatalError("Unexpected cell type at \(indexPath)")
		}
		cell.configureForObject(object: object)
		return cell
	}
}
