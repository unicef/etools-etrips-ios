import Foundation
import CoreData

protocol ManagedObjectContextSettable: class {
	var managedObjectContext: NSManagedObjectContext! { get set }
}
