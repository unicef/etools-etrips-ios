import Foundation
import UIKit
import CoreData

public enum TripType: Int32 {
	case myTrip, supervised
}

public final class TripEntity: ManagedObject {
	@NSManaged private(set) public var tripID: Int64
	@NSManaged private(set) public var referenceNumber: String
	@NSManaged private(set) public var travelerName: String?
	@NSManaged private(set) public var purposeOfTravel: String
	@NSManaged private(set) public var status: String
	@NSManaged private(set) public var startDate: NSDate
	@NSManaged private(set) public var endDate: NSDate
	@NSManaged private(set) public var typeValue: Int32

	@NSManaged private(set) public var supervisorID: Int64
	@NSManaged private(set) public var supervisorName: String

	@NSManaged public var report: String?
	@NSManaged private(set) public var rejectionNote: String?

	@NSManaged private(set) public var files: Set<FileEntity>?

	@NSManaged private(set) public var costAssignments: Set<CostAssignmentEntity>?
	@NSManaged private(set) public var travelItinerary: Set<TravelItineraryEntity>?
	@NSManaged private(set) public var travelActivities: Set<TravelActivityEntity>?
	@NSManaged private(set) public var costSummary: CostSummaryEntity?

	@NSManaged private(set) public var actionPoints: Set<ActionPointEntity>?
	@NSManaged public var lastModified: NSDate?
	@NSManaged private(set) public var currencyID: Int64

	// Local Report.
	@NSManaged public var localReport: LocalReportEntity?
	@NSManaged public var localFiles: Set<LocalFileEntity>?

	var type: TripType {
		get {
			return TripType(rawValue: self.typeValue)!
		}
		set {
			self.typeValue = newValue.rawValue
		}
	}

	var formattedStatus: String {
		return status.capitalized.replacingOccurrences(of: "_", with: " ")
	}

	var isDraft: Bool {

		var isReport = false
		if let report = localReport?.report {
			if !report.isEmpty { isReport = true }
		}

		var isLocalFiles = false
		if let localFiles = localFiles {
			if !localFiles.isEmpty { isLocalFiles = true }
		}
		return !isReportSubmitted && (isReport || isLocalFiles)
	}

	/// Provides status row title header.
	var statusTitleHeader: String {
		switch status {
		case "planned":
			switch type {
			case .myTrip:
				return "STATUS (Planned)"
			case .supervised:
				return "STATUS"
			}
		case "submitted":
			switch type {
			case .myTrip, .supervised:
				return "STATUS (Submitted)"
			}
		case "certification_submitted":
			switch type {
			case .myTrip, .supervised:
				return "STATUS (Certification Submitted)"
			}
		default:
			return "STATUS"
		}
	}

	/// Provides info about how to display `Status` Row in the table.
	var statusRowData: (text: String, color: UIColor) {
		switch status {
		case "planned":
			switch type {
			case .myTrip:
				return ("Submit", ThemeManager.shared.theme.buttonTintColor)
			case .supervised:
				return ("Planned", UIColor.black)
			}
		case "submitted":
			switch type {
			case .myTrip:
				return ("Waiting For Approval", UIColor.black)
			case .supervised:
				return ("Approve", ThemeManager.shared.theme.buttonTintColor)
			}
		case "rejected":
			switch type {
			case .myTrip, .supervised:
				return ("Rejected", ThemeManager.shared.theme.rejectedTripColor)
			}
		case "cancelled":
			switch type {
			case .myTrip, .supervised:
				return ("Canceled", ThemeManager.shared.theme.canceledTripColor)
			}
		case "certification_submitted":
			switch type {
			case .myTrip:
				return ("Waiting For Approval", UIColor.black)
			case .supervised:
				return ("Approve", ThemeManager.shared.theme.buttonTintColor)
			}
		case "certified":
			switch type {
			case .myTrip, .supervised:
				return ("Certified", UIColor.black)
			}
		case "approved":
			switch type {
			case .myTrip, .supervised:
				return ("Approved", UIColor.black)
			}
		case "sent_for_payment":
			switch type {
			case .myTrip, .supervised:
				return ("Sent For Payment", UIColor.black)
			}
		case "certification_rejected":
			switch type {
			case .myTrip, .supervised:
				return ("Certification Rejected", ThemeManager.shared.theme.certificationRejectedTripColor)
			}
		case "completed":
			switch type {
			case .myTrip, .supervised:
				return ("Completed", ThemeManager.shared.theme.completedTripColor)
			}
		case "certification_approved":
			switch type {
			case .myTrip, .supervised:
				return ("Certification Approved", UIColor.black)
			}
		default:
			return ("", UIColor.black)
		}
	}

	/// If report property not empty (loaded from server) we think
	/// that report was already submitted.
	var isReportSubmitted: Bool {
		guard let report = report else {
			return false
		}
		return !report.isEmpty
	}

	public var mutableFiles: NSMutableOrderedSet {
		return mutableOrderedSetValue(forKey: "files")
	}

	private var mutableCostAssignments: NSMutableOrderedSet {
		return mutableOrderedSetValue(forKey: "costAssignments")
	}

	private var mutableTravelItinerary: NSMutableOrderedSet {
		return mutableOrderedSetValue(forKey: "travelItinerary")
	}

	private var mutableTravelActivities: NSMutableOrderedSet {
		return mutableOrderedSetValue(forKey: "travelActivities")
	}

	private var mutableActionPoints: NSMutableOrderedSet {
		return mutableOrderedSetValue(forKey: "actionPoints")
	}

	public var mutableLocalFiles: NSMutableOrderedSet {
		return mutableOrderedSetValue(forKey: "localFiles")
	}

	public static func findAndUpdateOrCreate(in context: NSManagedObjectContext,
	                                         object: Trip,
	                                         type: TripType?) -> TripEntity {
		let predicate = NSPredicate(format: "tripID == %@", String(describing: object.tripID!))

		let tripEntity = findAndUpdateOrCreate(in: context, with: predicate) {
			$0.tripID = Int64(object.tripID!)
			$0.status = object.status!
			$0.referenceNumber = object.referenceNumber!
			$0.purposeOfTravel = object.purposeOfTravel!
			$0.startDate = (object.startDate as NSDate?)!
			$0.endDate = (object.endDate as NSDate?)!

			if let travelerName = object.travelerName {
				$0.travelerName = travelerName
			}

			if let supervisorID = object.supervisorID {
				$0.supervisorID = Int64(supervisorID)
			}

			if let supervisorName = object.supervisorName {
				$0.supervisorName = supervisorName
			}

			if let currencyID = object.currencyID {
				$0.currencyID = Int64(currencyID)
			}

			$0.report = object.report

			// Trip Type.
			if let type = type {
				$0.type = type
			}

			// Files.
			if let files = object.files {
				$0.mutableFiles.removeAllObjects()
				for file in files {
					let fileEntity = FileEntity.insert(into: context, object: file)
					$0.mutableFiles.add(fileEntity)
				}
			}

			// Travel Itinerary.
			if let travelItinerary = object.travelItinerary {
				$0.mutableTravelItinerary.removeAllObjects()
				for travel in travelItinerary {
					let travelItineraryEntity = TravelItineraryEntity.insert(into: context, object: travel)
					$0.mutableTravelItinerary.add(travelItineraryEntity)
				}
			}

			// Travel Activities.
			if let travelActivities = object.travelActivities {
				$0.mutableTravelActivities.removeAllObjects()
				for activity in travelActivities {
					let travelActivityEntity = TravelActivityEntity.insert(into: context, object: activity)
					$0.mutableTravelActivities.add(travelActivityEntity)
				}
			}

			// Cost Assignments.
			if let costAssignments = object.costAssignments {
				$0.mutableCostAssignments.removeAllObjects()
				for costAssigment in costAssignments {
					let costAssignmentEntity = CostAssignmentEntity.insert(into: context, object: costAssigment)
					$0.mutableCostAssignments.add(costAssignmentEntity)
				}

			}

			// Action Points.
			if let actionPoints = object.actionPoints {
				$0.mutableActionPoints.removeAllObjects()
				for actionPoint in actionPoints {
					let actionPointEntity = ActionPointEntity.findAndUpdateOrCreate(in: context, object: actionPoint)
					actionPointEntity.trip = $0
					$0.mutableActionPoints.add(actionPointEntity)
				}
			}

			// Cost Summary.
			if let costSummary = object.costSummary {
				$0.costSummary = CostSummaryEntity.insert(into: context, object: costSummary)
			}

			// Local Report.
			$0.localReport = LocalReportEntity.findOrCreate(in: context, tripID: $0.tripID)
			$0.localReport?.trip = $0

			// Local Files.
			if let localFiles = LocalFileEntity.findLocalFilesForTrip(in: context, with: $0.tripID) {
				for localFile in localFiles {
					localFile.trip = $0
					$0.mutableLocalFiles.add(localFile)
				}
			}

			// Rejection Note.
			if let rejectionNote = object.rejectionNote {
				$0.rejectionNote = rejectionNote
			}

			// Last modified.
			$0.lastModified = Date() as NSDate
		}

		return tripEntity
	}

	public static func deleteAll(in context: NSManagedObjectContext, with type: TripType) {
		let tripsFetchRequest = self.sortedFetchRequest
		tripsFetchRequest.predicate = NSPredicate(format: "typeValue == %d", type.rawValue)

		let fetchedTrips = try! context.fetch(tripsFetchRequest) as! [TripEntity]

		for tripEntity in fetchedTrips {
			context.delete(tripEntity)
		}
	}

	public func deleteLocalReport() {
		if let localReport = localReport {
			CoreDataStack.shared.managedObjectContext.delete(localReport)
		}

		if let localFiles = localFiles {
			for localFile in localFiles {
				CoreDataStack.shared.managedObjectContext.delete(localFile)
			}
		}
	}

	var fromDateToDateString: String {
		let startDateString = (startDate as Date).mediumDateStyleString()
		let endDateString = (endDate as Date).mediumDateStyleString()

		return "\(startDateString) - \(endDateString)"
	}
}

// MARK: - ManagedObjectType
extension TripEntity: ManagedObjectType {
	public static var entityName: String {
		return "TripEntity"
	}

	public static var defaultSortDescriptors: [NSSortDescriptor] {
		return [NSSortDescriptor(key: "startDate", ascending: true),
		        NSSortDescriptor(key: "referenceNumber", ascending: true)]
	}

	public static var defaultPredicate: NSPredicate {
		return NSPredicate(value: true)
	}
}
