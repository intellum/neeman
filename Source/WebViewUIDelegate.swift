import WebKit

/**
 *  This is used to allow a controller to implement code to handle window.open() alert(), confirm() and prompt()
 */
public protocol NeemanUIDelegate: NSObjectProtocol {
    /**
     Open a new window. This is where you implement something like a new tab in a browser.
     
     - parameter newWebView: The new web view that should become your tab.
     - parameter url:        The URL to display in the new tab.
     */
    func popupWebView(_ newWebView: WKWebView, withURL url: URL)
    
    /**
     Close the tab.
    
     - parameter webView: The web view that should be closed.
     */
    func closeWebView(_ webView: WKWebView)
    
    /**
     This is called when a script from a 3rd party domain calles alert(), confirm() or prompt().
     
     - parameter request: The request representing the url of the calling script.
     */
    func refusedUIFromRequest(_ request: URLRequest)
    
    /**
     This is called when alert(), confirm() or prompt() is called.
     
     - parameter request: The request representing the url of the calling script.
     */
    func presentAlertController(_ alert: UIAlertController)
}

extension NeemanUIDelegate {
    /** 
     Does nothing.
     
     - parameter url: The url being pushed onto the navigation stack.
     */
    public func pushNewWebViewControllerWithURL(_ url: URL) {}

    /**
     Does nothing.
     
     - parameter newWebView: The url being pushed onto the navigation stack.
     - parameter url: The url being pushed onto the navigation stack.
     */
    public func popupWebView(_ newWebView: WKWebView, withURL url: URL) {}
    
    /**
     Does nothing.
     
     - parameter webView: The url being pushed onto the navigation stack.
     */
    public func closeWebView(_ webView: WKWebView) {}
    
    /**
     Does nothing.
     
     - parameter request: The request from which the UI action was refused.
     */
    public func refusedUIFromRequest(_ request: URLRequest) {}
}

/** This class implements WKUIDelegate. It implements alert(), confirm() and prompt() using an alert controller.
 
 When window.open() is called it creates a new web view and passes this to the NeemanUIDelegate.
*/
open class WebViewUIDelegate: NSObject, WKUIDelegate {
    
    weak var delegate: NeemanUIDelegate?
    let baseURL: URL
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    /**
     This is called when window.open() is called. You can use this to implement something like tabs in a browser.
     
     - parameter webView:          The parent web view.
     - parameter configuration:    The configuration to use when creating the new web view.
     - parameter navigationAction: The navigation action causing the new web view to be created.
     - parameter windowFeatures:   Window features requested by the webpage.
     
     - returns: A new web view or nil.
     */
    open func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            
            let newWebView = WKWebView(frame: webView.frame, configuration: configuration)

            if let url = navigationAction.request.url {
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
    open func webViewDidClose(_ webView: WKWebView) {
        delegate?.closeWebView(webView)
    }
    
    /**
     Displays a JavaScript alert() panel.
     
     - parameter webView:           The web view invoking the delegate method.
     - parameter message:           The message to display.
     - parameter frame:             Information about the frame whose JavaScript initiated this call.
     - parameter completionHandler: The completion handler to call after the alert panel has been dismissed.
     */
    open func webView(_ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void) {
            
            if !shouldAcceptUIFromFrame(frame) {
                refusedUIFromRequest(frame.request)
                completionHandler()
                return
            }

            let alert = UIAlertController(title: nil,
                message: message,
                preferredStyle: .alert)
            let title = NeemanLocalizedString("Button-OK", comment: "OK Button")
            let ok = UIAlertAction(title: title, style: .default) { (action: UIAlertAction) -> Void in
                completionHandler()
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            delegate?.presentAlertController(alert)
    }
    
    /**
     Displays a JavaScript confirm() panel.
     
     - parameter webView:           The web view invoking the delegate method.
     - parameter message:           The message to display.
     - parameter frame:             Information about the frame whose JavaScript initiated this call.
     - parameter completionHandler: The completion handler to call after the confirm
     panel has been dismissed. Pass YES if the user chose OK, NO if the user chose Cancel.
     */
    open func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            
            if !shouldAcceptUIFromFrame(frame) {
                refusedUIFromRequest(frame.request)
                completionHandler(false)
                return
            }
            
            let alert = UIAlertController(title: nil,
                message: message,
                preferredStyle: .alert)
            let title = NeemanLocalizedString("Button-OK", comment: "OK Button")
            let ok = UIAlertAction(title: title, style: .default) { (action: UIAlertAction) -> Void in
                completionHandler(true)
                alert.dismiss(animated: true, completion: nil)
            }
            let cancel = UIAlertAction(title: NeemanLocalizedString("Button-Cancel", comment: "Cancel Button"),
                style: .default) { (action: UIAlertAction) -> Void in
                    
                completionHandler(false)
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            alert.addAction(cancel)
            delegate?.presentAlertController(alert)
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
    open func webView(_ webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?,
        initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
            
            if !shouldAcceptUIFromFrame(frame) {
                refusedUIFromRequest(frame.request)
                completionHandler(nil)
                return
            }

            let alert = UIAlertController(title: nil,
                message: prompt,
                preferredStyle: .alert)
            let ok = UIAlertAction(title: NeemanLocalizedString("Button-OK", comment: "OK Button"), style: .default) { (action: UIAlertAction) -> Void in
                if let text = alert.textFields?.first?.text {
                    completionHandler(text)
                }
                alert.dismiss(animated: true, completion: nil)
            }
            let cancel = UIAlertAction(title: NeemanLocalizedString("Button-Cancel", comment: "Cancel Button"),
                style: .default) { (action: UIAlertAction) -> Void in
                    
                completionHandler(nil)
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            alert.addAction(cancel)
            
            alert.addTextField { (textField: UITextField) -> Void in
                textField.text = defaultText
            }
            delegate?.presentAlertController(alert)
    }
        
    /**
     This is called when javascript from a different domain tries to call either alert(), confirm() or prompt(). 
     You can override this to log the offending domains.
     
     - parameter request: The request from the offending frame.
     */
    internal func refusedUIFromRequest(_ request: URLRequest) {
        print("Refused UI Request from \(request.url?.host ?? "N/A")")
    }

    /**
     This returns whether or not we should allow the delegate methods to be called for the supplied frame.
     
     - parameter frame: The frame from which the delegate method is being called.
     
     - returns: Return false if we should ignore the delegate call.
     */
    func shouldAcceptUIFromFrame(_ frame: WKFrameInfo) -> Bool {
        guard let requestHost = frame.request.url?.host else {
            return false
        }

        if let host = baseURL.host {
            if requestHost.contains(host) {
                return true
            }
        }
        return false
    }
    
    func _webView(_ webView: WKWebView,
                  printFrame frame: Any) {

        let printController = UIPrintInteractionController.shared
        
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfo.OutputType.general
        printInfo.jobName = (webView.url?.absoluteString)!
        printInfo.duplex = UIPrintInfo.Duplex.none
        printInfo.orientation = UIPrintInfo.Orientation.portrait
        
        printController.printPageRenderer = nil
        printController.printingItems = nil
        printController.printingItem = webView.url!
        
        printController.printInfo = printInfo
        printController.showsNumberOfCopies = true
        
        printController.present(animated: true, completionHandler: nil)
    }
}
