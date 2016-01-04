import WebKit

extension WKWebViewConfiguration {
    func setupWithSettings(settings: Settings) -> WKWebViewConfiguration {
        processPool = WebViewController.processPool
        if #available(iOS 9.0, *) {
            applicationNameForUserAgent = settings.appName
        }
        addJavascript()
        return self
    }
    
    func addJavascript() {
        addScript("AtDocumentStart.js", injectionTime: .AtDocumentStart)
        addScript("AtDocumentEnd.js", injectionTime: .AtDocumentEnd)
        //        js.addScript("FastClick.js", injectionTime: .AtDocumentEnd)
        addCSSScript()
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
        var content = ""
        do {
            if let path = NSBundle(forClass: WebViewController.self).pathForResource(fileName, ofType: "") {
                content += try String(contentsOfFile:path, encoding: NSUTF8StringEncoding)
            }
            if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "") {
                content += try String(contentsOfFile:path, encoding: NSUTF8StringEncoding)
            }
        } catch _ {
        }
        return content
    }
}