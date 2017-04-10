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
    
    public static func deleteAll(in context: NSManagedObjectContext) {
        let currenciesFetchRequest = self.sortedFetchRequest
        let fetchedCurrencies = try! context.fetch(currenciesFetchRequest) as! [CurrencyEntity]
        
        for currencyEntity in fetchedCurrencies {
            context.delete(currencyEntity)
        }
    }
    
    public static func findCurrency(with id: Int64, in context: NSManagedObjectContext) -> CurrencyEntity? {
        let currenciesFetchRequest = self.sortedFetchRequest
        let fetchedCurrencies = try! context.fetch(currenciesFetchRequest) as? [CurrencyEntity]
        let filteredCurrencies = fetchedCurrencies?.filter { $0.currencyID == id }
        return filteredCurrencies?.first
    }
}

// MARK: - ManagedObjectType
extension CurrencyEntity: ManagedObjectType {
	public static var entityName: String {
		return "CurrencyEntity"
	}
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "name", ascending: true)]
    }
}
