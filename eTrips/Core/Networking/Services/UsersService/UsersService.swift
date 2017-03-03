import Foundation

typealias UsersServiceCompletionHandler = (Bool) -> Void

class UsersService {
	func downloadUsers(completion: @escaping UsersServiceCompletionHandler) {
		eTripsAPIProvider.request(.users) { result in
			switch result {
			case let .success(response):
				do {
					let parsedUsers: [User]? = try response.mapArray(User.self)
					
					guard let users = parsedUsers else {
						completion(false)
					}
					
					for user in users {
						_ = UserEntity.findAndUpdateOrCreate(in: CoreDataStack.shared.managedObjectContext,
						                                     object: user)
					}
					
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