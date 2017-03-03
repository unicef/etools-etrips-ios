import Foundation

typealias TripReportCompletionHandler = (Bool, NetworkError?) -> Void

/// Service updates report with text on remote and stores updated trip in Core Data.
class TripReportService {
	func sendReport(_ report: String, for trip: TripEntity, completion: @escaping TripReportCompletionHandler) {
		eTripsAPIProvider.request(.tripTextReport(report: report, trip: trip)) { result in
			switch result {
			case .success(_):
				completion(true, nil)
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
