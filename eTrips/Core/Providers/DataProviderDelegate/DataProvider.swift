import Foundation

enum DataProviderUpdate<Object> {
	case insert(IndexPath)
	case update(IndexPath, Object)
	case move(IndexPath, IndexPath)
	case delete(IndexPath)
}

protocol DataProvider: class {
	associatedtype Object
	func numberOfItemsInSection(section: Int) -> Int
	func objectAtIndexPath(indexPath: IndexPath) -> Object
}

protocol DataProviderDelegate: class {
	associatedtype Object
	func dataProviderDidUpdate()
}
