import UIKit
import CoreData
import Moya

protocol PersonSelectionTableViewControllerDelegate: class {
    func didSelectPerson(_ person: UserEntity)
}

class PersonSelectionTableViewController: UITableViewController {
    /// Services.
    var usersService: UsersService = UsersService()

    /// Data.
    typealias Data = FetchedResultsDataProvider<PersonSelectionTableViewController>
    var dataSource: TableViewDataSource<PersonSelectionTableViewController, Data, PersonTableViewCell>!

    /// Core Data Context.
    var managedObjectContext = CoreDataStack.shared.managedObjectContext

    /// Delegate.
    weak var delegate: PersonSelectionTableViewControllerDelegate?

    /// Search Controller.
    let searchController = UISearchController(searchResultsController: nil)

    /// Token for cancelling the request.
    var cancellableToken: Cancellable?

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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let cancellableToken = cancellableToken {
            cancellableToken.cancel()
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

        dataSource = TableViewDataSource(tableView: tableView,
                                         dataProvider: dataProvider,
                                         delegate: self,
                                         isSearch: searchController.isActive)
    }

    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }

    func handleRefresh(refreshControl _: UIRefreshControl) {
        downloadUsers()
    }

    func downloadUsers() {

        // Disable search when loading users.
        searchController.searchBar.isUserInteractionEnabled = false

        cancellableToken = usersService.downloadUsers { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.refreshControl?.endRefreshing()
                    let alert = UIAlertController(title: error.title,
                                                  message: error.detail,
                                                  preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK",
                                                 style: .cancel,
                                                 handler: nil)

                    alert.addAction(okAction)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    self.refreshControl?.endRefreshing()
                    self.searchController.searchBar.isUserInteractionEnabled = true
                    self.updateUI()
                }
            }
        }
    }

    private func updateUI() {
        setupTableViewDataSource()
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

        // Handle situation with refresh controll when search is active.
        if searchController.isActive {
            refreshControl?.endRefreshing()
            refreshControl = nil
        } else {
            setupRefreshControl()
        }

        tableView.reloadData()
    }
}
