import Foundation
import UIKit

class TableViewDataSource<Delegate: DataSourceDelegate, Data: DataProvider, Cell: UITableViewCell>
    : NSObject, UITableViewDataSource
    where Delegate.Object == Data.Object, Cell: ConfigurableCell, Cell.DataSource == Data.Object {
    
    private let tableView: UITableView
    private weak var delegate: Delegate!
    private let dataProvider: Data
    private let isSearch: Bool
    
    required init(tableView: UITableView, dataProvider: Data, delegate: Delegate, isSearch: Bool) {
        self.tableView = tableView
        self.dataProvider = dataProvider
        self.delegate = delegate
        self.isSearch = isSearch
        super.init()
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    public var isEmpty: Bool {
        return dataProvider.numberOfItemsInSection(section: 0) == 0
    }
    
    var selectedObject: Data.Object? {
        guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
        return dataProvider.objectAtIndexPath(indexPath: indexPath)
    }
    
    func processUpdates() {
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource'
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = dataProvider.numberOfItemsInSection(section: section)
        
        if numberOfRows == 0 && isSearch == true {
            // Display a message when the table is empty
            let messageLabel = UILabel(frame:
                CGRect(origin: CGPoint(x: 0, y: 0), size:
                    CGSize(width: self.tableView.bounds.size.width,
                           height: self.tableView.bounds.size.height)))
            
            messageLabel.text = "No users found."
            messageLabel.textColor = UIColor.lightGray
            messageLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.sizeToFit()
            
            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = .none
            
            return 0
        } else {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
            return numberOfRows
        }
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
