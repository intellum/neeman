public extension FileManager {
    public func plistDictionaryNamed(_ name: String) -> [AnyHashable: Any]? {
        guard let plistPath = Bundle.main.path(forResource: name, ofType: "plist") else {
            return nil
        }
        return plistDictionaryAtPath(plistPath)
    }

    public func plistDictionaryAtPath(_ path: String) -> [AnyHashable: Any]? {
        var plistData: [AnyHashable: Any] = [:]
        let plistXML = FileManager.default.contents(atPath: path)!
        var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml //Format of the Property List.
        do {
            plistData = try PropertyListSerialization.propertyList(from: plistXML,
                                                                   options: .mutableContainersAndLeaves,
                                                                   format: &propertyListFormat) as? [String:AnyObject] ?? [:]
            
        } catch {
            print("Error reading plist: \(error), format: \(propertyListFormat)")
        }
        return plistData
    }
}

/// This contains some optional settings that are loaded from Settings.plist in the main bundle.
open class NeemanSettings {
    /// Set this if you would like some extra logging.
    open let debug: Bool
    /// You can set this yourself but otherwise it is taken from CFBundleName.
    open let appName: String
    /// This can be set to enable the use of relative URLs in the web view controllers URLString property.
    open let baseURL: String
    /// This stores all the settings loaded from the initialising object. These can be accessed through object subscripting.
    let allSettings: [AnyHashable: Any]

    /**
     Creates a Settings object by loading Settings.plist.
     */
    public convenience init() {
        var path = Bundle.main.path(forResource: "Settings", ofType: "plist")
        if path == nil {
            path = Bundle(for: type(of: self)).path(forResource: "Settings", ofType: "plist")
        }
        self.init(path: path ?? "")
    }

    /**
     Creates a Settings object by loading the contents of the .plist at the supplied path.
     
     - parameter path: The path to the .plist file to load the setting from.
     */
    public convenience init(path: String) {
        self.init(dictionary: FileManager.default.plistDictionaryAtPath(path)!)
    }
    
    /**
     Creates a Settings object by loading the setting from the supplied dictionary.
     
     - parameter dictionary: A dictionary containing the desired settings.
     */
    public init(dictionary: [AnyHashable: Any]) {
        allSettings = dictionary
        debug = allSettings["debug"] as? Bool ?? false
        appName = allSettings["appName"] as? String ?? Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
        baseURL = allSettings["baseURL"] as? String ?? ""
    }
    
    /**
     Allows us to access settings using a subscript. i.e. settings["appName"].
     
     - parameter key: The key for setting. This is the same as the key in the plist or dictionary with the settings.
     
     - returns: The setting for the supplied key.
     */
    open subscript(key: String) -> AnyObject? {
        get {
            return allSettings[key] as AnyObject?
        }
    }
}
