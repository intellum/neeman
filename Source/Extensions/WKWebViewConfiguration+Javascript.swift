import WebKit

extension WKWebViewConfiguration {
    func setupForNeeman() -> WKWebViewConfiguration {
        processPool = WebViewController.processPool
        if #available(iOS 9.0, *) {
            applicationNameForUserAgent = Settings.sharedInstance.appName
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
    
    func addAuthenticationForURL(url: NSURL?) {
        guard let url = url else {
            return
        }
        if let cookie = authCookieForURL(url) {
            setCookie(cookie)
        }
    }
    
    func authCookieForURL(url: NSURL) -> NSHTTPCookie? {
        guard let authCookieName = Settings.sharedInstance.authCookieName else {
            return nil
        }
        let cookieStore = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let cookies = cookieStore.cookiesForURL(url)
        if let authCookies = cookies?.filter({$0.name == authCookieName}),
            authCookie = authCookies.first {
                return authCookie
        }
        
        if let authToken = Settings.sharedInstance.authToken {
            let properties: [String: AnyObject] = [
                NSHTTPCookieName:authCookieName,
                NSHTTPCookieValue:authToken,
                NSHTTPCookieDomain:url.host!,
                NSHTTPCookieOriginURL:url.host!,
                NSHTTPCookiePath:"/",
                NSHTTPCookieSecure:true
            ]
            
            if let cookie = NSHTTPCookie(properties: properties) {
                return cookie
            }
        }
        return nil
    }
    
    func setCookie(cookie: NSHTTPCookie) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "eee, dd MMM yyyy HH:mm:ss zzz"
        
        let oneYearInSeconds: NSTimeInterval = 60*60*24*365
        let dateInOneYear = NSDate(timeIntervalSinceNow: oneYearInSeconds)
        let expires = cookie.expiresDate ?? dateInOneYear
        let expiresString = dateFormatter.stringFromDate(expires)
        let content = "document.cookie = '\(cookie.name)=\(cookie.value); expires=\(expiresString); path=\(cookie.path)';"

        let script = WKUserScript(source: content, injectionTime: .AtDocumentStart, forMainFrameOnly: true)
        userContentController.addUserScript(script)
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