import UIKit
import WebKit

public protocol NeemanUIDelegate: NSObjectProtocol {
    func pushNewWebViewControllerWithURL(url: NSURL)
    func popupWebView(newWebView: WKWebView, withURL url: NSURL)
    func closeWebView(webView: WKWebView)
    func refusedUIFromRequest(request: NSURLRequest)
}

extension NeemanUIDelegate {
    public func pushNewWebViewControllerWithURL(url: NSURL) {}
    public func popupWebView(newWebView: WKWebView, withURL url: NSURL) {}
    public func closeWebView(webView: WKWebView) {}
    public func refusedUIFromRequest(request: NSURLRequest) {}
}

public class WebViewUIDelegate: NSObject, WKUIDelegate {
    
    weak var delegate: NeemanUIDelegate?
    var settings: Settings
    
    init(settings: Settings) {
        self.settings = settings
        super.init()
    }

    public func webView(webView: WKWebView,
        createWebViewWithConfiguration configuration: WKWebViewConfiguration,
        forNavigationAction navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures) -> WKWebView? {
            
            let newWebView = WKWebView(frame: webView.frame, configuration: configuration)
            configuration.processPool = ProcessPool.sharedInstance
            if #available(iOS 9.0, *) {
                configuration.applicationNameForUserAgent = settings.appName
            }

            if let url = navigationAction.request.URL {
                delegate?.popupWebView(newWebView, withURL: url)
            }
            return newWebView
    }
    
    public func webViewDidClose(webView: WKWebView) {
        delegate?.closeWebView(webView)
    }
    
    public func webView(webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: () -> Void) {
            
            if !shouldAcceptUIFromFrame(frame) {
                refusedUIFromRequest(frame.request)
                return
            }

            let alert = UIAlertController(title: nil,
                message: message,
                preferredStyle: .Alert)
            let title = NSLocalizedString("OK", comment: "OK Button")
            let ok = UIAlertAction(title: title, style: .Default) { (action: UIAlertAction) -> Void in
                completionHandler()
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            alert.addAction(ok)
            presentAlertController(alert)
    }
    
    public func webView(webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: (Bool) -> Void) {
            
            if !shouldAcceptUIFromFrame(frame) {
                refusedUIFromRequest(frame.request)
                return
            }
            
            let alert = UIAlertController(title: nil,
                message: message,
                preferredStyle: .Alert)
            let title = NSLocalizedString("OK", comment: "OK Button")
            let ok = UIAlertAction(title: title, style: .Default) { (action: UIAlertAction) -> Void in
                completionHandler(true)
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"),
                style: .Default) { (action: UIAlertAction) -> Void in
                    
                completionHandler(false)
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            alert.addAction(ok)
            alert.addAction(cancel)
            presentAlertController(alert)
    }
    
    public func webView(webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: (String?) -> Void) {
            
            if !shouldAcceptUIFromFrame(frame) {
                refusedUIFromRequest(frame.request)
                return
            }

            let alert = UIAlertController(title: nil,
                message: prompt,
                preferredStyle: .Alert)
            let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button"), style: .Default) { (action: UIAlertAction) -> Void in
                if let text = alert.textFields?.first?.text {
                    completionHandler(text)
                }
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"),
                style: .Default) { (action: UIAlertAction) -> Void in
                    
                completionHandler(nil)
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            alert.addAction(ok)
            alert.addAction(cancel)
            
            alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
                textField.text = defaultText
            }
            presentAlertController(alert)
    }
    
    public func presentAlertController(alert: UIAlertController) {
        guard let rootViewController = UIApplication.sharedApplication().delegate?.window??.rootViewController else {
            return
        }
        
        rootViewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    public func refusedUIFromRequest(request: NSURLRequest) {
        print("Refused UI Request from \(request.URL?.host)")
    }

    func shouldAcceptUIFromFrame(frame: WKFrameInfo) -> Bool {
        guard let requestHost = frame.request.URL?.host else {
            return false
        }

        if let host = NSURL(string: settings.baseURL)?.host {
            if requestHost == host {
                return true
            }
        }
        return false
    }
}
