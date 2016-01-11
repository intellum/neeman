import UIKit

public class Settings {
    public let appName: String
    public let baseURL: String
    let allSettings: NSDictionary?

    public convenience init() {
        let path = NSBundle.mainBundle().pathForResource("Settings", ofType: "plist")
        self.init(path: path)
    }

    public convenience init(path: String?) {
        var dict: NSDictionary?
        if let _ = path {
            dict = NSDictionary(contentsOfFile: path!)
        }
        self.init(dictionary: dict)
    }
    
    public init(dictionary: NSDictionary?) {
        allSettings = dictionary
        appName = allSettings?["appName"] as? String ?? NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? String ?? ""
        baseURL = allSettings?["baseURL"] as? String ?? ""
    }
    
    public subscript(key: String) -> AnyObject? {
        get {
            return allSettings?[key]
        }
    }
}
