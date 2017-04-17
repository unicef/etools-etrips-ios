import Foundation
import CoreData
import SwiftPaginator
import UIScrollView_InfiniteScroll

class TripsBaseTableViewController: UITableViewController {
    /// Static Data.
    var staticDataEntity: StaticDataEntity?
    var staticDataT2FEntity: StaticDataT2FEntity?

    /// Services.
    var tripsService: TripsService = TripsService()
    var tripsPaginator: Paginator<TripEntity>!

    /// Data.
    typealias Data = FetchedResultsDataProvider<TripsBaseTableViewController>
    var dataSource: TableViewDataSource<TripsBaseTableViewController, Data, TripTableViewCell>!

    /// Context.
    var managedObjectContext = CoreDataStack.shared.managedObjectContext

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetch Static Data 1.
        let staticDataRequest = NSFetchRequest<NSFetchRequestResult>(entityName: StaticDataEntity.entityName)
        let staticDataResult =
            try! managedObjectContext.fetch(staticDataRequest) as! [StaticDataEntity]
        staticDataEntity = staticDataResult.first

        // Fetch Static Data 2.
        let staticDataT2FRequest = NSFetchRequest<NSFetchRequestResult>(entityName: StaticDataT2FEntity.entityName)
        let staticDataT2FResult =
            try! managedObjectContext.fetch(staticDataT2FRequest) as! [StaticDataT2FEntity]
        staticDataT2FEntity = staticDataT2FResult.first

        setupRefreshControl()
        setupTableView()
    }

    // MARK: - IBActions
    @IBAction func profileBarButtonItemAction(_: UIBarButtonItem) {
        if let profileTableViewController = ProfileTableViewController.viewControllerFromStoryboard() {
            let navigationController =
                UINavigationController(rootViewController: profileTableViewController)

            present(navigationController, animated: true, completion: nil)
        }
    }

    // MARK: - Methods
    func handleRefresh(_: UIRefreshControl) {
        tripsPaginator.fetchFirstPage()
    }

    func hidePullToRefreshAndInfiniteScroll() {
        self.refreshControl?.endRefreshing()
        self.tableView.finishInfiniteScroll()
    }

    func setupPaginator(with tripType: TripType) {
        tripsPaginator =
            Paginator<TripEntity>(pageSize: 20,
                                  fetchHandler: { (_ paginator: Paginator, _ page: Int, _ pageSize: Int) in

                                      guard let userID = UserManager.shared.userID else {
                                          return
                                      }

                                      self.tripsService.downloadTrips(userID: userID,
                                                                      type: tripType,
                                                                      page: page,
                                                                      pageSize: pageSize) { success, totalCount, error in

                                          self.hidePullToRefreshAndInfiniteScroll()

                                          // Network Error.
                                          if let error = error {

                                              if paginator.total == 0 && self.tableView.numberOfRows(inSection: 0) == 0 {
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
                                          // Success.
                                          if success {
                                              paginator.received(results: [], total: totalCount!)
                                          } else {
                                              paginator.failed()
                                          }
                                      }
                                  },
                                  resultsHandler: { paginator, _ in

                                      // Update action points after loading first page of trips.
                                      if paginator.page == 1 {
                                          NotificationCenter.default
                                              .post(name: Notification.Name.TripsDidUpdatedNotification,
                                                    object: self)
                                      }

                                      // Empty state.
                                      if paginator.page == 1 && paginator.total == 0 {
                                          self.displayEmptyView()
                                      } else {
                                          self.tableView.backgroundView = nil
                                      }

                                      self.hidePullToRefreshAndInfiniteScroll()
                                  },
                                  resetHandler: { _ in
                                  },
                                  failureHandler: { _ in
                                      self.hidePullToRefreshAndInfiniteScroll()

            })

    }

    func setupTableView() {
        tableView.register(UINib(nibName: String(describing: TripTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: TripTableViewCell.self))

        tableView.tableFooterView = UIView()

        tableView.addInfiniteScroll { _ in

            if !self.tripsPaginator.reachedLastPage {
                self.tripsPaginator.fetchNextPage()
            } else {
                self.hidePullToRefreshAndInfiniteScroll()
            }
        }

        tableView.setShouldShowInfiniteScrollHandler { _ -> Bool in
            return !self.tripsPaginator.reachedLastPage
        }
    }

    func setupTableViewDataSource(with tripType: TripType) {
        // Trips Fetch Request.
        let tripsFetchRequest = TripEntity.sortedFetchRequest
        tripsFetchRequest.fetchBatchSize = 20
        tripsFetchRequest.returnsObjectsAsFaults = false
        tripsFetchRequest.predicate = NSPredicate(format: "typeValue == %d", tripType.rawValue)

        let fetchedResultsController =
            NSFetchedResultsController(fetchRequest: tripsFetchRequest,
                                       managedObjectContext: managedObjectContext,
                                       sectionNameKeyPath: nil,
                                       cacheName: nil)

        let dataProvider = FetchedResultsDataProvider(fetchedResultsController: fetchedResultsController,
                                                      delegate: self)

        dataSource = TableViewDataSource(tableView: tableView,
                                         dataProvider: dataProvider,
                                         delegate: self,
                                         isSearch: false)
    }

    func setupRefreshControl() {
        refreshControl = UIRefreshControl()

        guard let refreshControl = refreshControl else {
            return
        }

        refreshControl.addTarget(self,
                                 action: #selector(TripsBaseTableViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)

        tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated: true)
        refreshControl.beginRefreshing()
    }

    func displayEmptyView() {
        self.tableView.backgroundView = nil
    }
}

// MARK: - DataProviderDelegate
extension TripsBaseTableViewController: DataProviderDelegate {
    typealias Object = TripEntity

    func dataProviderDidUpdate() {
        refreshControl?.endRefreshing()
        dataSource.processUpdates()
    }
}

// MARK: - DataSourceDelegate
extension TripsBaseTableViewController: DataSourceDelegate {
    func cellIdentifierForObject(object: TripEntity) -> String {
        return String(describing: TripTableViewCell.self)
    }
}

// MARK: - UITableViewDelegate
extension TripsBaseTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }

    override func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
        if let tripDetailsViewController =
            TripDetailsViewController.viewControllerFromStoryboard() as? TripDetailsViewController {

            guard let trip = dataSource.selectedObject else { fatalError("Showing detail, but no selected row?") }
            tripDetailsViewController.tripEntity = trip
            tripDetailsViewController.staticDataEntity = staticDataEntity
            tripDetailsViewController.staticDataT2FEntity = staticDataT2FEntity
            navigationController?.pushViewController(tripDetailsViewController, animated: true)
        }
    }
}
