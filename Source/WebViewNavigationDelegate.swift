import WebKit

/**
 A neeman navigation delegate can influence whether a request is pushed onto the navigation stack or not.
 It also receives notice of when a web view finished loading or was redirected.
 */
public protocol NeemanNavigationDelegate: NSObjectProtocol {
    /**
     This is called when a new web view should be pushed onto the navigation stack.
     
     - parameter url: The URL to load in the new web view.
     */
    func pushNewWebViewControllerWithURL(_ url: URL)
    
    /**
     Decide if we should prevent a navigation action from being loading in a new web view. 
     It will instead be loaded in the current one.
     
     - parameter navigationAction: The navigation action that will be loaded.
     
     - returns: Whether we should prevent the request from being loading in a new web view.
     */
    func shouldPreventPushOfNavigationAction(_ navigationAction: WKNavigationAction) -> Bool
    
    /**
     Decide if we should force the navigation action to be loaded in a new web view.
     
     This is useful if a page is setting document.location within a click handler. 
     Web kit does not realise that this was from a "link" click. In this case we can make sure it is handled like a link.
     
     - parameter navigationAction: The navigation action that will be loaded.
     
     - returns: Whether we should force the request to be loaded in a new web view.
     */
    func shouldForcePushOfNavigationAction(_ navigationAction: WKNavigationAction) -> Bool
    
    /**
     Decide if we should prevent the navigation action from being loaded.
     
     This is useful if, for example, you would like to switch to another tab that is displaying this request.
     
     - parameter navigationAction: The navigation action that will be loaded.
     
     - returns: Whether we should prevent the request from being loaded.
     */
    func shouldPreventNavigationAction(_ navigationAction: WKNavigationAction) -> Bool
    
    /**
     This is called when the web view finished loading but encountered and error.
     
     - parameter webView: The web view.
     - parameter error:   The error encountered.
     */
    func webView(_ webView: WKWebView, didFinishLoadingWithError error: NSError)
    
    /**
     This is called when the navigation was completed. The web view might have been redirected a number of times,
     but this is not called until the final redirection is complete.
     
     - parameter webView: Then web view.
     - parameter URL:     The URL that was finally loaded.
     */
    func webView(_ webView: WKWebView, didFinishNavigationWithURL URL: URL?)
    
    /**
     This is called when a request is redirected.
     
     - parameter webView: The web view.
     - parameter URL:     The URL that is being redirected to.
     */
    func webView(_ webView: WKWebView, didReceiveServerRedirectToURL URL: URL?)
}

extension NeemanNavigationDelegate {
    /**
     Does nothing.
     - parameter url: The url that is being pushed onto the navigation stack.
     */
    public func pushNewWebViewControllerWithURL(_ url: URL) {}
    
    /**
     Does nothing.
     - parameter navigationAction: The navigation action that is being considered for pushing onto the navigation stack.
     - returns: Whether the navigation action should be pushed onto the navigation stack or loaded in the current web view.
     */
    public func shouldPreventPushOfNavigationAction(_ navigationAction: WKNavigationAction) -> Bool { return false }
    
    /**
     Does nothing.
     - parameter navigationAction: The navigation action that is being considered for forced pushing onto the navigation stack.
     - returns: Whether we should force the navigation action to be pushed onto the navigation stack.
     */
    public func shouldForcePushOfNavigationAction(_ navigationAction: WKNavigationAction) -> Bool { return false }
    
    /**
     Does nothing.
     - parameter webView: The webView that currently being displayed.
     - parameter error: The error that occured whilst loading the page.
     */
    public func webView(_ webView: WKWebView, didFinishLoadingWithError error: NSError) {}
    
    /**
     Does nothing.
     - parameter webView: The webView that currently being displayed.
     - parameter url: The url that was navigated to.
     */
    public func webView(_ webView: WKWebView, didFinishNavigationWithURL url: URL?) {}
    
    /**
     Does nothing.
     - parameter webView: The webView that currently being displayed.
     - parameter url: The url that the server redirected to.
     */
    public func webView(_ webView: WKWebView, didReceiveServerRedirectToURL url: URL?) {}
}

/** This class works out when we should load a new URL in the same web view and when we should push a new
 web view onto the navigation stack. It also lets its delegate know when the web view has been redirected
 and has finished loading.
*/
open class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
    /// The url of the first requested page.
    var rootURL: URL
    
    /** The delegate that should be notified of when the web view has finished loading or when
    a new web view should be pushed onto the navigation stack.
    */
    open weak var delegate: NeemanNavigationDelegate?
    
    /**
     Create a new web view delegate initialised from a URL and the delegate to call back.
     
     - parameter rootURL:  The url of the first requested page that the web view opened.
     - parameter delegate: The delegate to call when we should, for example, push a new web view onto the navigation stack.
     */
    public init(rootURL: URL, delegate: NeemanNavigationDelegate?) {
        self.rootURL = rootURL
        self.delegate = delegate
    }
    
    /**
     Decide if the performed navigation should push a new web view onto the navigation stack or not.
     
     - parameter webView:          The web view in which a navigation was performed.
     - parameter navigationAction: The navigation that was performed.
     - parameter decisionHandler:  This is the object that you give your action policy to.
     */
    open func webView(_ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            var actionPolicy: WKNavigationActionPolicy = .allow
            let shouldPrevent = delegate?.shouldPreventNavigationAction(navigationAction) ?? false
            if shouldPrevent {
                actionPolicy = .cancel
            } else {
                let isLink = navigationAction.navigationType == .linkActivated
                let isOther = navigationAction.navigationType == .other

                let shouldPush = shouldPushForRequestFromWebView(webView, navigationAction: navigationAction) && isLink
                let shouldForcePush = delegate?.shouldForcePushOfNavigationAction(navigationAction) ?? false
                
                if !isOther && (shouldPush || shouldForcePush) {
                    delegate?.pushNewWebViewControllerWithURL(navigationAction.request.url!)
                    actionPolicy = .cancel
                }
            }

            let actionString = (actionPolicy.rawValue == 1) ? "Allowed" : "Canceled"
            let urlString = navigationAction.request.url?.absoluteString ?? ""
            log("URL: \(urlString)        -       \(actionString)")
            
            decisionHandler(actionPolicy)
    }
    
    /**
     Log a message to the console using debugPrint. This can be overridded to use another logging mechanism.
     
     - parameter message: The message that shoudl be logged.
    */
    open func log(_ message: String) {
        debugPrint(message)
    }

    /**
     This is called when the web view redirects to a new URL. 
     It also calls didReceiveServerRedirectToURL on the delegate.
     
     - parameter webView:    The web view that was redirected.
     - parameter navigation: The navigation object.
     */
    open func webView(_ webView: WKWebView,
        didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        delegate?.webView(webView, didReceiveServerRedirectToURL: webView.url)
    }
    
    /**
     This is called when the web view finishes loading a URL.
     It also calls didFinishNavigationWithURL on the delegate.
     
     - parameter webView:    The web view that was redirected.
     - parameter navigation: The navigation object.
     */

    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.webView(webView, didFinishNavigationWithURL: webView.url)
    }
    
    /**
     This is called when the web view finishes loading a URL with an error.
     It also calls didFinishLoadingWithError on the delegate.
     
     - parameter webView:    The web view that was redirected.
     - parameter navigation: The navigation object.
     - parameter error:      The error that occured during navigation.
     */
    open func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation?, withError error: Error) {
        delegate?.webView(webView, didFinishLoadingWithError: error as NSError)
    }
    
    // MARK: Should Push
    /**
    This is where we decide whether or not a new URL causes us to push a new web view onto the navigation stack.
    
    - parameter webView: The web view that is navigating.
    - parameter navigationAction: The navigation action that we are about to navigate to.
    
    - returns: Whether or not to push a new web view onto the navigation stack.
    */
    open func shouldPushForRequestFromWebView(_ webView: WKWebView, navigationAction: WKNavigationAction) -> Bool {
        if let d = delegate, d.shouldPreventPushOfNavigationAction(navigationAction) {
            return false
        }
        guard let url = navigationAction.request.url else {
            return false
        }

        let request = navigationAction.request
        let isInitialRequest = url.absoluteString == rootURL.absoluteString
        let isSameHost = request.url?.host == rootURL.host
        let isSamePathAsWebView = request.url?.path == webView.url?.path
        let isSamePath = request.url?.path == rootURL.path || isSamePathAsWebView
        let isFragmentOfThisPage = request.url?.fragment != nil && isSameHost && isSamePath
        
        return !isInitialRequest && !isFragmentOfThisPage
    }
}
