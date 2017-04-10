import Foundation
import CoreData
import Moya_ObjectMapper

typealias ActionPointsDownloadCompletionHandler = (Bool, Int?, NetworkError?) -> Void
typealias ActionPointsUpdateCompletionHandler = (Bool, NetworkError?) -> Void
typealias ActionPointsAddCompletionHandler = (Bool, NetworkError?) -> Void

/// Class responsible for loading action points data and storing it to the Core Data.
class ActionPointsService {
	var managedObjectContext = CoreDataStack.shared.managedObjectContext

	func downloadActionPoints(userID: Int,
	                          page: Int,
	                          pageSize: Int,
	                          completion: @escaping ActionPointsDownloadCompletionHandler) {
		eTripsAPIProvider.request(.actionPoints(userID: userID, page: page, pageSize: pageSize)) { result in
			
			switch result {
			case let .success(response):
				let statusCode = response.statusCode
				
				switch statusCode {
				case 200...299:
					do {
						let parsedFeed: ActionPointFeed? = try response.mapObject(ActionPointFeed.self)
						
						guard let feed = parsedFeed else {
							completion(false, nil, nil)
						}
						
						guard let actionPoints = feed.actionPoints else {
							completion(false, nil, nil)
							return
						}
						
						if page == 1 {
							ActionPointEntity.deleteAll(in: self.managedObjectContext)
						}
						
						guard !actionPoints.isEmpty else {
							completion(true, feed.totalCount, nil)
							return
						}
						
						var pointsEntities = [ActionPointEntity]()
						
						// Sync adding.
						// Add new action points to the database.
						for actionPoint in actionPoints {
							let pointEntity =
								ActionPointEntity.findAndUpdateOrCreate(in: self.managedObjectContext,
																		object: actionPoint)
							pointsEntities.append(pointEntity)
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
	
	func updateActionPoint(_ actionPoint: ActionPointEntity,
	                       completion: @escaping ActionPointsUpdateCompletionHandler) {
		eTripsAPIProvider.request(.updateActionPoint(point: actionPoint)) { result in
			switch result {
			case let .success(response):
				let statusCode = response.statusCode
				
				switch statusCode {
				case 200...299:
					do {
						let parsedActionPoint: ActionPoint? = try response.mapObject(ActionPoint.self)
						
						guard let point = parsedActionPoint else {
							completion(false, nil)
							return
						}
						_ = ActionPointEntity.findAndUpdateOrCreate(in: self.managedObjectContext,
						                                            object: point)
						
						completion(true, nil)
					} catch {
						completion(false, nil)
					}
				case 400:
					completion(false, NetworkError(title: "Error",
					                               detail: "Please, verify action point. Some information is missing or incorrect"))
				case 401, 403:
					NotificationCenter.default.post(name: Notification.Name.UserDidLogOutNotification, object: self)
				default:
					completion(false, nil)
				}
				
			case let .failure(error):
				switch error {
				case .underlying(let nsError):
					completion(false, NetworkError(title: "Error", detail: nsError.localizedDescription))
				default:
					completion(false, nil)
				}
			}
		}
	}
	
	func addActionPoint(_ actionPoints: [ActionPointEntity],
	                    forTripID tripID: Int,
	                    completion: @escaping ActionPointsAddCompletionHandler) {
		eTripsAPIProvider.request(.addActionPoint(points: actionPoints, tripID: tripID)) { result in
			switch result {
			case let .success(response):
				let statusCode = response.statusCode
				
				switch statusCode {
				case 200...299:
					do {
						let parsedTrip: Trip? = try response.mapObject(Trip.self)
						
						guard let trip = parsedTrip else {
							completion(false, nil)
							return
						}
						
						ActionPointEntity.deleteAll(forTripID: tripID, in: self.managedObjectContext)
						
						_ = TripEntity.findAndUpdateOrCreate(in: self.managedObjectContext,
						                                     object: trip,
						                                     type: nil)
						
						CoreDataStack.shared.saveContext()
						
						completion(true, nil)
						
					} catch {
						completion(false, nil)
					}
				case 400:
					completion(false,
					           NetworkError(title: "Error",
					                        detail: "Please, verify action point. Some information is missing or incorrect"))
				case 401, 403:
					NotificationCenter.default.post(name: Notification.Name.UserDidLogOutNotification, object: nil)
				default:
					completion(false, nil)
				}
			case let .failure(error):
				switch error {
				case .underlying(let nsError):
					completion(false, NetworkError(title: "Error", detail: nsError.localizedDescription))
				default:
					completion(false, nil)
				}
			}
		}
	}
	
}
