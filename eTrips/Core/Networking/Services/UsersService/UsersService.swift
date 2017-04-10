import Foundation

typealias UsersServiceCompletionHandler = (Bool) -> Void

class UsersService {
    var managedObjectContext = CoreDataStack.shared.managedObjectContext

    func downloadUsers(completion: @escaping UsersServiceCompletionHandler) {
        eTripsAPIProvider.request(.users) { result in
            switch result {
            case let .success(response):
                let statusCode = response.statusCode

                switch statusCode {
                case 200 ... 299:
                    do {
                        let parsedUsers: [User]? = try response.mapArray(User.self)

                        guard let users = parsedUsers else {
                            completion(false)
                        }

                        UserEntity.deleteAll(in: self.managedObjectContext)
                        for user in users {
                            _ = UserEntity.insert(into: self.managedObjectContext, object: user)
                        }
                        CoreDataStack.shared.saveContext()
                        completion(true)
                    } catch {
                        completion(false)
                    }
                default:
                    completion(false)
                }

            case .failure:
                completion(false)
            }
        }
    }
}
