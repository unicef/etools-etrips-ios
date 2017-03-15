import Foundation

typealias TransitionServiceCompletionHandler = (Bool, NetworkError?) -> Void

class TransitionService {
	func transition(tripID: Int, transition: TripTransition, rejectionNote: String?,
	                completion: @escaping TransitionServiceCompletionHandler) {
		eTripsAPIProvider.request(.transition(tripID: tripID, to: transition, rejectionNote: rejectionNote)) { result in
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
						_ = TripEntity.findAndUpdateOrCreate(in: CoreDataStack.shared.managedObjectContext,
						                                     object: trip,
						                                     type: nil)

						CoreDataStack.shared.saveContext()

						completion(true, nil)

					} catch {
						completion(false, nil)
					}
				case 400:
					do {
						if let json = try response.mapJSON() as? NSDictionary {
							if let messages = json.allValues.first as? [String] {
								completion(false, NetworkError(title: "Error", detail: messages.first))
							} else {
								completion(false, nil)
							}
						} else {
							completion(false, nil)
						}
					} catch {
						completion(false, nil)
					}
				case 401, 403:
					NotificationCenter.default.post(name: Notification.Name.UserDidLogOutNotification, object: self)
				default:
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
