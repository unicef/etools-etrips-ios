import Foundation
import CoreData
import Moya_ObjectMapper

typealias TripsServiceCompletionHandler = (Bool, Int?, NetworkError?) -> Void

/// Class responsible for loading trips data and storing it to the Core Data.
class TripsService {
	var managedObjectContext = CoreDataStack.shared.managedObjectContext

	func downloadTrips(userID: Int,
	                   type: TripType,
	                   page: Int,
	                   pageSize: Int,
	                   completion: @escaping TripsServiceCompletionHandler) {
		
		eTripsAPIProvider.request(.trips(userID: userID, type: type, page: page, pageSize: pageSize)) { result in
			switch result {
			case let .success(response):
				let statusCode = response.statusCode

				switch statusCode {
				case 200...299:
					do {
						let parsedFeed: TripFeed? = try response.mapObject(TripFeed.self)

						guard let feed = parsedFeed else {
							completion(false, nil, nil)
							return
						}
 
						guard let trips = feed.trips else {
							completion(false, nil, nil)
							return
						}

						if page == 1 {
							TripEntity.deleteAll(in: self.managedObjectContext, with: type)
							CoreDataStack.shared.saveContext()
						}
						
						guard !trips.isEmpty else {
							completion(true, feed.totalCount, nil)
							return
						}
						
						var tripEntities = [TripEntity]()
						// Add new trips to the database.
						for trip in trips {
							let tripEntity =
								TripEntity.findAndUpdateOrCreate(in: CoreDataStack.shared.managedObjectContext,
																 object: trip,
																 type: type)
							tripEntities.append(tripEntity)
						}

						CoreDataStack.shared.saveContext()

						completion(true, feed.totalCount, nil)

					} catch {
						completion(false, nil, nil)
					}
				case 400:
					do {
						guard let json = try response.mapJSON() as? NSDictionary else {
							completion(false, nil, nil)
							return
						}
						
						guard let messages = json.allValues.first as? [String] else {
							completion(false, nil, nil)
							return
						}
						
						completion(false, nil, NetworkError(title: "Error", detail: messages.first))
					} catch {
						completion(false, nil, nil)
					}
				case 401, 403:
					NotificationCenter.default.post(name: Notification.Name.UserDidLogOutNotification, object: self)
				default:
					completion(false, nil, nil)
				}
			case let .failure(error):
				switch error {
				case .underlying(let nsError):
					completion(false, nil, NetworkError(title: "Error", detail: nsError.localizedDescription))
				default:
					completion(false, nil, nil)
				}
			}
		}

	}
}
