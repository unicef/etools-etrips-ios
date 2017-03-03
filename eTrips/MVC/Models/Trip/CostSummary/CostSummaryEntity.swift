import Foundation
import CoreData

public final class CostSummaryEntity: ManagedObject {
	@NSManaged private(set) public var dsaTotal: String
	@NSManaged private(set) public var expensesTotal: String
	@NSManaged private(set) public var deductionsTotal: String
	
	var totalCost: Double? {
		guard let dsaTotalDouble = Double(dsaTotal) else {
			return nil
		}
		
		guard let expensesTotalDouble = Double(expensesTotal) else {
			return nil
		}
		
		guard let deductionsTotalDouble = Double(deductionsTotal) else {
			return nil
		}
		return dsaTotalDouble + expensesTotalDouble - deductionsTotalDouble
	}
	
	public static func insert(into context: NSManagedObjectContext, object: CostSummary) -> CostSummaryEntity {
		
		let costSummaryEntity: CostSummaryEntity = context.insertObject()
		
		// DSA Total.
		if let dsaTotal = object.dsaTotal {
			costSummaryEntity.dsaTotal = dsaTotal
		}
		
		// Expenses Total.
		if let expensesTotal = object.expensesTotal {
			costSummaryEntity.expensesTotal = expensesTotal
		}
		
		// Deductions Total.
		if let deductionsTotal = object.deductionsTotal {
			costSummaryEntity.deductionsTotal = deductionsTotal
		}
		
		return costSummaryEntity
	}
}

// MARK: - ManagedObjectType
extension CostSummaryEntity: ManagedObjectType {
	public static var entityName: String {
		return "CostSummaryEntity"
	}
}
