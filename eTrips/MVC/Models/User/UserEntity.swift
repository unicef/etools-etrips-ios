import Foundation
import CoreData

public final class UserEntity: ManagedObject {

	@NSManaged private(set) public var userID: Int64
	@NSManaged private(set) public var fullName: String
	@NSManaged private(set) public var username: String
	@NSManaged private(set) public var email: String
	
	public static func findAndUpdateOrCreate(in context: NSManagedObjectContext,
	                                         object: User) -> UserEntity {

		let predicate = NSPredicate(format: "userID == %@", String(describing: object.userID!))

		let userEntity = findAndUpdateOrCreate(in: context, with: predicate) {
			if let userID = object.userID {
				$0.userID = Int64(userID)
			}
			
			if let fullName = object.fullName {
				$0.fullName = fullName
			}
			
			if let username = object.username {
				$0.username = username
			}
			
			if let email = object.email {
				$0.email = email
			}
		}
		return userEntity
	}
}

extension UserEntity: ManagedObjectType {
	public static var entityName: String {
		return "UserEntity"
	}

	public static var defaultSortDescriptors: [NSSortDescriptor] {
		return [NSSortDescriptor(key: "lastName", ascending: true)]
	}
}
