import Foundation
import CoreData

public final class ActionPointEntity: ManagedObject {
	@NSManaged private(set) public var pointID: Int64
	@NSManaged private(set) public var actionPointNumber: String?
	@NSManaged private(set) public var tripReferenceNumber: String?
	@NSManaged private(set) public var pointDescription: String?
	@NSManaged private(set) public var dueDate: NSDate
	@NSManaged private(set) public var personResponsibleID: Int64
	@NSManaged private(set) public var status: String
	@NSManaged private(set) public var completedAt: NSDate?
	@NSManaged private(set) public var actionsTaken: String?
	@NSManaged private(set) public var followUp: Bool
	@NSManaged private(set) public var comments: String?
	@NSManaged private(set) public var createdAt: NSDate
	@NSManaged private(set) public var assignedByPersonID: Int64
	@NSManaged private(set) public var tripID: Int64
	@NSManaged private(set) public var personResponsibleName: String?
	@NSManaged private(set) public var assignedByName: String?
	@NSManaged public var trip: TripEntity?
	
	public static func findAndUpdateOrCreate(in context: NSManagedObjectContext,
	                                         object: ActionPoint) -> ActionPointEntity {
		
		let predicate = NSPredicate(format: "pointID == %d", object.pointID)
		let actionPointEntity = findAndUpdateOrCreate(in: context, with: predicate) {
			$0.pointID = Int64(object.pointID)
			$0.actionPointNumber = object.actionPointNumber
			$0.tripReferenceNumber = object.tripReferenceNumber
			$0.pointDescription = object.pointDescription
			$0.personResponsibleID = Int64(object.personResponsibleID)
			$0.status = object.status
			$0.completedAt = object.completedAtDate as NSDate?
			$0.actionsTaken = object.actionsTaken
			$0.comments = object.comments
			$0.assignedByPersonID = Int64(object.assignedByPersonID)
			$0.tripID = Int64(object.tripID)
			$0.personResponsibleName = object.personResponsibleName
			$0.assignedByName = object.assignedByName
			
			if let date = object.createdAtDate { $0.createdAt = date as NSDate }
			if let date = object.dueDate { $0.dueDate = date as NSDate }
			
			$0.followUp = object.followUp
		}
		
		return actionPointEntity
	}
	
	public static func findAndUpdateOrCreate(in context: NSManagedObjectContext,
	                                         object: ActionPointEntity) -> ActionPointEntity {
		
		let predicate = NSPredicate(format: "pointID == %d", object.pointID)
		let actionPointEntity = findAndUpdateOrCreate(in: context, with: predicate) {
			$0.pointID = object.pointID
			$0.actionPointNumber = object.actionPointNumber
			$0.tripReferenceNumber = object.tripReferenceNumber
			$0.pointDescription = object.pointDescription
			$0.personResponsibleID = object.personResponsibleID
			$0.status = object.status
			$0.completedAt = object.completedAt
			$0.actionsTaken = object.actionsTaken
			$0.comments = object.comments
			$0.assignedByPersonID = Int64(object.assignedByPersonID)
			$0.tripID = object.tripID
			$0.createdAt = object.createdAt
			$0.dueDate = object.dueDate
			$0.followUp = object.followUp
			$0.personResponsibleName = object.personResponsibleName
			$0.assignedByName = object.assignedByName
		}
		
		return actionPointEntity
	}
	
	public static func createNewDraftEntity(in context: NSManagedObjectContext,
	                                        withCreatorID creatorID: Int) -> ActionPointEntity {
		
		let draftEntity = findOrCreate(in: context, with: NSPredicate(format: "tripID = %d", -1)) {
			$0.assignedByPersonID = Int64(creatorID)
			$0.createdAt = NSDate()
			$0.dueDate = NSDate()
			$0.status = "open"
		}
		
		return draftEntity
	}
	
	public static func deleteAll(in context: NSManagedObjectContext) {
		
		let fetchedActionPoints = try! context.fetch(self.sortedFetchRequest) as! [ActionPointEntity]
		
		for pointEntity in fetchedActionPoints {
			context.delete(pointEntity)
		}
		
		CoreDataStack.shared.saveContext(context: context)
	}
	
	public static func deleteAll(forTripID tripID: Int, in context: NSManagedObjectContext) {
		
		let fetchRequest = self.sortedFetchRequest
		fetchRequest.predicate = NSPredicate(format: "tripID == %d", tripID)
		
		let fetchedEntities = try! context.fetch(fetchRequest) as! [ActionPointEntity]
		
		for entity in fetchedEntities {
			context.delete(entity)
		}
		
		CoreDataStack.shared.saveContext(context: context)
	}
	
	// MARK: - Utilities
	var dueDateString: String {
		let dateString = (dueDate as Date).mediumDateStyleString()
		return "\(dateString)"
	}
	
	var completedAtDateString: String? {
		guard let date = completedAt else {
			return nil
		}
		
		let dateString = (date as Date).mediumDateStyleString()
		return "\(dateString)"
	}
	
	func dictionaryValue() -> [String: Any] {
		
		var result: [String: Any] = ["status": status,
		                             "description": pointDescription ?? "",
		                             "follow_up": followUp,
		                             "person_responsible": String(personResponsibleID),
		                             "comments": comments ?? "",
		                             "actions_taken": actionsTaken ?? "",
		                             "assigned_by": String(assignedByPersonID),
		                             "created_at": DateFormatter.iso8601DateFormatter.string(from: createdAt as Date)]
		
		let dueDateString = DateFormatter.iso8601DateFormatter.string(from: self.dueDate as Date)
		result["due_date"] = dueDateString
		
		if let date = completedAt as? Date {
			result["completed_at"] = DateFormatter.iso8601DateFormatter.string(from: date)
		} else {
			result["completed_at"] = NSNull()
		}
		
		return result
	}
	
	// MARK: - Methods for updating data
	func updatePerson(with newID: Int64, name: String) {
		personResponsibleID = newID
		personResponsibleName = name
	}
	
	func updatePointDescription(newDescription: String?) {
		pointDescription = newDescription
	}
	
	func updateDueDate(newDate: Date) {
		dueDate = NSDate(timeIntervalSince1970: newDate.timeIntervalSince1970)
	}
	
	func updateCompletedAtDate(newDate: Date?) {
		if let date = newDate {
			completedAt = NSDate(timeIntervalSince1970: date.timeIntervalSince1970)
		} else {
			completedAt = nil
		}
	}
	
	func updateStatus(newStatus: String) {
		status = newStatus.lowercased()
	}
	
	func updateActionsTaken(newAction: String?) {
		actionsTaken = newAction
	}
	
	func updateFollowUp(flag: Bool) {
		followUp = flag
	}
}

// MARK: - ManagedObjectType
extension ActionPointEntity: ManagedObjectType {
	public static var entityName: String {
		return "ActionPointEntity"
	}
	
	public static var defaultSortDescriptors: [NSSortDescriptor] {
		return [NSSortDescriptor(key: "tripReferenceNumber", ascending: true)]
	}
	
	public static var defaultPredicate: NSPredicate {
		return NSPredicate(value: true)
	}
}
