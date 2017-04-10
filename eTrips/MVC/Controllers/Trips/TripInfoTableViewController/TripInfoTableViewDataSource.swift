import Foundation
import MBProgressHUD

class TripInfoTableViewDataSource: NSObject {
	public var tripEntity: TripEntity!

	var transitionService = TransitionService()

	fileprivate weak var controller: TripInfoTableViewController?
    
    var managedObjectContex = CoreDataStack.shared.managedObjectContext
	var currency: CurrencyEntity?

	fileprivate enum SectionType {
		case travelerSection
		case supervisorSection
		case datesSection
		case purposeOfTravelSection
		case statusSection
		case travelDetailsSection
		case costSummarySection
	}

	fileprivate enum Row {
		case travelerRow
		case supervisorRow
		case datesRow
		case purposeOfTravelRow
		case statusRow
		case rejectRow
		case rejectionNoteRow
		case travelActivitiesRow
		case travelItineraryRow
		case travelCostAssigmentRow
		case dsaTotalRow
		case expenseTotalRow
		case deductionsTotalRow
		case totalCostRow

		var reuseIdentifier: String {
			switch self {
			case .travelerRow:
				return "TravelerRowCell"
			case .supervisorRow:
				return "SupervisorRowCell"
			case .datesRow:
				return "DatesRowCell"
			case .purposeOfTravelRow:
				return "PurposeOfTravelRowCell"
			case .statusRow:
				return "StatusRowCell"
			case .rejectRow:
				return "RejectRowCell"
			case .rejectionNoteRow:
				return String(describing: TripRejectionNoteTableViewCell.self)
			case .travelActivitiesRow:
				return "TravelActivitiesRowCell"
			case .travelItineraryRow:
				return "TravelItineraryRowCell"
			case .travelCostAssigmentRow:
				return "TravelCostAssigmentRowCell"
			case .dsaTotalRow:
				return "DSATotalRowCell"
			case .expenseTotalRow:
				return "ExpenseTotalRowCell"
			case .deductionsTotalRow:
				return "DeductionsTotalRowCell"
			case .totalCostRow:
				return "TotalCostRowCell"
			}
		}
	}

	fileprivate struct Section {
		var type: SectionType
		var rows: [Row]
	}

	fileprivate var sections = [Section]()

	/// Static Data.
	public var staticDataEntity: StaticDataEntity!
	public var staticDataT2FEntity: StaticDataT2FEntity!

	// MARK: - Init
	required init(controller: TripInfoTableViewController,
	              tripEntity: TripEntity,
	              staticData: StaticDataEntity,
	              staticDataT2F: StaticDataT2FEntity) {
		self.controller = controller
		self.tripEntity = tripEntity
		self.staticDataEntity = staticData
		self.staticDataT2FEntity = staticDataT2F
		super.init()
		setupSections()
	}

	// MARK: - Methods
	func setupSections() {
		sections.removeAll()

		// `Traveler` section.
		sections.append(Section(type: .travelerSection, rows: [.travelerRow]))

		// `Supervisor` section.
		sections.append(Section(type: .supervisorSection, rows: [.supervisorRow]))

		// `Dates` section.
		sections.append(Section(type: .datesSection, rows: [.datesRow]))

		// `Purpose` section.
		sections.append(Section(type: .purposeOfTravelSection, rows: [.purposeOfTravelRow]))

		// `Status` section.
		if (tripEntity.status == "submitted" || tripEntity.status == "certification_submitted")
			&& tripEntity.type == .supervised {
			sections.append(Section(type: .statusSection, rows: [.statusRow, .rejectRow, .rejectionNoteRow]))
		} else if tripEntity.status == "rejected" || tripEntity.status == "certification_rejected" {

			if let rejectionNote = tripEntity.rejectionNote {

				if !rejectionNote.isEmpty {
					sections.append(Section(type: .statusSection, rows: [.statusRow, .rejectionNoteRow]))
				} else {
					sections.append(Section(type: .statusSection, rows: [.statusRow]))
				}
			} else {
				sections.append(Section(type: .statusSection, rows: [.statusRow]))
			}
		} else {
			sections.append(Section(type: .statusSection, rows: [.statusRow]))
		}

		// `Travel Details` section.
		sections.append(Section(type: .travelDetailsSection,
		                        rows: [.travelActivitiesRow, .travelItineraryRow, .travelCostAssigmentRow]))

		// `Cost Summary` section.
		sections.append(Section(type: .costSummarySection,
		                        rows: [.dsaTotalRow, .expenseTotalRow, .deductionsTotalRow, .totalCostRow]))

	}

	func updateCurrency() {
        currency = CurrencyEntity.findCurrency(with: tripEntity.currencyID, in: managedObjectContex)
	}
}

// MARK: - UITableViewDataSource
extension TripInfoTableViewDataSource: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].rows.count
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch sections[section].type {
		case .travelerSection:
			return "TRAVELER"
		case .supervisorSection:
			return "SUPERVISOR"
		case .datesSection:
			return "DATES"
		case .purposeOfTravelSection:
			return "PURPOSE OF TRAVEL"
		case .statusSection:
			return tripEntity.statusTitleHeader
		case .travelDetailsSection:
			return nil
		case .costSummarySection:
			return "COST SUMMARY"
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]

		switch row {
		case .travelerRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
				fatalError()
			}
			cell.textLabel?.text = tripEntity?.travelerName
			return cell
		case .supervisorRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
				fatalError()
			}
			cell.textLabel?.text = tripEntity.supervisorName
			return cell
		case .datesRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
				fatalError()
			}
			cell.textLabel?.text = tripEntity?.fromDateToDateString
			return cell
		case .purposeOfTravelRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
				fatalError()
			}
			cell.textLabel?.text = tripEntity?.purposeOfTravel
			return cell
		case .statusRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
				fatalError()
			}
			let (text, color) = tripEntity.statusRowData
			cell.textLabel?.text = text
			cell.textLabel?.textColor = color
			return cell
		case .rejectRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
				fatalError()
			}
			cell.textLabel?.text = "Reject"
			cell.textLabel?.textColor = ThemeManager.shared.theme.rejectedTripColor
			return cell
		case .rejectionNoteRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier)
				as? TripRejectionNoteTableViewCell else {
				fatalError()
			}

			if tripEntity.status == "rejected" || tripEntity.status == "certification_rejected" {
				cell.textView.text = tripEntity.rejectionNote
				cell.textView.isUserInteractionEnabled = false
			} else {
				cell.textView.isUserInteractionEnabled = true
			}

			cell.textView.delegate = controller
			return cell
		case .travelActivitiesRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
				fatalError()
			}
			guard let count = tripEntity.travelActivities?.count else {
				return cell
			}
			cell.detailTextLabel?.text = count > 0 ? "\(count)" : ""
			return cell
		case .travelItineraryRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
				fatalError()
			}
			guard let count = tripEntity.travelItinerary?.count else {
				return cell
			}
			cell.detailTextLabel?.text = count > 0 ? "\(count)" : ""
			return cell
		case .travelCostAssigmentRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
				fatalError()
			}
			guard let count = tripEntity.costAssignments?.count else {
				return cell
			}
			cell.detailTextLabel?.text = count > 0 ? "\(count)" : ""
			return cell
		case .dsaTotalRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
				fatalError()
			}
			if let dsaTotal = tripEntity.costSummary?.dsaTotal {
				cell.detailTextLabel?.text = "\(dsaTotal) \(currency?.code ?? "")"
			} else {
				cell.detailTextLabel?.text = ""
			}
			return cell
		case .expenseTotalRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
				fatalError()
			}
			if let expensesTotal = tripEntity.costSummary?.expensesTotal {
				cell.detailTextLabel?.text = "\(expensesTotal) \(currency?.code ?? "")"
			} else {
				cell.detailTextLabel?.text = ""
			}
			return cell
		case .deductionsTotalRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
				fatalError()
			}
			if let deductionsTotal = tripEntity.costSummary?.deductionsTotal {
				cell.detailTextLabel?.text = "- \(deductionsTotal) \(currency?.code ?? "")"
			} else {
				cell.detailTextLabel?.text = ""
			}
			return cell
		case .totalCostRow:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier) else {
				fatalError()
			}
			if let totalCost = tripEntity.costSummary?.totalCost?.format(f: ".2") {
				cell.detailTextLabel?.text = "\(totalCost) \(currency?.code ?? "")"
			} else {
				cell.detailTextLabel?.text = ""
			}
			return cell
		}
	}

}

// MARK: - UITableViewDelegate
extension TripInfoTableViewDataSource: UITableViewDelegate {
	func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
		controller?.tableView.deselectRow(at: indexPath, animated: true)

		let section = sections[indexPath.section]
		let row = section.rows[indexPath.row]

		switch row {
		case .travelerRow, .supervisorRow, .datesRow, .purposeOfTravelRow,
		     .dsaTotalRow, .expenseTotalRow, .deductionsTotalRow, .totalCostRow, .rejectionNoteRow:
			break
		case .statusRow:
			switch tripEntity.status {
			case "planned":
				// Move from `Planned` to `Submitted`.
				if tripEntity.type == .myTrip {
					let hud = MBProgressHUD.showAdded(to: (controller?.navigationController?.view)!, animated: true)
					transitionService.transition(tripID: Int(tripEntity.tripID),
					                             transition: .submitForApproval,
					                             rejectionNote: nil) { _, error in

						if let error = error {
							let alert = UIAlertController(title: error.title,
							                              message: error.detail,
							                              preferredStyle: .alert)
							let okAction = UIAlertAction(title: "OK",
							                             style: .cancel,
							                             handler: nil)

							alert.addAction(okAction)

							self.controller?.present(alert, animated: true, completion: nil)
						}
						hud.hide(animated: true)
					}
				}
			case "submitted":
				// Move from `Submitted` to `Approved`.
				if tripEntity.type == .supervised {
					let hud = MBProgressHUD.showAdded(to: (controller?.navigationController?.view)!, animated: true)
					transitionService.transition(tripID: Int(tripEntity.tripID),
					                             transition: .approve,
					                             rejectionNote: nil) { _, error in
						if let error = error {
							let alert = UIAlertController(title: error.title,
							                              message: error.detail,
							                              preferredStyle: .alert)
							let okAction = UIAlertAction(title: "OK",
							                             style: .cancel,
							                             handler: nil)

							alert.addAction(okAction)

							self.controller?.present(alert, animated: true, completion: nil)
						}
						hud.hide(animated: true)
					}
				}
			case "certification_submitted":
				// Move from `Certification Submitted` to `Approved`.
				if tripEntity.type == .supervised {
					let hud = MBProgressHUD.showAdded(to: (controller?.navigationController?.view)!, animated: true)
					transitionService.transition(tripID: Int(tripEntity.tripID),
					                             transition: .approveCertificate,
					                             rejectionNote: nil) { _, error in
						if let error = error {
							let alert = UIAlertController(title: error.title,
							                              message: error.detail,
							                              preferredStyle: .alert)
							let okAction = UIAlertAction(title: "OK",
							                             style: .cancel,
							                             handler: nil)

							alert.addAction(okAction)

							self.controller?.present(alert, animated: true, completion: nil)
						}
						hud.hide(animated: true)
					}
				}

			default:
				break
			}
		case .rejectRow:
			switch tripEntity.status {
			case "submitted":
				// Move from `Submitted` to `Rejected`.
				if tripEntity.type == .supervised {
					let hud = MBProgressHUD.showAdded(to: (controller?.navigationController?.view)!, animated: true)
					transitionService.transition(tripID: Int(tripEntity.tripID),
					                             transition: .reject,
					                             rejectionNote: controller?.rejectionNote) { _, error in
						if let error = error {
							let alert = UIAlertController(title: error.title,
							                              message: error.detail,
							                              preferredStyle: .alert)
							let okAction = UIAlertAction(title: "OK",
							                             style: .cancel,
							                             handler: nil)

							alert.addAction(okAction)

							self.controller?.present(alert, animated: true, completion: nil)
						}

						hud.hide(animated: true)
					}
				}
			case "certification_submitted":
				// Move from `Certification Submitted` to `Certification Rejected`.
				if tripEntity.type == .supervised {
					let hud = MBProgressHUD.showAdded(to: (controller?.navigationController?.view)!, animated: true)
					transitionService.transition(tripID: Int(tripEntity.tripID),
					                             transition: .rejectСertificate,
					                             rejectionNote: controller?.rejectionNote) { _, error in
						if let error = error {
							let alert = UIAlertController(title: error.title,
							                              message: error.detail,
							                              preferredStyle: .alert)
							let okAction = UIAlertAction(title: "OK",
							                             style: .cancel,
							                             handler: nil)

							alert.addAction(okAction)

							self.controller?.present(alert, animated: true, completion: nil)
						}
						hud.hide(animated: true)
					}
				}

			default:
				break
			}
		case .travelActivitiesRow:
			controller?.showTravelActivities()
		case .travelItineraryRow:
			controller?.showTravelItinerary()
		case .travelCostAssigmentRow:
			controller?.showCostAssignment()
		}
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 0 {
			return 34.0
		} else {
			return tableView.sectionHeaderHeight
		}
	}
}
