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
    func pushNewWebViewControllerWithURL(url: NSURL)
    
    /**
     Decide if we should prevent a request from being loading in a new web view. 
     It will instead be loaded in the current one.
     
     - parameter request: The request that is about to be loaded.
     
     - returns: Whether we should prevent the request from being loading in a new web view.
     */
    func shouldPreventPushOfNewRequest(request: NSURLRequest) -> Bool
    
    /**
     Decide if we should force the request to be loaded in a new web view. 
     
     This is useful if a page is setting document.location within a click handler. 
     Web kit does not realise that this was from a "link" click. In this case we can make sure it is handled like a link.
     
     - parameter request: The request that will be loaded.
     
     - returns: Whether we should force the request to be loaded in a new web view.
     */
    func shouldForcePushOfNewRequest(request: NSURLRequest) -> Bool
    
    /**
     This is called when the web view finished loading but encountered and error.
     
     - parameter webView: The web view.
     - parameter error:   The error encountered.
     */
    func webView(webView: WKWebView, didFinishLoadingWithError error: NSError)
    
    /**
     This is called when the navigation was completed. The web view might have been redirected a number of times,
     but this is not called until the final redirection is complete.
     
     - parameter webView: Then web view.
     - parameter URL:     The URL that was finally loaded.
     */
    func webView(webView: WKWebView, didFinishNavigationWithURL URL: NSURL?)
    
    /**
     This is called when a request is redirected.
     
     - parameter webView: The web view.
     - parameter URL:     The URL that is being redirected to.
     */
    func webView(webView: WKWebView, didReceiveServerRedirectToURL URL: NSURL?)
}

extension NeemanNavigationDelegate {
    /// Does nothing.
    public func pushNewWebViewControllerWithURL(url: NSURL) {}
    /// Returns false.
    public func shouldPreventPushOfNewRequest(request: NSURLRequest) -> Bool { return false }
    /// Returns false.
    public func shouldForcePushOfNewRequest(request: NSURLRequest) -> Bool { return false }
    /// Does nothing.
    public func webView(webView: WKWebView, didFinishLoadingWithError error: NSError) {}
    /// Does nothing.
    public func webView(webView: WKWebView, didFinishNavigationWithURL: NSURL?) {}
    /// Does nothing.
    public func webView(webView: WKWebView, didReceiveServerRedirectToURL: NSURL?) {}
}

/** This class works out when we should load a new URL in the same web view and when we should push a new
 web view onto the navigation stack. It also lets its delegate know when the web view has been redirected
 and has finished loading.
*/
public class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
    /// The url of the first requested page.
    var rootURL: NSURL
    
    /** The delegate that should be notified of when the web view has finished loading or when
    a new web view should be pushed onto the navigation stack.
    */
    weak var delegate: NeemanNavigationDelegate?
    
    /// This contains, for example, the name of the app and optionally the base URL of your app.
    public var settings: Settings
    
    /**
     Returns a new web view delegate initialised from a URL and the delegate to call back.
     
     - parameter rootURL:  The url of the first requested page that the web view opened.
     - parameter delegate: The delegate to call when we should, for example, push a new web view onto the navigation stack.
     - parameter settings: Settings with some information like the root URL and whether we should be logging.
     
     - returns: The new navigation delegate.
     */
    public init(rootURL: NSURL, delegate: NeemanNavigationDelegate?, settings: Settings) {
        self.rootURL = rootURL
        self.delegate = delegate
        self.settings = settings
    }
    
    /**
     Decide if the performed navigation should push a new web view onto the navigation stack or not.
     
     - parameter webView:          The web view in which a navigation was performed.
     - parameter navigationAction: The navigation that was performed.
     - parameter decisionHandler:  This is the object that you give your action policy to.
     */
    public func webView(webView: WKWebView,
        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
        decisionHandler: (WKNavigationActionPolicy) -> Void) {
            
            var actionPolicy: WKNavigationActionPolicy = .Allow
            let shouldPush = shouldPushNewWebViewForRequest(navigationAction.request)

            let isLink = navigationAction.navigationType == .LinkActivated
            let shouldForcePush = delegate?.shouldForcePushOfNewRequest(navigationAction.request) ?? false
            if (isLink && shouldPush) || shouldForcePush {
                delegate?.pushNewWebViewControllerWithURL(navigationAction.request.URL!)
                actionPolicy = .Cancel
            }

            if settings.debug {
                let actionString = (actionPolicy.rawValue == 1) ? "Allowed" : "Canceled"
                print("URL: " + (navigationAction.request.URL?.absoluteString)! + "\t\t\t- " + actionString)
            }
            
            decisionHandler(actionPolicy)
    }

    /**
     This is called when the web view redirects to a new URL. 
     It also calls didReceiveServerRedirectToURL on the delegate.
     
     - parameter webView:    The web view that was redirected.
     - parameter navigation: The navigation object.
     */
    public func webView(webView: WKWebView,
        didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation?) {
        delegate?.webView(webView, didReceiveServerRedirectToURL: webView.URL)
    }
    
    /**
     This is called when the web view finishes loading a URL.
     It also calls didFinishNavigationWithURL on the delegate.
     
     - parameter webView:    The web view that was redirected.
     - parameter navigation: The navigation object.
     */
    public func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation?) {
        delegate?.webView(webView, didFinishNavigationWithURL: webView.URL)
    }
    
    /**
     This is called when the web view finishes loading a URL with an error.
     It also calls didFinishLoadingWithError on the delegate.
     
     - parameter webView:    The web view that was redirected.
     - parameter navigation: The navigation object.
     */
    public func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation?, withError error: NSError) {
        delegate?.webView(webView, didFinishLoadingWithError: error)
    }
    
    // MARK: Should Push
    /**
    This is where we decide whether or not a new URL causes us to push a new web view onto the navigation stack.
    
    - parameter request: The request that we are about to navigate to.
    
    - returns: Whether or not to push a new web view onto the navigation stack.
    */
    public func shouldPushNewWebViewForRequest(request: NSURLRequest) -> Bool {
        guard let url = request.URL else {
            return false
        }
        if let d = delegate where d.shouldPreventPushOfNewRequest(request) {
            return false
        }

        let isInitialRequest = url.absoluteString == rootURL.absoluteString
        let isSameHost = request.URL?.host == rootURL.host
        let isSamePath = request.URL?.path == rootURL.path
        let isFragmentOfThisPage = request.URL?.fragment != nil && isSameHost && isSamePath
        
        return !isInitialRequest && !isFragmentOfThisPage
    }
}
