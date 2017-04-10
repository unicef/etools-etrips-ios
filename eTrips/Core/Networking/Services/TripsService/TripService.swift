import Foundation

typealias TripServiceCompletionHandler = (Bool, NetworkError?) -> Void

/// Loading single trip by id.
class TripService {
	var managedObjectContext = CoreDataStack.shared.managedObjectContext

	func downloadTrip(tripID: Int, completion: @escaping TripServiceCompletionHandler) {
		eTripsAPIProvider.request(.trip(tripID: tripID)) { result in
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
						let tripEntity = TripEntity.findAndUpdateOrCreate(in: self.managedObjectContext,
						                                                  object: trip,
						                                                  type: nil)

						if tripEntity.isReportSubmitted {
							tripEntity.deleteLocalReport(in: self.managedObjectContext)
						}

						CoreDataStack.shared.saveContext()

						completion(true, nil)

					} catch {
						completion(false, nil)
					}
				case 400:
					do {
						guard let json = try response.mapJSON() as? NSDictionary else {
							completion(false, nil)
							return
						}

						guard let messages = json.allValues.first as? [String] else {
							completion(false, nil)
							return
						}

						completion(false, NetworkError(title: "Error", detail: messages.first))
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
				case .underlying(let nsError):
					completion(false, NetworkError(title: "Error", detail: nsError.localizedDescription))
				default:
					completion(false, nil)
				}
			}
		}

	}
}
