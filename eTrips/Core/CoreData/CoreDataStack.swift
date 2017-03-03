import Foundation
import CoreData

/// Class reponsible for managing Core Data stack.
class CoreDataStack {
	
	static let shared = CoreDataStack()
	
	private let modelName = "eTripsModel"
	
	private lazy var applicationDocumentsDirectory: NSURL = {
		let urls = FileManager.default.urls(
			for: .documentDirectory, in: .userDomainMask)
		return urls[urls.count - 1] as NSURL
	}()
	
	public lazy var managedObjectContext: NSManagedObjectContext = {
		var managedObjectContext = NSManagedObjectContext(
			concurrencyType: .mainQueueConcurrencyType)
		
		managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
		return managedObjectContext
	}()
	
	public lazy var stratchpadManagedObjectContext: NSManagedObjectContext = {
		var managedObjectContext = NSManagedObjectContext(
			concurrencyType: .mainQueueConcurrencyType)
		
		managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
		return managedObjectContext
	}()
	
	private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let url = self.applicationDocumentsDirectory.appendingPathComponent(self.modelName)
		
		do {
			let options = [NSMigratePersistentStoresAutomaticallyOption: true]
			try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil,
			                                   at: url, options: options)
		} catch {
			print("Error adding persistent store.")
		}
		
		return coordinator
	}()
	
	private lazy var managedObjectModel: NSManagedObjectModel = {
		let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd")!
		return NSManagedObjectModel(contentsOf: modelURL)!
	}()
    
    func saveContext(context: NSManagedObjectContext) {
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                abort()
            }
        }
    }
	
	func saveContext() {
        saveContext(context: managedObjectContext)
	}
	
	func cleanData() {
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: "RemovableEntity")
		let deleteTripsRequest = NSBatchDeleteRequest(fetchRequest: request)
		try! managedObjectContext.execute(deleteTripsRequest)
		managedObjectContext.reset()
		managedObjectContext.set(object: nil, forSingleObjectCacheKey: Constants.Cache.Profile)
	}
}
