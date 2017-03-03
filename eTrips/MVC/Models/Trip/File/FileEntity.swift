import Foundation
import CoreData

public final class FileEntity: ManagedObject {
	@NSManaged private(set) public var fileID: Int64
	@NSManaged private(set) public var fileURL: String
	@NSManaged private(set) public var caption: String
	
	@NSManaged public var trip: TripEntity
	
	public static func insert(into context: NSManagedObjectContext, object: File) -> FileEntity {
		
		let fileEntity: FileEntity = context.insertObject()
		
		if let fileID = object.fileID {
			fileEntity.fileID = Int64(fileID)
		}
		
		if let fileURL = object.fileURL {
			fileEntity.fileURL = fileURL
		}
		
		if let caption = object.caption {
			fileEntity.caption = caption
		}
		
		return fileEntity
	}
	
	public static func insert(into context: NSManagedObjectContext,
	                          fileID: Int, fileURL: String, caption: String) -> FileEntity {
		let fileEntity: FileEntity = context.insertObject()
		
		fileEntity.fileID = Int64(fileID)
		fileEntity.fileURL = fileURL
		fileEntity.caption = caption
		
		return fileEntity
	}
}

// MARK: - ManagedObjectType
extension FileEntity: ManagedObjectType {
	public static var entityName: String {
		return "FileEntity"
	}
}
