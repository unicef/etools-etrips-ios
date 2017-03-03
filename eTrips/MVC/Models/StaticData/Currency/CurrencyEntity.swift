import Foundation
import CoreData

public final class CurrencyEntity: ManagedObject {
	@NSManaged private(set) public var currencyID: Int64
	@NSManaged private(set) public var name: String?
	@NSManaged private(set) public var code: String?
	@NSManaged private(set) public var iso4127: String?
	@NSManaged private(set) public var exchangeToDollar: Double
	
	public static func insert(into context: NSManagedObjectContext, object: Currency) -> CurrencyEntity {
		
		let currencyEntity: CurrencyEntity = context.insertObject()
		
		if let currencyID = object.currencyID {
			currencyEntity.currencyID = Int64(currencyID)
		}
		
		if let name = object.name {
			currencyEntity.name = name
		}
		
		if let code = object.code {
			currencyEntity.code = code
		}
		
		if let iso4127 = object.iso4127 {
			currencyEntity.iso4127 = iso4127
		}
		
		if let exchangeToDollar = object.exchangeToDollar {
			currencyEntity.exchangeToDollar = exchangeToDollar
		}
		
		return currencyEntity
	}
}

// MARK: - ManagedObjectType
extension CurrencyEntity: ManagedObjectType {
	public static var entityName: String {
		return "CurrencyEntity"
	}
}
