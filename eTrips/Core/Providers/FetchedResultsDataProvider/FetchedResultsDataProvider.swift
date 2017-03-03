import Foundation
import CoreData

class FetchedResultsDataProvider<Delegate: DataProviderDelegate>
	: NSObject, NSFetchedResultsControllerDelegate, DataProvider {
	
	typealias Object = Delegate.Object
	
	fileprivate let fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
	fileprivate weak var delegate: Delegate!
	
	init(fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>, delegate: Delegate) {
		self.fetchedResultsController = fetchedResultsController
		self.delegate = delegate
		super.init()
		fetchedResultsController.delegate = self
		try! fetchedResultsController.performFetch()
	}
	
	// MARK: - DataProvider
	// TODO: Refactor according to Swift API Design Guidelines
	func numberOfItemsInSection(section: Int) -> Int {
		guard let section = fetchedResultsController.sections?[section] else { return 0 }
		return section.numberOfObjects
	}
	
	func objectAtIndexPath(indexPath: IndexPath) -> Delegate.Object {
		guard let object = fetchedResultsController.object(at: indexPath) as? Object else {
			fatalError("Unexpected object at \(indexPath)")
		}
		return object
	}
	
	// MARK: - NSFetchedResultsControllerDelegate
	func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate.dataProviderDidUpdate()
	}
}
