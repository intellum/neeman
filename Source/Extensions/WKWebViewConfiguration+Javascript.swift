import WebKit

extension WKWebViewConfiguration {
    func setupWithSettings(settings: Settings) -> WKWebViewConfiguration {
        processPool = ProcessPool.sharedInstance
        if #available(iOS 9.0, *) {
            applicationNameForUserAgent = settings.appName
        }
        addJavascript()
        return self
    }
    
    func addJavascript() {
        addCSSScript()
        addScript("AtDocumentStart.js", injectionTime: .AtDocumentStart)
        addScript("AtDocumentEnd.js", injectionTime: .AtDocumentEnd)
        //        js.addScript("FastClick.js", injectionTime: .AtDocumentEnd)
    }
    
    func addScript(scriptName: String, injectionTime: WKUserScriptInjectionTime) {
        let content = stringFromContentInFileName(scriptName)
        let script = WKUserScript(source: content, injectionTime: injectionTime, forMainFrameOnly: true)
        userContentController.addUserScript(script)
    }
    
    func addCSSScript() {
        var javascript = stringFromContentInFileName("InjectCSS.js")
        var css = stringFromContentInFileName("WebView.css")
        css = css.stringByReplacingOccurrencesOfString("\n", withString: "\\\n")
        javascript = javascript.stringByReplacingOccurrencesOfString("${CSS}", withString: css)
        
        let script = WKUserScript(source: javascript, injectionTime: .AtDocumentStart, forMainFrameOnly: true)
        userContentController.addUserScript(script)
    }
    
    func stringFromContentInFileName(fileName: String) -> String! {
        return contentsOfNeemansWithName(fileName) + contentsOfMainBundlesFileWithName(fileName)
    }
    
    func contentsOfNeemansWithName(fileName: String) -> String {
        let bundle = NSBundle(forClass: object_getClass(self))
        return contentsOfFileNamed(fileName, inBundle: bundle)
    }

    func contentsOfMainBundlesFileWithName(fileName: String) -> String {
        let bundle = NSBundle.mainBundle()
        return contentsOfFileNamed(fileName, inBundle: bundle)
    }

    func contentsOfFileNamed(fileName: String, inBundle bundle: NSBundle) -> String {
        if let path = bundle.pathForResource(fileName, ofType: "") {
            return contentsOfFileAtPath(path)
        }
        return ""
    }
    
    func contentsOfFileAtPath(filePath: String) -> String {
        var content = ""
        do {
            content += try String(contentsOfFile:filePath, encoding: NSUTF8StringEncoding)
        } catch _ {
        }
        return content
    }
}
