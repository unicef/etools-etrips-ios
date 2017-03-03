import UIKit

protocol PersonSelectionTableViewControllerDelegate: class {
    func didSelectPerson(_ person: UserEntity)
}

class PersonSelectionTableViewController: UITableViewController {
    
    var usersService: UsersService = UsersService()
    
    var selectedPersonId: Int64? {
        didSet {
            if let index = usersInfo.find({ $0.userID == oldValue }) {
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
    
    var usersInfo = [UserEntity]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    weak var delegate: PersonSelectionTableViewControllerDelegate?

	// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
        loadUsersInfo()

        refreshControl?.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: .valueChanged)
    }
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        usersService.downloadUsers { _ in
            self.loadUsersInfo()
            refreshControl.endRefreshing()
        }
    }
}

// MARK: - UITableViewDataSource
extension PersonSelectionTableViewController {
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersInfo.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UsertCellID", for: indexPath)
        
        let user = usersInfo[indexPath.row]
        cell.textLabel?.text = "\(user.fullName)"
        
        if let _ = selectedPersonId {
            cell.accessoryType = user.userID == selectedPersonId! ? .checkmark : .none
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PersonSelectionTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            selectedPersonId = usersInfo[indexPath.row].userID
			
			        if let index = tableView.indexPathForSelectedRow {
            delegate?.didSelectPerson(usersInfo[index.row])
        }
			
			_ = navigationController?.popViewController(animated: true)
			
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
}

// MARK: Loading users info from DB
extension PersonSelectionTableViewController {
    func loadUsersInfo() {
        let context = CoreDataStack.shared.managedObjectContext
        usersInfo = UserEntity.fetch(in: context).sorted { $0.fullName < $1.fullName }
    }
}

// MARK: - ViewControllerFromStoryboard
extension PersonSelectionTableViewController: ViewControllerFromStoryboard {
    static func viewControllerFromStoryboard<T: UIViewController>() -> T? {
        let storyboard = UIStoryboard(name: Constants.Storyboard.ActionPoints, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? T
    }
}
