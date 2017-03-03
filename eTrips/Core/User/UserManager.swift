import Foundation
import KeychainAccess

/// Class responsible for managing user token and storing it to the keychain.
class UserManager {
	
	static let shared = UserManager()
	
	public var token: String? {
		get {
			return keychain["token"]
		}
		set {
			keychain["token"] = newValue
		}
	}
	
	public var profileEntity: ProfileEntity? {
		return ProfileEntity.profileEntityForLoggedInUser(in: CoreDataStack.shared.managedObjectContext)
	}
	
	public var userID: Int? {
		guard let profile = profileEntity else {
			return nil
		}
		return Int(profile.profileID)
	}
	
	public var isLoggedIn: Bool {
		return keychain["token"] != nil
	}
	
	private let keychain: Keychain = Keychain(service: "org.eTrips-token")
}
