import Foundation
import CoreData

public final class StaticDataEntity: ManagedObject {
	@NSManaged private(set) public var wbs: Set<WBSEntity>?
	@NSManaged private(set) public var grants: Set<GrantEntity>?
	@NSManaged private(set) public var funds: Set<FundEntity>?

	public var mutableWBS: NSMutableOrderedSet {
		return mutableOrderedSetValue(forKey: "wbs")
	}

	private var mutableGrants: NSMutableOrderedSet {
		return mutableOrderedSetValue(forKey: "grants")
	}

	private var mutableFunds: NSMutableOrderedSet {
		return mutableOrderedSetValue(forKey: "funds")
	}
	
	public static func insert(in context: NSManagedObjectContext,
	                          object: StaticData) -> StaticDataEntity {

		let staticDataEntity: StaticDataEntity = context.insertObject()

		// WBS.
		if let wbsArray = object.wbs {
			staticDataEntity.mutableWBS.removeAllObjects()
			for wbs in wbsArray {
				let wbsEntity = WBSEntity.insert(into: context, object: wbs)
				staticDataEntity.mutableWBS.add(wbsEntity)
			}
		}

		// Grants.
		if let grants = object.grants {
			staticDataEntity.mutableGrants.removeAllObjects()
			for grant in grants {
				let grantEntity = GrantEntity.insert(into: context, object: grant)
				staticDataEntity.mutableGrants.add(grantEntity)
			}
		}

		// Funds.
		if let funds = object.funds {
			staticDataEntity.mutableFunds.removeAllObjects()
			for fund in funds {
				let fundEntity = FundEntity.insert(into: context, object: fund)
				staticDataEntity.mutableFunds.add(fundEntity)
			}
		}

		return staticDataEntity
	}

	public func findWBS(with id: Int64) -> WBSEntity? {
		let filteredWBS = wbs?.filter { $0.wbsID == id }
		return filteredWBS?.first
	}

	public func findFund(with id: Int64) -> FundEntity? {
		let filteredFunds = funds?.filter { $0.fundID == id }
		return filteredFunds?.first
	}

	public func findGrant(with id: Int64) -> GrantEntity? {
		let filteredGrants = grants?.filter { $0.grantID == id }
		return filteredGrants?.first
	}
}

// MARK: - ManagedObjectType
extension StaticDataEntity: ManagedObjectType {
	public static var entityName: String {
		return "StaticDataEntity"
	}
}
