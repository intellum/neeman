import WebKit

extension WKWebViewConfiguration {
    
    /**
     Initialise with some common setup for Neeman.
     
     - parameter settings: Settings to use to setup.
     
     - returns: An initialized object.
     */
    convenience init(settings: Settings) {
        self.init()
        processPool = ProcessPool.sharedInstance
        if #available(iOS 9.0, *) {
            applicationNameForUserAgent = settings.appName
        }
        addJavascript()
    }
    
    /**
     Add the Javascript that adds CSS aswell as the AtDocumentStart.js and AtDocumentEnd.js scripts.
     */
    func addJavascript() {
        addCSSScript()
        addScript("AtDocumentStart.js", injectionTime: .AtDocumentStart)
        addScript("AtDocumentEnd.js", injectionTime: .AtDocumentEnd)
        //        js.addScript("FastClick.js", injectionTime: .AtDocumentEnd)
    }
    
    /**
     Inject a script at the specified injection time.
     
     - parameter scriptName:    The name of the script to inject.
     - parameter injectionTime: The point at which to inject the script.
     */
    func addScript(scriptName: String, injectionTime: WKUserScriptInjectionTime) {
        let content = stringFromContentInFileName(scriptName)
        let script = WKUserScript(source: content, injectionTime: injectionTime, forMainFrameOnly: true)
        userContentController.addUserScript(script)
    }
    
    /**
     Injects WebView.css into the page.
     */
    func addCSSScript() {
        var javascript = stringFromContentInFileName("InjectCSS.js")
        var css = stringFromContentInFileName("WebView.css")
        css = css.stringByReplacingOccurrencesOfString("\n", withString: "\\\n")
        javascript = javascript.stringByReplacingOccurrencesOfString("${CSS}", withString: css)
        
        let script = WKUserScript(source: javascript, injectionTime: .AtDocumentStart, forMainFrameOnly: true)
        userContentController.addUserScript(script)
    }
    
    /**
     Gets the content of the file with the specified name.
     
     - parameter fileName: The name of the file to load content from.
     
     - returns: The contets of the file.
     */
    func stringFromContentInFileName(fileName: String) -> String! {
        return contentsOfNeemansWithName(fileName) + contentsOfMainBundlesFileWithName(fileName)
    }
    
    /**
     Gets the content of the file with the specified name from the Neeman bundle.
     
     - parameter fileName: The name of the file to load content from.
     
     - returns: The contets of the file.
     */
    func contentsOfNeemansWithName(fileName: String) -> String {
        let bundle = NSBundle(forClass: WebViewController.self)
        return contentsOfFileNamed(fileName, inBundle: bundle)
    }

    /**
     Gets the content of the file with the specified name from the main bundle.
     
     - parameter fileName: The name of the file to load content from.
     
     - returns: The contets of the file.
     */
    func contentsOfMainBundlesFileWithName(fileName: String) -> String {
        let bundle = NSBundle.mainBundle()
        return contentsOfFileNamed(fileName, inBundle: bundle)
    }

    /**
     Gets the content of the file with the specified name from the specified bundle.
     
     - parameter fileName: The name of the file to load content from.
     
     - returns: The contets of the file.
     */
    func contentsOfFileNamed(fileName: String, inBundle bundle: NSBundle) -> String {
        if let path = bundle.pathForResource(fileName, ofType: "") {
            return contentsOfFileAtPath(path)
        }
        return ""
    }
    
    /**
     Gets the content of the file with the specified name from the specified path.
     
     - parameter fileName: The name of the file to load content from.
     
     - returns: The contets of the file.
     */
    func contentsOfFileAtPath(filePath: String) -> String {
        var content = ""
        do {
            content += try String(contentsOfFile:filePath, encoding: NSUTF8StringEncoding)
        } catch _ {
        }
        return content
    }
}
