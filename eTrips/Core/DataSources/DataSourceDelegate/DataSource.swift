import Foundation

protocol DataSourceDelegate: class {
	associatedtype Object
	func cellIdentifierForObject(object: Object) -> String
}
