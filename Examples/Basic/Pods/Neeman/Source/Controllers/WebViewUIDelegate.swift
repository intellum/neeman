import UIKit
import WebKit

/**
 *  This is used to allow a controller to implement code to handle window.open() alert(), confirm() and prompt()
 */
public protocol NeemanUIDelegate: NSObjectProtocol {
    /**
     This is called when a web view should be pushed onto the navigation stack.
     
     - parameter url: The URL to load in the new web view.
     */
    func pushNewWebViewControllerWithURL(url: NSURL)
    /**
     Open a new window. This is where you implement something like a new tab in a browser.
     
     - parameter newWebView: The new web view that should become your tab.
     - parameter url:        The URL to display in the new tab.
     */
    func popupWebView(newWebView: WKWebView, withURL url: NSURL)
    
    /**
     Close the tab.
    
     - parameter webView: The web view that should be closed.
     */
    func closeWebView(webView: WKWebView)
    
    /**
     This is called when a script from a 3rd party domain calles alert(), confirm() or prompt().
     
     - parameter request: The request representing the url of the calling script.
     */
    func refusedUIFromRequest(request: NSURLRequest)
}

extension NeemanUIDelegate {
    /// Does nothing.
    public func pushNewWebViewControllerWithURL(url: NSURL) {}
    /// Does nothing.
    public func popupWebView(newWebView: WKWebView, withURL url: NSURL) {}
    /// Does nothing.
    public func closeWebView(webView: WKWebView) {}
    /// Does nothing.
    public func refusedUIFromRequest(request: NSURLRequest) {}
}

/** This class implements WKUIDelegate. It implements alert(), confirm() and prompt() using an alert controller.
 
 When window.open() is called it creates a new web view and passes this to the NeemanUIDelegate.
*/
public class WebViewUIDelegate: NSObject, WKUIDelegate {
    
    weak var delegate: NeemanUIDelegate?
    var settings: Settings
    
    init(settings: Settings) {
        self.settings = settings
        super.init()
    }

    /**
     This is called when window.open() is called. You can use this to implement something like tabs in a browser.
     
     - parameter webView:          The parent web view.
     - parameter configuration:    The configuration to use when creating the new web view.
     - parameter navigationAction: The navigation action causing the new web view to be created.
     - parameter windowFeatures:   Window features requested by the webpage.
     
     - returns: A new web view or nil.
     */
    public func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration,
        forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            
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
    
    /**
     Notifies your app that the DOM window object's close() method completed successfully.
     
     Your app should remove the web view from the view hierarchy and update
     the UI as needed, such as by closing the containing browser tab or window.
     
     - parameter webView: The web view that is being closed.
     */
    public func webViewDidClose(webView: WKWebView) {
        delegate?.closeWebView(webView)
    }
    
    /**
     Displays a JavaScript alert() panel.
     
     - parameter webView:           The web view invoking the delegate method.
     - parameter message:           The message to display.
     - parameter frame:             Information about the frame whose JavaScript initiated this call.
     - parameter completionHandler: The completion handler to call after the alert panel has been dismissed.
     */
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
    
    /**
     Displays a JavaScript confirm() panel.
     
     - parameter webView:           The web view invoking the delegate method.
     - parameter message:           The message to display.
     - parameter frame:             Information about the frame whose JavaScript initiated this call.
     - parameter completionHandler: The completion handler to call after the confirm
     panel has been dismissed. Pass YES if the user chose OK, NO if the user chose Cancel.
     */
    public func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo, completionHandler: (Bool) -> Void) {
            
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
    
    /**
     Displays a JavaScript text input panel resulting from the prompt() method.
     
     - parameter webView:           The web view invoking the delegate method.
     - parameter prompt:            The prompt to display.
     - parameter defaultText:       The initial text to display in the text entry field.
     - parameter frame:             Information about the frame whose JavaScript initiated this call.
     - parameter completionHandler: The completion handler to call after the text
     input panel has been dismissed. Pass the entered text if the user chose
     OK, otherwise nil.
     */
    public func webView(webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?,
        initiatedByFrame frame: WKFrameInfo, completionHandler: (String?) -> Void) {
            
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
    
    /**
     Presents the alert controller in the windows root view controller.
     
     - parameter alert: The alert controller to present.
     */
    internal func presentAlertController(alert: UIAlertController) {
        guard let rootViewController = UIApplication.sharedApplication().delegate?.window??.rootViewController else {
            return
        }
        
        rootViewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    /**
     This is called when javascript from a different domain tries to call either alert(), confirm() or prompt(). 
     You can override this to log the offending domains.
     
     - parameter request: The request from the offending frame.
     */
    internal func refusedUIFromRequest(request: NSURLRequest) {
        print("Refused UI Request from \(request.URL?.host)")
    }

    /**
     This returns whether or not we should allow the delegate methods to be called for the supplied frame.
     
     - parameter frame: The frame from which the delegate method is being called.
     
     - returns: Return false if we should ignore the delegate call.
     */
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
