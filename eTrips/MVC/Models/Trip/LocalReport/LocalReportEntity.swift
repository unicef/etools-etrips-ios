import Foundation
import CoreData

public final class LocalReportEntity: ManagedObject {
	@NSManaged private(set) public var tripID: Int64
	@NSManaged public var report: String?
	
	@NSManaged public var trip: TripEntity?
	
	public static func findOrCreate(in context: NSManagedObjectContext,
	                                tripID: Int64) -> LocalReportEntity {
		
		let predicate = NSPredicate(format: "tripID == %@", String(describing: tripID))
		
		let localReportEntity = findOrCreate(in: CoreDataStack.shared.managedObjectContext, with: predicate) {
			$0.tripID = tripID
		}
		
		return localReportEntity
	}
	
	public static func findLocalReportsForTrip(in context: NSManagedObjectContext,
	                                           with id: Int64) -> [LocalReportEntity]? {
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
		request.predicate = NSPredicate(format: "tripID == %d", id)
		
		let results = try! context.fetch(request) as? [LocalReportEntity]
		return results
	}
}

// MARK: - ManagedObjectType
extension LocalReportEntity: ManagedObjectType {
	public static var entityName: String {
		return "LocalReportEntity"
	}
}
