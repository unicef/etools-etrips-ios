import UIKit
import CoreData

class SettingsTableViewController: UITableViewController {

  var profileEntity: ProfileEntity?

  fileprivate enum SectionType {
    case generalSettingsSection
    case logOutSection
  }

  fileprivate enum Row {
    case languageRow
    case countryRow
    case logOutRow

    var reuseIdentifier: String {
      switch self {
      case .languageRow:
        return "LanguageRowCell"
      case .countryRow:
        return "CountryRowCell"
      case .logOutRow:
        return "LogOutRowCell"
      }
    }
  }

  fileprivate struct Section {
    var type: SectionType
    var rows: [Row]
  }

  fileprivate var sections = [Section]()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    if let profile = ProfileEntity.profileEntityForLoggedInUser(in: CoreDataStack.shared.managedObjectContext) {
      profileEntity = profile

      sections = [Section(type: .generalSettingsSection, rows: [.languageRow]),
        Section(type: .logOutSection, rows: [.logOutRow])]

      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 44

      tableView.reloadData()
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  // MARK: - IBActions
  @IBAction func closeBarButtonItemAction(_: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }

  func showLogOutActionSheet(at indexPath: IndexPath) {
    let alert = UIAlertController(title: "",
      message: "Are you sure you want to log out?",
      preferredStyle: UIAlertControllerStyle.actionSheet)

    alert.modalPresentationStyle = .popover

    let logOutAction = UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
      self?.dismiss(animated: true, completion: {
        NotificationCenter.default.post(name: Notification.Name.UserDidLogOutNotification, object: self)
        return
      })
    })

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

    alert.addAction(logOutAction)
    alert.addAction(cancelAction)

    if let popoverPresentationController = alert.popoverPresentationController {
      popoverPresentationController.sourceView = tableView.cellForRow(at: indexPath)
      popoverPresentationController.sourceRect = (tableView.cellForRow(at: indexPath)?.bounds)!
      popoverPresentationController.permittedArrowDirections = .any
    }

    present(alert, animated: true, completion: nil)
  }

}

// MARK: - UITableViewDatasource
extension SettingsTableViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].rows.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let section = sections[indexPath.section]
    let row = section.rows[indexPath.row]

    guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
      fatalError()
    }

    switch row {
    case .languageRow:
      return cell
    case .countryRow:
      cell.detailTextLabel?.text = (profileEntity?.country)!
      return cell
    case .logOutRow:
      return cell
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch sections[section].type {
    case .generalSettingsSection:
      return nil
    case .logOutSection:
      return "YOU LOGGED AS \((profileEntity?.firstName)!) \((profileEntity?.lastName)!)"
    }
  }
}

// MARK: - UITableViewDelegate
extension SettingsTableViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    tableView.deselectRow(at: indexPath, animated: true)

    let section = sections[indexPath.section]
    let row = section.rows[indexPath.row]

    switch row {
    case .languageRow:
      break
    case .countryRow:
      break
    case .logOutRow:
      showLogOutActionSheet(at: indexPath)
    }
  }
}

// MARK: - ViewControllerFromStoryboard
extension SettingsTableViewController: ViewControllerFromStoryboard {
  static func viewControllerFromStoryboard<T: UIViewController>() -> T? {
    let storyboard = UIStoryboard(name: Constants.Storyboard.Settings, bundle: nil)
    return storyboard.instantiateInitialViewController() as? T
  }

}
