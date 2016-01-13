/// This contains some optional settings that are loaded from Settings.plist in the main bundle.
public class Settings {
    /// Set this if you would like some extra logging.
    public let debug: Bool
    /// You can set this yourself but otherwise it is taken from CFBundleName.
    public let appName: String
    /// This can be set to enable the use of relative URLs in the web view controllers rootURLString property.
    public let baseURL: String
    /// This stores all the settings loaded from the initialising object. These can be accessed through object subscripting.
    let allSettings: NSDictionary?

    /**
     Creates a Settings object by loading Settings.plist.
     
     - returns: A new Settings object.
     */
    public convenience init() {
        let path = NSBundle.mainBundle().pathForResource("Settings", ofType: "plist")
        self.init(path: path)
    }

    /**
     Creates a Settings object by loading the contents of the .plist at the supplied path.
     
     - parameter path: The path to the .plist file to load the setting from.
     
     - returns: A new Settings object.
     */
    public convenience init(path: String?) {
        var dict: NSDictionary?
        if let _ = path {
            dict = NSDictionary(contentsOfFile: path!)
        }
        self.init(dictionary: dict)
    }
    
    /**
     Creates a Settings object by loading the setting from the supplied dictionary.
     
     - parameter dictionary: A dictionary containing the desired settings.
     
     - returns: A new Settings object.
     */
    public init(dictionary: NSDictionary?) {
        allSettings = dictionary
        debug = allSettings?["debug"] as? Bool ?? false
        appName = allSettings?["appName"] as? String ?? NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? String ?? ""
        baseURL = allSettings?["baseURL"] as? String ?? ""
    }
    
    /**
     Allows us to access settings using a subscript. i.e. settings["appName"].
     
     - parameter key: The key for setting. This is the same as the key in the plist or dictionary with the settings.
     
     - returns: The setting for the supplied key.
     */
    public subscript(key: String) -> AnyObject? {
        get {
            return allSettings?[key]
        }
    }
}
