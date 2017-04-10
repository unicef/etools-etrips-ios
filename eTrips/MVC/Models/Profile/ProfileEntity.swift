import Foundation
import CoreData

public final class ProfileEntity: ManagedObject {
	@NSManaged public private(set) var profileID: Int64
	@NSManaged public private(set) var firstName: String
    @NSManaged public private(set) var lastName: String
    @NSManaged public private(set) var country: String
	@NSManaged public private(set) var username: String?
	@NSManaged public private(set) var office: String?
	@NSManaged public private(set) var jobTitle: String?
    @NSManaged public private(set) var businessArea: Int64
	
	var fullName: String {
		return "\(firstName) \(lastName)"
	}
	
	public static func insert(into context: NSManagedObjectContext, object: Profile) -> ProfileEntity {
		let profileEntity: ProfileEntity = context.insertObject()
		
		// ID.
		if let profileID = object.profileID {
			profileEntity.profileID = Int64(profileID)
		}
		
		// First name.
		if let firstName = object.firstName {
			profileEntity.firstName = firstName
		}
		
		// Last name.
		if let lastName = object.lastName {
			profileEntity.lastName = lastName
		}
		
		// Country.
		if let country = object.country {
			profileEntity.country = country
		}
		
		// Username.
		if let username = object.username {
			profileEntity.username = username
		}
		
		// Office.
		if let office = object.office {
			profileEntity.office = office
		}
		
		// Job title.
		if let jobTitle = object.jobTitle {
			profileEntity.jobTitle = jobTitle
		}
        
        // Business Area.
        if let businessArea = object.businessArea {
            profileEntity.businessArea = Int64(businessArea)
        }

		return profileEntity
	}
}

extension ProfileEntity: ManagedObjectType {
	public static var entityName: String {
		return "ProfileEntity"
	}
}

extension ProfileEntity {
	static func profileEntityForLoggedInUser(in context: NSManagedObjectContext) -> ProfileEntity? {
		return fetchSingleObject(in: context, cacheKey: Constants.Cache.Profile) { _ in }
	}
}
