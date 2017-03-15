import Foundation

class StaticDataService {
	func downloadStaticData(completion: @escaping (_ success: Bool, _ staticDataEntity: StaticDataEntity?) -> Void) {
		eTripsAPIProvider.request(.staticData) { result in
			switch result {
			case let .success(response):
				let statusCode = response.statusCode
				switch statusCode {
				case 200...299:
					do {
						let parsedStaticData: StaticData? = try response.mapObject(StaticData.self)
						
						if let staticData = parsedStaticData {
							let staticDataEntity =
								StaticDataEntity.insert(in: CoreDataStack.shared.managedObjectContext, object: staticData)
							
							CoreDataStack.shared.saveContext()
							completion(true, staticDataEntity)
						} else {
							completion(false, nil)
						}
					} catch {
						completion(false, nil)
					}
				default:
					completion(false, nil)
				}
				
			case .failure:
				completion(false, nil)
			}
		}
	}
}
