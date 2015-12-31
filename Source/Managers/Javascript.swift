import UIKit
import WebKit

class Javascript {
    func setCookie(cookie: NSHTTPCookie, config: WKWebViewConfiguration) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "eee, dd MMM yyyy HH:mm:ss zzz"

        let oneYearInSeconds: NSTimeInterval = 60*60*24*365
        let dateInOneYear = NSDate(timeIntervalSinceNow: oneYearInSeconds)
        let expires = cookie.expiresDate ?? dateInOneYear
        let expiresString = dateFormatter.stringFromDate(expires)
        let content = "document.cookie = '\(cookie.name)=\(cookie.value); expires=\(expiresString); path=\(cookie.path)';"

        let script = WKUserScript(source: content, injectionTime: .AtDocumentStart, forMainFrameOnly: true)
        config.userContentController.addUserScript(script)
    }
    
    func addScript(scriptName: String, config: WKWebViewConfiguration, injectionTime: WKUserScriptInjectionTime) {
        let content = stringFromContentInFileName(scriptName)
        let script = WKUserScript(source: content, injectionTime: injectionTime, forMainFrameOnly: true)
        config.userContentController.addUserScript(script)
    }
    
    func addCSSScript(config: WKWebViewConfiguration) {
        var javascript = stringFromContentInFileName("InjectCSS.js")
        var css = stringFromContentInFileName("WebView.css")
        css = css.stringByReplacingOccurrencesOfString("\n", withString: "\\\n")
        javascript = javascript.stringByReplacingOccurrencesOfString("${CSS}", withString: css)
        
        let script = WKUserScript(source: javascript, injectionTime: .AtDocumentStart, forMainFrameOnly: true)
        config.userContentController.addUserScript(script)
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
