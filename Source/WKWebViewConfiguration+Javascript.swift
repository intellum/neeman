import WebKit

extension WKWebViewConfiguration {
    
    /**
     Initialise with some common setup for Neeman.
     
     - parameter settings: Settings to use to setup.
     */
    convenience init(settings: NeemanSettings) {
        self.init()
        processPool = ProcessPool.sharedInstance
        if #available(iOS 9.0, *) {
            applicationNameForUserAgent = "Neeman \(settings.appName) iOS"
        }
        addJavascript()
    }
    
    /**
     Add the Javascript that adds CSS aswell as the AtDocumentStart.js and AtDocumentEnd.js scripts.
     */
    func addJavascript() {
        addCSSScript()
        addScript("AtDocumentStart.js", injectionTime: .atDocumentStart)
        addScript("AtDocumentEnd.js", injectionTime: .atDocumentEnd)
        //        js.addScript("FastClick.js", injectionTime: .AtDocumentEnd)
    }
    
    /**
     Inject a script at the specified injection time.
     
     - parameter scriptName:    The name of the script to inject.
     - parameter injectionTime: The point at which to inject the script.
     */
    public func addScript(_ scriptName: String, injectionTime: WKUserScriptInjectionTime) {
        let content = stringFromContentInFileName(scriptName)
        let script = WKUserScript(source: content!, injectionTime: injectionTime, forMainFrameOnly: false)
        userContentController.addUserScript(script)
    }
    
    /**
     Injects WebView.css into the page.
     */
    func addCSSScript() {
        let script = WKUserScript(source: javascriptForCSS(),
                                  injectionTime: .atDocumentStart,
                                  forMainFrameOnly: true)
        userContentController.addUserScript(script)
    }
    
    /**
     Returns the javascript required to inject the Neeman CSS.
     
     - returns: The processed javascript.
     */
    func javascriptForCSS() -> String {
        var javascript = stringFromContentInFileName("InjectCSS.js")
        javascript = javascriptWithCSSAddedToJavascript(javascript!)
        javascript = javascriptWithVersionAddedToJavascript(javascript!)
        
        return javascript!
    }
    
    /**
     Returns the javascript with the "${CSS}" template replaced with the apps CSS.
     
     - parameter javascript: The javascript to add the CSS to.
     
     - returns: The processed javascript.
     */
    func javascriptWithCSSAddedToJavascript(_ javascript: String) -> String {
        var css = stringFromContentInFileName("WebView.css")
        css = css?.replacingOccurrences(of: "\n", with: "\\\n")
        
        return javascript.replacingOccurrences(of: "${CSS}", with: css!)
    }
    
    /**
     Returns the javascript with the "${VERSION}" template replaced with the current version of the app.
     
     - parameter javascript: The javascript to add the version to.
     
     - returns: The processed javascript.
     */
    func javascriptWithVersionAddedToJavascript(_ javascript: String) -> String {
        var versionForCSS = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionForCSS = version.replacingOccurrences(of: ".", with: "_")
        }
        
        return javascript.replacingOccurrences(of: "${VERSION}", with: versionForCSS)
    }
    
    /**
     Gets the content of the file with the specified name.
     
     - parameter fileName: The name of the file to load content from.
     
     - returns: The contets of the file.
     */
    func stringFromContentInFileName(_ fileName: String) -> String! {
        return contentsOfNeemansWithName(fileName) + contentsOfMainBundlesFileWithName(fileName)
    }
    
    /**
     Gets the content of the file with the specified name from the Neeman bundle.
     
     - parameter fileName: The name of the file to load content from.
     
     - returns: The contets of the file.
     */
    func contentsOfNeemansWithName(_ fileName: String) -> String {
        let bundle = Bundle(for: WebViewController.self)
        return contentsOfFileNamed(fileName, inBundle: bundle)
    }

    /**
     Gets the content of the file with the specified name from the main bundle.
     
     - parameter fileName: The name of the file to load content from.
     
     - returns: The contets of the file.
     */
    func contentsOfMainBundlesFileWithName(_ fileName: String) -> String {
        let bundle = Bundle.main
        return contentsOfFileNamed(fileName, inBundle: bundle)
    }

    /**
     Gets the content of the file with the specified name from the specified bundle.
     
     - parameter fileName: The name of the file to load content from.
     - parameter bundle: The bundle in which to look for the named file.
     
     - returns: The contets of the file.
     */
    func contentsOfFileNamed(_ fileName: String, inBundle bundle: Bundle) -> String {
        if let path = bundle.path(forResource: fileName, ofType: "") {
            return contentsOfFileAtPath(path)
        }
        return ""
    }
    
    /**
     Gets the content of the file with the specified name from the specified path.
     
     - parameter filePath: The path to the file to load content from.
     
     - returns: The contets of the file.
     */
    func contentsOfFileAtPath(_ filePath: String) -> String {
        var content = ""
        do {
            content += try String(contentsOfFile:filePath, encoding: String.Encoding.utf8)
        } catch _ {
        }
        return content
    }
}
