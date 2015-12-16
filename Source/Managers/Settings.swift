import UIKit

public class Settings {
    public static var sharedInstanceForTesting: Settings?
    public static var sharedInstance: Settings {
        get {
            return sharedInstanceForTesting ?? Settings()
        }
        set {
            sharedInstanceForTesting = newValue
        }
    }
    public let appName: String
    public let baseURL: String
    public let authCookieName: String?
    public let keychainService: String
    public let logoutPage: String
    public let recoverPasswordURL: String
    public var color1: UIColor?
    public var color2: UIColor?
    public let isNavbarDark: Bool

    convenience init() {
        let path = NSBundle.mainBundle().pathForResource("Settings", ofType: "plist")
        self.init(path: path)
    }

    public init(path: String?) {
        var dict: NSDictionary?
        if let _ = path {
            dict = NSDictionary(contentsOfFile: path!)
        }
        
        appName = dict?["AppName"] as? String ?? ""
        baseURL = dict?["BaseURL"] as? String ?? ""
        authCookieName = dict?["AuthCookieName"] as? String ?? ""
        keychainService = dict?["KeychainService"] as? String ?? "com.intellum.level"
        logoutPage = dict?["LogoutPage"] as? String ?? ""
        recoverPasswordURL = dict?["RecoverPasswordURL"] as? String ?? ""
 
        if let color1String = dict?["Color1"] as? String {
            color1 = UIColor(hex: color1String)
        }
        
        if let color2String = dict?["Color2"] as? String {
            color2 = UIColor(hex: color2String)
        }
        
        isNavbarDark = dict?["IsNavbarDark"] as? Bool ?? false
    }
}
