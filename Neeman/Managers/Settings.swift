import UIKit

class Settings {
    static let sharedInstance = Settings()
    let appName: String
    let baseURL: String
    let logoutPage: String
    let recoverPasswordURL: String
    var color1: UIColor?
    var color2: UIColor?
    
    init() {
        var dict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("Settings", ofType: "plist") {
            dict = NSDictionary(contentsOfFile: path)
        }
        appName = dict!["AppName"] as! String
        baseURL = dict!["BaseURL"] as! String
        logoutPage = dict!["LogoutPage"] as! String
        recoverPasswordURL = dict!["RecoverPasswordURL"] as! String
 
        if let color1String = dict?["Color1"] as? String
        {
            color1 = UIColor(hex: color1String)
        }
        if let color2String = dict?["Color2"] as? String
        {
            color2 = UIColor(hex: color2String)
        }
    }
}