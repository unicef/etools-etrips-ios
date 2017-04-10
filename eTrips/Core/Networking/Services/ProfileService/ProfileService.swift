import Foundation
import CoreData
import Moya_ObjectMapper

typealias ProfileServiceCompletionHandler = (Bool, Int?) -> Void

/// Class responsible for loading profile data and storing it to the Core Data.
class ProfileService {
	var managedObjectContext = CoreDataStack.shared.managedObjectContext
	
	func downloadProfile(completion: @escaping ProfileServiceCompletionHandler) {
		eTripsAPIProvider.request(.profile) { result in
			switch result {
			case let .success(response):
				let statusCode = response.statusCode
				
				switch statusCode {
				case 200...299:
					do {
						let parsedProfile: Profile? = try response.mapObject(Profile.self)
						
						guard let profile = parsedProfile else {
							completion(false, nil)
						}
						
						_ = ProfileEntity.insert(into: self.managedObjectContext, object: profile)
						
						CoreDataStack.shared.managedObjectContext.performSaveOrRollback()
						completion(true, parsedProfile?.businessArea)
						
					} catch {
						completion(false, nil)
					}
				default:
					completion(false, nil)
				}
			case .failure:
				completion(false, nil)
			}
		}
		
	}
	
}
