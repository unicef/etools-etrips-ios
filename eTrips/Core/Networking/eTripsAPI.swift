import Foundation
import Moya

public enum TripTransition: String {
    case submitForApproval = "submit_for_approval"
    case approve
    case approveCertificate = "approve_certificate"
    case reject
    case rejectСertificate = "reject_certificate"
}

enum eTripsAPI {
    case login(username: String, password: String)
    case users
    case trips(userID: Int, type: TripType, page: Int, pageSize: Int)
    case trip(tripID: Int)
    case tripTextReport(report: String, trip: TripEntity)
    case uploadTripPhoto(photo: Data, caption: String, trip: TripEntity)
    case deleteTripPhoto(tripID: Int, photoID: Int)
    case profile
    case transition(tripID: Int, to: TripTransition, rejectionNote: String?)
    case staticData
    case staticDataT2F
    case wbsGrantsFunds(businessArea: Int)
    case actionPoints(userID: Int, page: Int, pageSize: Int)
    case updateActionPoint(point: ActionPointEntity)
    case addActionPoint(points: [ActionPointEntity], tripID: Int)
    case currencies
}

let endpointClosure = { (target: eTripsAPI) -> Endpoint<eTripsAPI> in
    let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)

    switch target {
    case .login:
        return defaultEndpoint
    case .users, .trips, .trip, .tripTextReport, .profile, .uploadTripPhoto, .deleteTripPhoto,
         .staticData, .staticDataT2F, .actionPoints, .transition, .updateActionPoint, .addActionPoint,
         .wbsGrantsFunds, .currencies:
        if let token = UserManager.shared.token {
            return defaultEndpoint.adding(newHTTPHeaderFields: ["Authorization": "JWT " + token])
        } else {
            return defaultEndpoint
        }
    }
}

let eTripsAPIProvider = MoyaProvider<eTripsAPI>(endpointClosure: endpointClosure,
                                                manager: DefaultAlamofireManager.shared)

extension eTripsAPI: TargetType {
    var baseURL: URL {
        return URL(string: Configuration.sharedInstance.baseURL())!
    }

    var path: String {
        switch self {
        case .login:
            return "/login/token-auth/"
        case .users:
            return "/api/users/"
        case .trips:
            return "/api/t2f/travels/"
        case .trip(let tripID):
            return "/api/t2f/travels/\(tripID)/"
        case .tripTextReport(_, let trip):
            return "/api/t2f/travels/\(trip.tripID)/"
        case .uploadTripPhoto(_, _, let trip):
            return "/api/t2f/travels/\(trip.tripID)/attachments/"
        case .deleteTripPhoto(let tripID, let photoID):
            return "/api/t2f/travels/\(tripID)/attachments/\(photoID)/"
        case .profile:
            return "/users/api/profile/"
        case .staticData:
            return "/api/static_data/"
        case .staticDataT2F:
            return "/api/t2f/static_data/"
        case .actionPoints:
            return "/api/t2f/action_points/"
        case .transition(let tripID, let transition, _):
            return "/api/t2f/travels/\(tripID)/\(transition.rawValue)/"
        case .updateActionPoint(let point):
            return "/api/t2f/action_points/\(point.pointID)/"
        case .addActionPoint(_, let tripID):
            return "/api/t2f/travels/\(tripID)/"
        case .wbsGrantsFunds:
            return "/api/wbs_grants_funds/"
        case .currencies:
            return "/api/currencies/"
        }
    }

    var method: Moya.Method {
        switch self {
        case .users, .trips, .trip, .profile, .staticData,
             .staticDataT2F, .actionPoints, .wbsGrantsFunds, .currencies:
            return .get
        case .tripTextReport, .transition, .updateActionPoint, .addActionPoint:
            return .patch
        case .login, .uploadTripPhoto:
            return .post
        case .deleteTripPhoto:
            return .delete
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .login(let username, let password):
            return ["username": username, "password": password]
        case .trips(let userID, let type, let page, let pageSize):
            switch type {
            case .myTrip:
                return ["f_traveler": userID, "page": page, "page_size": pageSize, "sort_by": "start_date"]
            case .supervised:
                return ["f_supervisor": userID, "page": page, "page_size": pageSize, "sort_by": "start_date"]
            }
        case .tripTextReport(let report, _):
            return ["report": report]
        case .actionPoints(let userID, let page, let pageSize):
            return ["f_person_responsible": userID, "page": page, "page_size": pageSize, "sort_by": "due_date"]
        case .updateActionPoint(let point):
            return point.dictionaryValue()
        case .addActionPoint(let points, _):
            return ["action_points": points.map { $0.dictionaryValue() }]
        case .transition(_, _, let rejectionNote):
            guard let rejectionNote = rejectionNote else {
                return ["rejection_note": NSNull()]
            }
            return ["rejection_note": rejectionNote]
        case .users:
            return ["verbosity": "minimal"]
        case .wbsGrantsFunds(let businessArea):
            return ["business_area": businessArea]
        default:
            return nil
        }
    }

    var parameterEncoding: ParameterEncoding {
        switch self {
        case .trips, .actionPoints, .users, .wbsGrantsFunds:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }

    var sampleData: Data {
        return "SampleData".utf8Encoded
    }

    var task: Task {
        switch self {
        case .uploadTripPhoto(let photo, let caption, _):
            return .upload(.multipart([MultipartFormData(provider: .data(photo),
                                                         name: "file",
                                                         fileName: "image.png",
                                                         mimeType: "image/png"),
                                       MultipartFormData(provider: .data(caption.data(using: .utf8)!),
                                                         name: "name",
                                                         fileName: nil,
                                                         mimeType: "text"),
                                       MultipartFormData(provider: .data("Picture".data(using: .utf8)!),
                                                         name: "type",
                                                         fileName: nil,
                                                         mimeType: "text")]))
        default:
            return .request
        }
    }
}

// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var utf8Encoded: Data {
        return self.data(using: .utf8)!
    }
}
