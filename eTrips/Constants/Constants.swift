import Foundation

/// Struct contains all application needed constants.
struct Constants {
    /// Storyboard names constants.
    struct Storyboard {
        static let Authentication = "Authentication"
        static let TabBar = "TabBar"
        static let Trips = "Trips"
        static let Settings = "Settings"
        static let ActionPoints = "ActionPoints"
        static let Profile = "Profile"
    }

    /// UserDefaults keys constants.
    struct UserDefaults {
        static let FirstLaunchKey = "FirstLaunchKey"
    }

    /// Cache.
    struct Cache {
        static let Profile = "Profile"
    }

    /// Hockey SDK keys.
    struct HockeySDK {
        static let stagingAppIdentifier = "78445491ff6b41218e9d9ad489f658a2"
        static let productionAppIdentifier = "b8c800962c0f45a7956f43137f756a76"
    }
}
