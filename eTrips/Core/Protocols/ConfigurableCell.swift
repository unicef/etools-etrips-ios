import Foundation

protocol ConfigurableCell: class {
	associatedtype DataSource
	func configureForObject(object: DataSource)
}
