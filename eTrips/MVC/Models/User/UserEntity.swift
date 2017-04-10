import Foundation
import CoreData

public final class UserEntity: ManagedObject {

    @NSManaged private(set) public var userID: Int64
    @NSManaged private(set) public var name: String
    @NSManaged private(set) public var firstName: String
    @NSManaged private(set) public var lastName: String

    public static func insert(into context: NSManagedObjectContext, object: User) -> UserEntity {
        let userEntity: UserEntity = context.insertObject()

        if let userID = object.userID {
            userEntity.userID = Int64(userID)
        }

        if let name = object.name {
            userEntity.name = name
        }

        if let firstName = object.firstName {
            userEntity.firstName = firstName
        }

        if let lastName = object.lastName {
            userEntity.lastName = lastName
        }

        return userEntity
    }

    public static func findAndUpdateOrCreate(in context: NSManagedObjectContext, object: User) -> UserEntity {

        let predicate = NSPredicate(format: "userID == %@", String(describing: object.userID!))

        let userEntity = findAndUpdateOrCreate(in: context, with: predicate) {
            if let userID = object.userID {
                $0.userID = Int64(userID)
            }

            if let name = object.name {
                $0.name = name
            }

            if let firstName = object.firstName {
                $0.firstName = firstName
            }

            if let lastName = object.lastName {
                $0.lastName = lastName
            }
        }
        return userEntity
    }

    public static func deleteAll(in context: NSManagedObjectContext) {
        let usersFetchRequest = self.sortedFetchRequest

        let fetchedUsers = try! context.fetch(usersFetchRequest) as! [UserEntity]

        for userEntity in fetchedUsers {
            context.delete(userEntity)
        }
    }
}

extension UserEntity: ManagedObjectType {
    public static var entityName: String {
        return "UserEntity"
    }

    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "name", ascending: true)]
    }
}
