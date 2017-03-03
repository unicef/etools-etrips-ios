import Foundation

/// Allows to configure project from .plist.
class Configuration {

	// Singleton instance.
	static let sharedInstance = Configuration()

	let currentConfigurationPlistKey = "Configuration"
	let configurationFileNamePlistKey = "ConfigurationFileName"

	var configuration: NSDictionary

	init() {
		// Take current configuration value from the "Info.plist".
		// Can be "Debug", "Staging", etc.
		let currentConfiguration =
			Bundle.main.infoDictionary![currentConfigurationPlistKey] as? String

		// Get configuration file name.
		// Configuration file contains info for each configuration.
		let configurationFileName =
			Bundle.main.infoDictionary![configurationFileNamePlistKey] as? String

		guard configurationFileName != nil else {
			fatalError("No Configuration property found in plist")
		}

		// Loads "Configurations.plist" and stores it to dictionary.
		// The configuration names are the keys of the "configuration" dictionary.
		let plistPath =
			Bundle.main.path(forResource: configurationFileName, ofType: "plist")!

		let dictionary = NSDictionary(contentsOfFile: plistPath)

		configuration =
			dictionary?.value(forKey: currentConfiguration!) as! NSDictionary
	}
}

extension Configuration {
	func baseURL() -> String {
		return configuration.object(forKey: "baseURL") as! String
	}
}
