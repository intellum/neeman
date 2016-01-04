import UIKit

public class Settings {
    public let appName: String
    public let baseURL: String

    public convenience init() {
        let path = NSBundle.mainBundle().pathForResource("Settings", ofType: "plist")
        self.init(path: path)
    }

    public init(path: String?) {
        var dict: NSDictionary?
        if let _ = path {
            dict = NSDictionary(contentsOfFile: path!)
        }
        appName = dict?["appName"] as? String ?? ""
        baseURL = dict?["baseURL"] as? String ?? ""
    }
}
