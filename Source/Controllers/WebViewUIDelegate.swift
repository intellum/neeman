import UIKit
import WebKit

protocol NeemanUIDelegate: NSObjectProtocol {
    func pushNewWebViewControllerWithURL(url: NSURL)
    func openURL(url:NSURL, inNewWebView webView: WKWebView)
    func closeWebView(webView: WKWebView)
}

public class WebViewUIDelegate: NSObject, WKUIDelegate {
    
    weak var delegate: NeemanUIDelegate?

    public func webView(webView: WKWebView,
        createWebViewWithConfiguration configuration: WKWebViewConfiguration,
        forNavigationAction navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures) -> WKWebView? {
            
            let newWebView = WKWebView(frame: webView.frame, configuration: configuration)
            configuration.processPool = WebViewController.processPool
            if #available(iOS 9.0, *) {
                configuration.applicationNameForUserAgent = Settings.sharedInstance.appName
            }

            if let url = navigationAction.request.URL {
                delegate?.openURL(url, inNewWebView: newWebView)
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
            
            guard let rootViewController = UIApplication.sharedApplication().delegate?.window??.rootViewController else {
                return
            }
            
            let alert = UIAlertController(title: nil,
                message: message,
                preferredStyle: .Alert)
            let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button"), style: .Default) { (action: UIAlertAction) -> Void in
                completionHandler()
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            alert.addAction(ok)
            rootViewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    public func webView(webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: (Bool) -> Void) {
            
            guard let rootViewController = UIApplication.sharedApplication().delegate?.window??.rootViewController else {
                return
            }
            
            let alert = UIAlertController(title: nil,
                message: message,
                preferredStyle: .Alert)
            let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button"), style: .Default) { (action: UIAlertAction) -> Void in
                completionHandler(true)
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"), style: .Default) { (action: UIAlertAction) -> Void in
                completionHandler(false)
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            alert.addAction(ok)
            alert.addAction(cancel)
            rootViewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    public func webView(webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: (String?) -> Void) {

            guard let rootViewController = UIApplication.sharedApplication().delegate?.window??.rootViewController else {
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
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"), style: .Default) { (action: UIAlertAction) -> Void in
                completionHandler(nil)
                alert.dismissViewControllerAnimated(true, completion: nil)
            }
            alert.addAction(ok)
            alert.addAction(cancel)
            
            alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
                textField.text = defaultText
            }
            rootViewController.presentViewController(alert, animated: true, completion: nil)
            
    }

}