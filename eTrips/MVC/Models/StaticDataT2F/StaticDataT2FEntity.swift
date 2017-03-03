import Foundation
import CoreData

public final class StaticDataT2FEntity: ManagedObject {
	@NSManaged private(set) public var partners: Set<PartnerEntity>?
	@NSManaged private(set) public var partnerships: Set<PartnershipEntity>?

	public var mutablePartners: NSMutableOrderedSet {
		return mutableOrderedSetValue(forKey: "partners")
	}

	private var mutablePartnerships: NSMutableOrderedSet {
		return mutableOrderedSetValue(forKey: "partnerships")
	}

	public static func insert(in context: NSManagedObjectContext,
	                          object: StaticDataT2F) -> StaticDataT2FEntity {

		let staticDataT2FEntity: StaticDataT2FEntity = context.insertObject()

		// Partners.
		staticDataT2FEntity.mutablePartners.removeAllObjects()
		if let partnersArray = object.partners {
			for partner in partnersArray {
				let partnerEntity = PartnerEntity.insert(into: context, object: partner)
				staticDataT2FEntity.mutablePartners.add(partnerEntity)
			}
		}

		// Partnerships.
		staticDataT2FEntity.mutablePartnerships.removeAllObjects()
		if let partnershipsArray = object.partnerships {
			for partnership in partnershipsArray {
				let partnershipEntity = PartnershipEntity.insert(into: context, object: partnership)
				staticDataT2FEntity.mutablePartnerships.add(partnershipEntity)
			}
		}

		return staticDataT2FEntity
	}

	public func findPartner(with id: Int64) -> PartnerEntity? {
		let filteredPartners = partners?.filter { $0.partnerID == id }
		return filteredPartners?.first
	}

	public func findPartnership(with id: Int64) -> PartnershipEntity? {
		let filteredPartnerships = partnerships?.filter { $0.partnershipID == id }
		return filteredPartnerships?.first
	}
}

// MARK: - ManagedObjectType
extension StaticDataT2FEntity: ManagedObjectType {
	public static var entityName: String {
		return "StaticDataT2FEntity"
	}
}
