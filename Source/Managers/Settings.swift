import UIKit

public class Settings {
    public let appName: String
    public let baseURL: String
    let allSettings: NSDictionary?

    public convenience init() {
        let path = NSBundle.mainBundle().pathForResource("Settings", ofType: "plist")
        self.init(path: path)
    }

    public init(path: String?) {
        if let _ = path {
            allSettings = NSDictionary(contentsOfFile: path!)
        } else {
            allSettings = nil
        }
        appName = allSettings?["appName"] as? String ?? NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? String ?? ""
        baseURL = allSettings?["baseURL"] as? String ?? ""
    }
    
    public subscript(key: String) -> AnyObject? {
        get {
            return allSettings?[key]
        }
    }
    
    func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? Settings {
            return allSettings == object.allSettings
        } else {
            return false
        }
    }
    
    var hash: Int {
        return allSettings?.hashValue ?? 0
    }
}
