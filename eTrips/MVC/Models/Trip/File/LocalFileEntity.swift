import Foundation
import CoreData

public final class LocalFileEntity: ManagedObject {
	@NSManaged private(set) public var tripID: Int64
	@NSManaged private(set) public var fileID: Int64
	@NSManaged private(set) public var fileURL: String
	@NSManaged private(set) public var caption: String
	
	@NSManaged public var trip: TripEntity?
	
	public static func findOrCreate(in context: NSManagedObjectContext, fileID: Int,
	                                tripID: Int64, fileURL: String, caption: String) -> LocalFileEntity {
		
		let predicate = NSPredicate(format: "fileID == %@", String(describing: fileID))
		
		let localFileEntity = findOrCreate(in: context, with: predicate) {
			$0.tripID = tripID
			$0.fileID = Int64(fileID)
			$0.fileURL = fileURL
			$0.caption = caption
		}
		
		return localFileEntity
	}
	
	public static func findLocalFilesForTrip(in context: NSManagedObjectContext, with id: Int64) -> [LocalFileEntity]? {
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
		request.predicate = NSPredicate(format: "tripID == %d", id)
		
		let results = try! context.fetch(request) as? [LocalFileEntity]
		return results
	}
}

// MARK: - ManagedObjectType
extension LocalFileEntity: ManagedObjectType {
	public static var entityName: String {
		return "LocalFileEntity"
	}
}
