import Foundation
import Moya

typealias UsersServiceCompletionHandler = (Bool, NetworkError?) -> Void

class UsersService {
    /// Contex.
    var managedObjectContext = CoreDataStack.shared.managedObjectContext
    
    /// Import Operation Queue.
    var importQueue = OperationQueue()

    func downloadUsers(completion: @escaping UsersServiceCompletionHandler) -> Cancellable {
        let cancellableToken = eTripsAPIProvider.request(.users) { result in
            switch result {
            case let .success(response):
                let statusCode = response.statusCode

                switch statusCode {
                case 200 ... 299:
                    let importOperation = UsersImport(with: response,
                                                      context: self.managedObjectContext) { success in
                        if success {
                            completion(true, nil)
                        } else {
                            completion(false, nil)
                        }
                    }
                    self.importQueue.addOperation(importOperation)
                default:
                    completion(false, nil)
                }
            case let .failure(error):
                switch error {
                case .underlying(let nsError):
                    completion(false, NetworkError(title: "Error", detail: nsError.localizedDescription))
                default:
                    completion(false, nil)
                }
            }
        }
        return cancellableToken
    }
}
