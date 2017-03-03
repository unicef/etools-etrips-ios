import Foundation
import CoreData
import Moya_ObjectMapper

typealias ProfileServiceCompletionHandler = (Bool) -> Void

/// Class responsible for loading profile data and storing it to the Core Data.
class ProfileService {
	
	func downloadProfile(completion: @escaping ProfileServiceCompletionHandler) {
		eTripsAPIProvider.request(.profile) { result in
			switch result {
			case let .success(response):
				
				do {
					let parsedProfile: Profile? = try response.mapObject(Profile.self)
					
					guard let profile = parsedProfile else {
						completion(false)
					}
					
					_ = ProfileEntity.insert(into: CoreDataStack.shared.managedObjectContext, object: profile)
					
					CoreDataStack.shared.managedObjectContext.performSaveOrRollback()
					completion(true)
					
				} catch {
					completion(false)
				}
				
			case .failure:
				completion(false)
			}
		}
		
	}
	
}
