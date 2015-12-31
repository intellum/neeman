import UIKit
import KeychainAccess

public class Settings {
    public static var sharedInstanceForTesting: Settings?
    static var singleInstance = Settings()
    public static var sharedInstance: Settings {
        get {
            return sharedInstanceForTesting ?? singleInstance
        }
        set {
            sharedInstanceForTesting = newValue
        }
    }
    public let keychain: Keychain
    public let appName: String
    
    public let pathsToBlock: [String]
    var myAuthToken: String?
    public var authToken: String? {
        set {
            myAuthToken = newValue
            keychain["app_auth_cookie"] = newValue
        }
        get {
            if myAuthToken == nil {
                myAuthToken = keychain["app_auth_cookie"]
            }
            return myAuthToken ?? "not-set-yet"
        }
    }
    public var baseURLFromPlist: String
    public var baseURL: String {
        get {
            return keychain["users_base_url"] ?? self.baseURLFromPlist
        }
        set {
            var urlString = newValue
            if urlString.characters.last == "/" {
                urlString.removeAtIndex(urlString.endIndex.predecessor())
            }
            keychain["users_base_url"] = urlString
            baseURLFromPlist = urlString
        }
    }
    public let authCookieName: String?
    
    /**
     An optional regular expression to define on which pages a logout button should be placed
     in the right bar button item.
     
     ## Examples
       - /user/profile/me
       - /.*
     */
    public let logoutPage: String
    public let recoverPasswordURL: String
    public let color1: UIColor?
    public let color2: UIColor?
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
        appName = dict?["appName"] as? String ?? ""
        authCookieName = dict?["authCookieName"] as? String
        pathsToBlock = dict?["pathsToBlock"] as? [String] ?? []
        logoutPage = dict?["logoutPage"] as? String ?? ""
        recoverPasswordURL = dict?["recoverPasswordURL"] as? String ?? ""
 
        if let color1String = dict?["color1"] as? String {
            color1 = UIColor(hex: color1String)
        } else {
            color1 = nil
        }
        
        if let color2String = dict?["color2"] as? String {
            color2 = UIColor(hex: color2String)
        } else {
            color2 = nil
        }
        
        isNavbarDark = dict?["isNavbarDark"] as? Bool ?? false

        let keychainService = dict?["KeychainService"] as? String ?? "com.intellum.level"
        keychain = Keychain(service: keychainService)
        baseURLFromPlist = dict?["baseURL"] as? String ?? ""
    }
}
