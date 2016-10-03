/// This contains some optional settings that are loaded from Settings.plist in the main bundle.
open class NeemanSettings {
    /// Set this if you would like some extra logging.
    open let debug: Bool
    /// You can set this yourself but otherwise it is taken from CFBundleName.
    open let appName: String
    /// This can be set to enable the use of relative URLs in the web view controllers URLString property.
    open let baseURL: String
    /// This stores all the settings loaded from the initialising object. These can be accessed through object subscripting.
    let allSettings: NSDictionary?

    /**
     Creates a Settings object by loading Settings.plist.
     */
    public convenience init() {
        let path = Bundle.main.path(forResource: "Settings", ofType: "plist")
        self.init(path: path)
    }

    /**
     Creates a Settings object by loading the contents of the .plist at the supplied path.
     
     - parameter path: The path to the .plist file to load the setting from.
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
     */
    public init(dictionary: NSDictionary?) {
        allSettings = dictionary
        debug = allSettings?["debug"] as? Bool ?? false
        appName = allSettings?["appName"] as? String ?? Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
        baseURL = allSettings?["baseURL"] as? String ?? ""
    }
    
    /**
     Allows us to access settings using a subscript. i.e. settings["appName"].
     
     - parameter key: The key for setting. This is the same as the key in the plist or dictionary with the settings.
     
     - returns: The setting for the supplied key.
     */
    open subscript(key: String) -> AnyObject? {
        get {
            return allSettings?[key] as AnyObject?
        }
    }
}
