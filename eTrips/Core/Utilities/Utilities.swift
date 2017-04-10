import Foundation

extension Set where Element: AnyObject {
	public func containsObjectIdenticalTo(_ object: AnyObject) -> Bool {
		return contains { $0 === object }
	}
}

protocol RowIndexable {
    func indexPath() -> IndexPath
}

extension RowIndexable where Self: RawRepresentable, Self.RawValue == Int {
    func indexPath() -> IndexPath {
        return IndexPath(row: self.rawValue, section: 0)
    }
}
