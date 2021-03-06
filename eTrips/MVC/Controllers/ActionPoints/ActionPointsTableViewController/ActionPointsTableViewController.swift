import UIKit
import CoreData
import UIScrollView_InfiniteScroll
import SwiftPaginator

class ActionPointsTableViewController: UITableViewController {
    /// Service.
    var actionPointsService: ActionPointsService = ActionPointsService()
    
    /// Paginator.
    var actionPointsPaginator: Paginator<ActionPointEntity>?
    
    /// Data.
    fileprivate typealias Data = FetchedResultsDataProvider<ActionPointsTableViewController>
    fileprivate var dataSource: TableViewDataSource<ActionPointsTableViewController, Data, ActionPointTableViewCell>!
    
    /// Core Data Context.
    var managedObjectContext = CoreDataStack.shared.managedObjectContext
    
    /// Mode of the screen `myActionPoints`, `tripActionPoints`. (by default `myActionPoints`)
    public var mode: Mode = .myActionPoints
    enum Mode {
        case myActionPoints
        case tripActionPoints(Int64)
    }
    
    // MARK: - Lifecycle
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ThemeManager.shared.customize(item: navigationController?.tabBarItem, for: .actionPointsTab)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupFetchedResultsController()
        setupNotifications()
        
        switch mode {
        case .myActionPoints:
            
            setupRefreshControl()
            setupPaginator()
            
            self.actionPointsPaginator?.fetchFirstPage()
        default:
            break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch mode {
        case .tripActionPoints:
            if dataSource.isEmpty {
                displayEmptyView()
            } else {
                tableView.backgroundView = nil
            }
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBActions
    @IBAction func settingsBarButtonItemAction(_: UIBarButtonItem) {
        if let settingsTableViewController = SettingsTableViewController.viewControllerFromStoryboard() {
            present(settingsTableViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func profileBarButtonItemAction(_: UIBarButtonItem) {
        if let profileTableViewController = ProfileTableViewController.viewControllerFromStoryboard() {
            let navigationController =
                UINavigationController(rootViewController: profileTableViewController)
            
            present(navigationController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Methods
    func setupNotifications() {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(ActionPointsTableViewController.tripsDidUpdatedNotification(_:)),
                         name: Notification.Name.TripsDidUpdatedNotification,
                         object: nil)
    }
    
    func setupPaginator() {
        actionPointsPaginator =
            Paginator<ActionPointEntity>(pageSize: 20,
                                         fetchHandler: { (_ paginator: Paginator, _ page: Int, _ pageSize: Int) in
                                             
                                             guard let userID = UserManager.shared.userID else {
                                                 return
                                             }
                                             
                                             self.actionPointsService
                                                 .downloadActionPoints(userID: userID,
                                                                       page: page,
                                                                       pageSize: pageSize) { success, totalCount, error in
                                                     
                                                     self.hidePullToRefreshAndInfiniteScroll()
                                                     // Network Error.
                                                     if let error = error {
                                                         
                                                         if paginator.total == 0 &&
                                                             self.tableView.numberOfRows(inSection: 0) == 0 {
                                                             self.displayEmptyView()
                                                         } else {
                                                             self.tableView.backgroundView = nil
                                                         }
                                                         
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
                                                         
                                                     }
                                                     
                                                     if success {
                                                         paginator.received(results: [], total: totalCount!)
                                                     } else {
                                                         paginator.failed()
                                                     }
                                                 }
                                             
                                         },
                                         resultsHandler: { paginator, _ in
                                             
                                             // Empty state.
                                             if paginator.page == 1 && paginator.total == 0 {
                                                 self.displayEmptyView()
                                             } else {
                                                 self.tableView.backgroundView = nil
                                             }
                                             
                                             self.refreshControl?.endRefreshing()
                                             self.tableView.finishInfiniteScroll()
                                         },
                                         resetHandler: { _ in
                                             self.tableView.finishInfiniteScroll()
                                         },
                                         failureHandler: { _ in
                                             self.tableView.finishInfiniteScroll()
                                             
            })
        
    }
    
    func hidePullToRefreshAndInfiniteScroll() {
        self.refreshControl?.endRefreshing()
        self.tableView.finishInfiniteScroll()
    }
    
    func pullToRefresh(_: UIRefreshControl) {
        actionPointsPaginator?.fetchFirstPage()
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: String(describing: ActionPointTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: ActionPointTableViewCell.self))
        
        tableView.tableFooterView = UIView()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        tableView.addInfiniteScroll { _ in
            
            guard let isLastPageFlag = self.actionPointsPaginator?.reachedLastPage else {
                
                self.tableView.finishInfiniteScroll()
                return
            }
            
            if isLastPageFlag {
                self.tableView.finishInfiniteScroll()
            } else {
                self.actionPointsPaginator?.fetchNextPage()
            }
        }
        
        tableView.setShouldShowInfiniteScrollHandler { _ -> Bool in
            
            guard let isLastPageFlag = self.actionPointsPaginator?.reachedLastPage else {
                return false
            }
            return !isLastPageFlag
        }
    }
    
    func setupFetchedResultsController() {
        
        // Trips Fetch Request.
        let actionPointsFetchRequest = ActionPointEntity.sortedFetchRequest
        actionPointsFetchRequest.fetchBatchSize = 20
        actionPointsFetchRequest.returnsObjectsAsFaults = false
        actionPointsFetchRequest.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)]
        
        switch mode {
        case .myActionPoints:
            if let userID = UserManager.shared.userID {
                actionPointsFetchRequest.predicate = NSPredicate(format: "personResponsibleID == %d", userID)
            }
        case .tripActionPoints(let tripID):
            actionPointsFetchRequest.predicate = NSPredicate(format: "tripID == %d", tripID)
        }
        
        let fetchedResultsController =
            NSFetchedResultsController(fetchRequest: actionPointsFetchRequest,
                                       managedObjectContext: self.managedObjectContext,
                                       sectionNameKeyPath: nil,
                                       cacheName: nil)
        
        let dataProvider = FetchedResultsDataProvider(fetchedResultsController: fetchedResultsController,
                                                      delegate: self)
        dataSource = TableViewDataSource(tableView: tableView,
                                         dataProvider: dataProvider,
                                         delegate: self,
                                         isSearch: false)
        
        if dataSource.isEmpty {
            switch mode {
            case .myActionPoints:
                displayEmptyView()
            default:
                break
            }
        }
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        
        guard let refreshControl = refreshControl else {
            return
        }
        
        refreshControl.addTarget(self,
                                 action: #selector(ActionPointsTableViewController.pullToRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        
        tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated: true)
        refreshControl.beginRefreshing()
    }
    
    func displayEmptyView() {
        let text = "You don’t have any Action Points."
        let subtitle = "Your Action Points will be displayed here."
        
        let emptyView = EmptyView.instanceFromNib(with: UIImage(assetIdentifier: .actionPointsEmptyStateIcon),
                                                  text: text,
                                                  subtitle: subtitle)
        emptyView.frame = self.tableView.bounds
        self.tableView.backgroundView = emptyView
    }
    
    // MARK: - Notifications
    func tripsDidUpdatedNotification(_: Notification) {
        switch mode {
        case .myActionPoints:
            self.actionPointsPaginator?.fetchFirstPage()
        default:
            break
        }
    }
}

// MARK: - DataProviderDelegate
extension ActionPointsTableViewController: DataProviderDelegate {
    typealias Object = ActionPointEntity
    
    func dataProviderDidUpdate() {
        refreshControl?.endRefreshing()
        dataSource.processUpdates()
        
        if dataSource.isEmpty {
            displayEmptyView()
        } else {
            tableView.backgroundView = nil
        }
    }
}

// MARK: - DataSourceDelegate
extension ActionPointsTableViewController: DataSourceDelegate {
    func cellIdentifierForObject(object: ActionPointEntity) -> String {
        return String(describing: ActionPointTableViewCell.self)
    }
}

// MARK: - UITableViewDelegate
extension ActionPointsTableViewController {
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let pointDetailsController =
            ActionPointDetailsTableViewController.viewControllerFromStoryboard()
            as? ActionPointDetailsTableViewController {
            
            guard let point = dataSource.selectedObject else { fatalError("Showing detail, but no selected row?") }
            pointDetailsController.delegate = self
            pointDetailsController.actionPoint = point
            navigationController?.pushViewController(pointDetailsController, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ActionPointsTableViewController: ActionPointDetailsTableViewControllerDelegate {
    func didUpdateActionPoint(_: ActionPointEntity) {
        dataSource.processUpdates()
    }
    
    func didAddNewActionPoint() {
        dataSource.processUpdates()
    }
}
