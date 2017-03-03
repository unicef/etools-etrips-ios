import Foundation
import CoreData
import Moya_ObjectMapper

typealias ActionPointsDownloadCompletionHandler = (Bool, Int?, NetworkError?) -> Void
typealias ActionPointsUpdateCompletionHandler = (Bool, NetworkError?) -> Void
typealias ActionPointsAddCompletionHandler = (Bool, NetworkError?) -> Void

/// Class responsible for loading action points data and storing it to the Core Data.
class ActionPointsService {
	func downloadActionPoints(userID: Int,
	                          page: Int,
	                          pageSize: Int,
	                          completion: @escaping ActionPointsDownloadCompletionHandler) {
		eTripsAPIProvider.request(.actionPoints(userID: userID, page: page, pageSize: pageSize)) { result in
			
			switch result {
				
			case let .success(response):
				
				let statusCode = response.statusCode
				
				if statusCode == 401 || statusCode == 403 {
					NotificationCenter.default.post(name: Notification.Name.UserDidLogOutNotification, object: self)
					return
				}
				
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
						ActionPointEntity.deleteAll(in: CoreDataStack.shared.managedObjectContext)
					}
					
					if !actionPoints.isEmpty {
						var pointsEntities = [ActionPointEntity]()
						
						// Sync adding.
						// Add new action points to the database.
						for actionPoint in actionPoints {
							let pointEntity =
								ActionPointEntity.findAndUpdateOrCreate(in: CoreDataStack.shared.managedObjectContext,
								                                        object: actionPoint)
							pointsEntities.append(pointEntity)
						}
						
						CoreDataStack.shared.saveContext()
						
						completion(true, feed.totalCount, nil)
						
					} else {
						completion(true, feed.totalCount, nil)
					}
					
				} catch {
					completion(false, nil, nil)
				}
				
			case let .failure(error):
				switch error {
				case .underlying(let nsError as NSError?):
					completion(false, nil, NetworkError(title: "Error", detail: nsError?.localizedDescription))
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
				
				if statusCode == 400 {
					completion(false, NetworkError(title: "Error",
					                               detail: "Verify action point. Due date cannot be earlier than today."))
					return
				}
				
				if statusCode == 401 || statusCode == 403 {
					NotificationCenter.default.post(name: Notification.Name.UserDidLogOutNotification, object: self)
					return
				}
				
				do {
					let parsedActionPoint: ActionPoint? = try response.mapObject(ActionPoint.self)
					
					guard let point = parsedActionPoint else {
						completion(false, nil)
						return
					}
					_ = ActionPointEntity.findAndUpdateOrCreate(in: CoreDataStack.shared.managedObjectContext,
					                                            object: point)
					
					completion(true, nil)
					
				} catch {
					completion(false, nil)
				}
				
			case let .failure(error):
				switch error {
				case .underlying(let nsError as NSError?):
					completion(false, NetworkError(title: "Error", detail: nsError?.localizedDescription))
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
				
				if statusCode == 400 {
					completion(false, NetworkError(title: "Error",
					                               detail: "Verify action point. Due date cannot be earlier than today."))
					return
				}
				
				if statusCode == 401 || statusCode == 403 {
					NotificationCenter.default.post(name: Notification.Name.UserDidLogOutNotification, object: nil)
					return
				}
				
				do {
					let parsedTrip: Trip? = try response.mapObject(Trip.self)
					
					guard let trip = parsedTrip else {
						completion(false, nil)
						return
					}
					
					let context = CoreDataStack.shared.managedObjectContext
					
					ActionPointEntity.deleteAll(forTripID: tripID, in: context)
					
					_ = TripEntity.findAndUpdateOrCreate(in: context,
					                                     object: trip,
					                                     type: nil)
					
					CoreDataStack.shared.saveContext()
					
					completion(true, nil)
					
				} catch {
					completion(false, nil)
				}
			case let .failure(error):
				switch error {
				case .underlying(let nsError as NSError?):
					completion(false, NetworkError(title: "Error", detail: nsError?.localizedDescription))
				default:
					completion(false, nil)
				}
			}
		}
	}
	
}
