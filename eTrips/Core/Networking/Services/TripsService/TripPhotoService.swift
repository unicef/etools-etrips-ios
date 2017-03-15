import Foundation
import UIKit

typealias TripPhotoUploadCompletionHandler = (Bool, NetworkError?) -> Void
typealias TripPhotoDeleteCompletionHandler = (Bool) -> Void

/// Service uploads trip report photo to the server.
class TripPhotoService {
	func upload(photo: Data, caption: String, for trip: TripEntity,
	            completion: @escaping TripPhotoUploadCompletionHandler) {
		eTripsAPIProvider.request(.uploadTripPhoto(photo: photo, caption: caption, trip: trip)) { result in
			switch result {
			case let .success(response):
				let statusCode = response.statusCode
				
				switch statusCode {
					case 200...299:
						completion(true, nil)
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

	func delete(tripID: Int, photoID: Int, completion: @escaping TripPhotoDeleteCompletionHandler) {
		eTripsAPIProvider.request(.deleteTripPhoto(tripID: tripID, photoID: photoID)) { result in
			switch result {
			case .success:
				completion(true)
			case .failure:
				completion(false)
			}

		}
	}
}
