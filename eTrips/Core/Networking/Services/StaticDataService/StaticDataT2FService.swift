import Foundation

class StaticDataT2FService {
	func downloadStaticDataT2F(completion: @escaping (_ success: Bool, _ staticDataEntity: StaticDataT2FEntity?) -> Void) {
		eTripsAPIProvider.request(.staticDataT2F) { result in
			switch result {
			case let .success(response):
				do {
					
					let parsedStaticDataT2F: StaticDataT2F? = try response.mapObject(StaticDataT2F.self)
					
					if let staticDataT2F = parsedStaticDataT2F {
						let staticDataT2FEntity =
							StaticDataT2FEntity.insert(in: CoreDataStack.shared.managedObjectContext,
							                           object: staticDataT2F)
						
						CoreDataStack.shared.saveContext()
						completion(true, staticDataT2FEntity)
					} else {
						completion(false, nil)
					}
				} catch {
					completion(false, nil)
				}
				
			case .failure:
				completion(false, nil)
			}
			
		}
	}
}
