import WebKit

class WebViewConfiguration: WKWebViewConfiguration {

    private var defaultApplicationNameForUserAgent: String {
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
        let bundleVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        return "/Version/\(appVersion)(\(bundleVersion)) Mobile/\(appName)/Neeman iOS"
    }

    /**
     Initialise with some common setup for Neeman.
     
     - parameter settings: Settings to use to setup.
     */
    override init() {
        super.init()
        processPool = ProcessPool.sharedInstance
        applicationNameForUserAgent = defaultApplicationNameForUserAgent
        if #available(iOS 10.0, *) {
            mediaTypesRequiringUserActionForPlayback = []
        } else {
            requiresUserActionForMediaPlayback = false
        }
        allowsInlineMediaPlayback = true
        addJavascript()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Add the Javascript that adds CSS aswell as the AtDocumentStart.js and AtDocumentEnd.js scripts.
     */
    func addJavascript() {
        addCSSScript()
        addScript("AtDocumentStart.js", injectionTime: .atDocumentStart)
        addScript("AtDocumentEnd.js", injectionTime: .atDocumentEnd)
    }
    
    /**
     Injects WebView.css into the page.
     */
    func addCSSScript() {
        let script = WKUserScript(source: Injector().javascriptForCSS(),
                                  injectionTime: .atDocumentStart,
                                  forMainFrameOnly: true)
        userContentController.addUserScript(script)
    }
}

extension WKWebViewConfiguration {
    /**
     Inject a script at the specified injection time.
     
     - parameter scriptName:    The name of the script to inject.
     - parameter injectionTime: The point at which to inject the script.
     */
    public func addScript(_ scriptName: String, injectionTime: WKUserScriptInjectionTime) {
        let content = Injector().stringFromContentInFileName(scriptName)
        let script = WKUserScript(source: content!, injectionTime: injectionTime, forMainFrameOnly: false)
        userContentController.addUserScript(script)
    }
}
