import WebKit

extension WKWebViewConfiguration {
    
    /**
     Initialise with some common setup for Neeman.
     
     - parameter settings: Settings to use to setup.
     */
    convenience init(settings: NeemanSettings) {
        self.init()
        processPool = ProcessPool.sharedInstance
        applicationNameForUserAgent = "Version/\(settings.appVersion)(\(settings.bundleVersion)) Mobile/Neeman iOS"
        if #available(iOS 10.0, *) {
            mediaTypesRequiringUserActionForPlayback = []
        } else {
            requiresUserActionForMediaPlayback = false
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
    }
    
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
