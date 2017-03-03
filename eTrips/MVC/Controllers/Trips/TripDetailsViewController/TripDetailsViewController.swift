import UIKit
import MBProgressHUD

/// Manages controllers for displaying "Trips Info", "Trip Report", "Trip Action Points".
class TripDetailsViewController: UIViewController {

	var tripService: TripService = TripService()
	var networkConnection: NetworkConnection = NetworkConnection()
	var actionPointsController: ActionPointsTableViewController?

	/// Managed Object Observer.
	private var observer: ManagedObjectObserver?
	public var tripEntity: TripEntity! {
		didSet {
			observer = ManagedObjectObserver(object: tripEntity) { [unowned self] type in
				if type == .update {
					self.setupSegmentedControl()
				}
			}
		}
	}

	private var addActionPointButton: UIBarButtonItem {
		let selector = #selector(addActionPointButtonAction)
		let btn = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: selector)
		return btn
	}

	enum SegueIdentifier: String {
		case tripInfoSegue = "TripInfoSegue"
		case tripReportSegue = "TripReportSegue"
		case tripActionPointsSegue = "TripActionPointsSegue"
	}

	enum Segment: Int {
		case tripSegment = 0
		case reportSegment
		case actionPointsSegment
	}

	/// Static data.
	public var staticDataEntity: StaticDataEntity!
	public var staticDataT2FEntity: StaticDataT2FEntity!

	/// Outlets.
	@IBOutlet var tripInfoContainerView: UIView!
	@IBOutlet var tripReportContainerView: UIView!
	@IBOutlet var tripActionPointsContainerView: UIView!
	@IBOutlet var segmentedControl: UISegmentedControl!

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		title = tripEntity.referenceNumber

		setupNavigationBar()
		setupSegmentedControl()

		navigationController?.interactivePopGestureRecognizer?.isEnabled = false

		let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
		tripService.downloadTrip(tripID: Int(tripEntity.tripID)) { _ in
			hud.hide(animated: true)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: - IBActions
	@IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {

		let selectedSegment = Segment(rawValue: sender.selectedSegmentIndex)!

		switch selectedSegment {
		case .tripSegment:
			tripInfoContainerView.alpha = 1
			tripReportContainerView.alpha = 0
			tripActionPointsContainerView.alpha = 0
			navigationItem.rightBarButtonItem = nil
		case .reportSegment:
			tripInfoContainerView.alpha = 0
			tripReportContainerView.alpha = 1
			tripActionPointsContainerView.alpha = 0
			navigationItem.rightBarButtonItem = nil
		case .actionPointsSegment:
			tripInfoContainerView.alpha = 0
			tripReportContainerView.alpha = 0
			tripActionPointsContainerView.alpha = 1

			if tripEntity.type == .myTrip {
				navigationItem.rightBarButtonItem = addActionPointButton
			}
		}

		view.endEditing(true)
	}
	
	func addActionPointButtonAction() {

		if !networkConnection.isNetworkReachable() {
			let alert = UIAlertController(title: "Error",
			                              message: "The Internet connection appears to be offline.",
			                              preferredStyle: .alert)
			let okAction = UIAlertAction(title: "OK",
			                             style: .cancel,
			                             handler: nil)

			alert.addAction(okAction)

			present(alert, animated: true, completion: nil)
			return
		}

		if let pointDetailsController =
			ActionPointDetailsTableViewController.viewControllerFromStoryboard()
			as? ActionPointDetailsTableViewController {
			pointDetailsController.delegate = actionPointsController
			pointDetailsController.isNewPoint = true
			pointDetailsController.tripEntity = tripEntity

			let navigationController = UINavigationController.init(rootViewController: pointDetailsController)
			present(navigationController, animated: true, completion: nil)
		}
	}

	// MARK: - Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		guard let identifier = segue.identifier, let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
			fatalError("Invalid segue identifier \(segue.identifier)")
		}

		switch segueIdentifier {
		case .tripInfoSegue:
			if let tripInfoTableViewController = segue.destination as? TripInfoTableViewController {
				tripInfoTableViewController.staticDataEntity = staticDataEntity
				tripInfoTableViewController.staticDataT2FEntity = staticDataT2FEntity
				tripInfoTableViewController.tripEntity = tripEntity
			}
		case .tripReportSegue:
			if let tripReportTableViewController = segue.destination as? TripReportTableViewController {
				tripReportTableViewController.tripEntity = tripEntity
			}
		case .tripActionPointsSegue:
			if let actionPointsTableViewController = segue.destination as? ActionPointsTableViewController {
				actionPointsTableViewController.tripID = tripEntity.tripID
				actionPointsController = actionPointsTableViewController
			}
		}
	}

	// MARK: - Methods
	func setupNavigationBar() {
		navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		navigationController?.navigationBar.shadowImage = UIImage()
	}

	func setupSegmentedControl() {
		if tripEntity.isReportSubmitted {
			segmentedControl.setTitle("Report ✔︎", forSegmentAt: Segment.reportSegment.rawValue)
		} else {
			if tripEntity.isDraft {
				segmentedControl.setTitle("Report -", forSegmentAt: Segment.reportSegment.rawValue)
			} else {
				segmentedControl.setTitle("Report ", forSegmentAt: Segment.reportSegment.rawValue)
			}
		}

		if let actionPoints = tripEntity.actionPoints {

			if actionPoints.count > 0 {
				segmentedControl.setTitle("Action Points (\(actionPoints.count)) ",
				                          forSegmentAt: Segment.actionPointsSegment.rawValue)
			} else {
				segmentedControl.setTitle("Action Points", forSegmentAt: Segment.actionPointsSegment.rawValue)
			}
		} else {
			segmentedControl.setTitle("Action Points", forSegmentAt: Segment.actionPointsSegment.rawValue)
		}
	}
}

// MARK: - ViewControllerFromStoryboard
extension TripDetailsViewController: ViewControllerFromStoryboard {
	static func viewControllerFromStoryboard<T: UIViewController>() -> T? {
		let storyboard = UIStoryboard(name: Constants.Storyboard.Trips, bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? T
	}
}
