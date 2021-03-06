import Foundation

typealias TripReportCompletionHandler = (Bool, NetworkError?) -> Void

/// Service updates report with text on remote and stores updated trip in Core Data.
class TripReportService {
	func sendReport(_ report: String, for trip: TripEntity, completion: @escaping TripReportCompletionHandler) {
		eTripsAPIProvider.request(.tripTextReport(report: report, trip: trip)) { result in
			switch result {
			case let .success(response):
				let statusCode = response.statusCode
				switch statusCode {
				case 200...299:
					completion(true, nil)
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
