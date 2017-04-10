import UIKit
import CoreData

protocol PersonSelectionTableViewControllerDelegate: class {
    func didSelectPerson(_ person: UserEntity)
}

class PersonSelectionTableViewController: UITableViewController {
    /// Services.
    var usersService: UsersService = UsersService()

    /// Data.
    typealias Data = FetchedResultsDataProvider<PersonSelectionTableViewController>
    var dataSource: TableViewDataSource<PersonSelectionTableViewController, Data, PersonTableViewCell>!

    /// Context.
    var managedObjectContext = CoreDataStack.shared.managedObjectContext

    /// Delegate.
    weak var delegate: PersonSelectionTableViewControllerDelegate?
    
    /// Search Controller.
    let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup.
        setupSearchController()
        setupTableViewDataSource()
        setupRefreshControl()
        
        if dataSource.isEmpty {
            downloadUsers()
        }
    }

    // MARK: - Methods
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()

        guard let refreshControl = refreshControl else {
            return
        }

        refreshControl.addTarget(self,
                                 action: #selector(PersonSelectionTableViewController.handleRefresh(refreshControl:)),
                                 for: UIControlEvents.valueChanged)

        if dataSource.isEmpty {
            tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated: true)
            refreshControl.beginRefreshing()
        }
    }

    func setupTableViewDataSource() {
        // Trips Fetch Request.
        let usersFetchRequest = UserEntity.sortedFetchRequest
        usersFetchRequest.fetchBatchSize = 20
        usersFetchRequest.returnsObjectsAsFaults = false
        
        if searchController.isActive && searchController.searchBar.text != "" {
            let searchString = searchController.searchBar.text!
            let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchString)
            usersFetchRequest.predicate = predicate
        }
        
        let fetchedResultsController =
            NSFetchedResultsController(fetchRequest: usersFetchRequest,
                                       managedObjectContext: managedObjectContext,
                                       sectionNameKeyPath: nil,
                                       cacheName: nil)
        
        let dataProvider = FetchedResultsDataProvider(fetchedResultsController: fetchedResultsController,
                                                      delegate: self)
        
        dataSource = TableViewDataSource(tableView: tableView, dataProvider: dataProvider, delegate: self)
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        downloadUsers()
    }
    
    func downloadUsers() {
        usersService.downloadUsers { _ in
            self.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - UITableViewDelegate
extension PersonSelectionTableViewController {
    override func tableView(_: UITableView, didSelectRowAt _: IndexPath) {

        guard let user = dataSource.selectedObject else { fatalError("Showing detail, but no selected row?") }
        delegate?.didSelectPerson(user)

        _ = navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
}

// MARK: - ViewControllerFromStoryboard
extension PersonSelectionTableViewController: ViewControllerFromStoryboard {
    static func viewControllerFromStoryboard<T: UIViewController>() -> T? {
        let storyboard = UIStoryboard(name: Constants.Storyboard.ActionPoints, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? T
    }
}

// MARK: - DataProviderDelegate
extension PersonSelectionTableViewController: DataProviderDelegate {
    typealias Object = UserEntity

    func dataProviderDidUpdate() {
        refreshControl?.endRefreshing()
        dataSource.processUpdates()
    }
}

// MARK: - DataSourceDelegate
extension PersonSelectionTableViewController: DataSourceDelegate {
    func cellIdentifierForObject(object: UserEntity) -> String {
        return String(describing: PersonTableViewCell.self)
    }
}

// MARK: - UISearchResultsUpdating
extension PersonSelectionTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        dataSource = nil
        setupTableViewDataSource()
        tableView.reloadData()
    }
}
