import Foundation

typealias TransitionServiceCompletionHandler = (Bool) -> Void

class TransitionService {
	func transition(tripID: Int, transition: TripTransition, rejectionNote: String?,
	                completion: @escaping TransitionServiceCompletionHandler) {
		eTripsAPIProvider.request(.transition(tripID: tripID, to: transition, rejectionNote: rejectionNote)) { result in
			switch result {
			case let .success(response):

				let statusCode = response.statusCode

				if statusCode == 401 || statusCode == 403 {
					NotificationCenter.default.post(name: Notification.Name.UserDidLogOutNotification, object: self)
					return
				}

				do {
					let parsedTrip: Trip? = try response.mapObject(Trip.self)

					guard let trip = parsedTrip else {
						completion(false)
						return
					}
					_ = TripEntity.findAndUpdateOrCreate(in: CoreDataStack.shared.managedObjectContext,
					                                     object: trip,
					                                     type: nil)

					CoreDataStack.shared.saveContext()

					completion(true)

				} catch {
					completion(false)
				}

			case .failure:
				completion(false)
			}
		}
	}
}
