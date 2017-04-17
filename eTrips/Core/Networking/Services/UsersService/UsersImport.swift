import UIKit
import Moya
import CoreData

class UsersImport: Operation {
    let response: Moya.Response
    let context: NSManagedObjectContext
    let completionHandler: (Bool) -> Void
    
    init(with response: Moya.Response,
         context: NSManagedObjectContext,
         completionHandler: @escaping (Bool) -> Void) {
        // Response
        self.response = response
        
        // Context.
        let importContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        importContext.mergePolicy = NSOverwriteMergePolicy
        self.context = importContext
        
        // Completion handler.
        self.completionHandler = completionHandler
        
        super.init()
    }
    
    override func main() {
        do {
            // Parsing users.
            let parsedUsers: [User]? = try response.mapArray(User.self)
            
            guard let users = parsedUsers else {
                cancel()
            }
            
            // Writing to Core Data.
            context.perform {
                
                for user in users {
                    _ = UserEntity.insert(into: self.context, object: user)
                }
                
                let error = self.saveContext()
                
                if error != nil {
                    self.completionHandler(false)
                } else {
                    self.completionHandler(true)
                }
            }
        } catch {
            cancel()
        }
    }
    
    private func saveContext() -> NSError? {
        var error: NSError?
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let saveError as NSError {
                error = saveError
            }
        }
        return error
    }
}
