import Foundation

struct Config {
    static var apiKey: String {
        guard let filePath = Bundle.main.path(forResource: "Config", ofType: "plist") else {
            fatalError("Couldn't find file 'Config.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "APIKey") as? String else {
            fatalError("Couldn't find key 'APIKey' in 'Config.plist'.")
        }
        return value
    }
}
