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
     Decide if we should prevent a navigation action from being loading in a new web view. 
     It will instead be loaded in the current one.
     
     - parameter navigationAction: The navigation action that will be loaded.
     
     - returns: Whether we should prevent the request from being loading in a new web view.
     */
    func shouldPreventPushOfNavigationAction(navigationAction: WKNavigationAction) -> Bool
    
    /**
     Decide if we should force the navigation action to be loaded in a new web view.
     
     This is useful if a page is setting document.location within a click handler. 
     Web kit does not realise that this was from a "link" click. In this case we can make sure it is handled like a link.
     
     - parameter navigationAction: The navigation action that will be loaded.
     
     - returns: Whether we should force the request to be loaded in a new web view.
     */
    func shouldForcePushOfNavigationAction(navigationAction: WKNavigationAction) -> Bool
    
    /**
     Decide if we should prevent the navigation action from being loaded.
     
     This is useful if, for example, you would like to switch to another tab that is displaying this request.
     
     - parameter navigationAction: The navigation action that will be loaded.
     
     - returns: Whether we should prevent the request from being loaded.
     */
    func shouldPreventNavigationAction(navigationAction: WKNavigationAction) -> Bool
    
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
    /**
     Does nothing.
     - parameter url: The url that is being pushed onto the navigation stack.
     */
    public func pushNewWebViewControllerWithURL(url: NSURL) {}
    
    /**
     Does nothing.
     - parameter request: The request that is being considered for pushing onto the navigation stack.
     - returns: Whether the request should be pushed onto the navigation stack or loaded in the current web view.
     */
    public func shouldPreventPushOfNavigationAction(navigationAction: WKNavigationAction) -> Bool { return false }
    
    /**
     Does nothing.
     - parameter request: The request that is being considered for forced pushing onto the navigation stack.
     - returns: Whether we should force the request to be pushed onto the navigation stack.
     */
    public func shouldForcePushOfNavigationAction(navigationAction: WKNavigationAction) -> Bool { return false }
    
    /**
     Does nothing.
     - parameter webView: The webView that currently being displayed.
     - parameter error: The error that occured whilst loading the page.
     */
    public func webView(webView: WKWebView, didFinishLoadingWithError error: NSError) {}
    
    /**
     Does nothing.
     - parameter webView: The webView that currently being displayed.
     - parameter url: The url that was navigated to.
     */
    public func webView(webView: WKWebView, didFinishNavigationWithURL url: NSURL?) {}
    
    /**
     Does nothing.
     - parameter webView: The webView that currently being displayed.
     - parameter url: The url that the server redirected to.
     */
    public func webView(webView: WKWebView, didReceiveServerRedirectToURL url: NSURL?) {}
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
    public var settings: NeemanSettings

    /**
     Create a new web view delegate initialised from a URL and the delegate to call back.
     
     - parameter rootURL:  The url of the first requested page that the web view opened.
     - parameter delegate: The delegate to call when we should, for example, push a new web view onto the navigation stack.
     - parameter settings: Settings with some information like the root URL and whether we should be logging.
     */
    public init(rootURL: NSURL, delegate: NeemanNavigationDelegate?, settings: NeemanSettings) {
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
            let shouldPrevent = delegate?.shouldPreventNavigationAction(navigationAction) ?? false
            if shouldPrevent {
                actionPolicy = .Cancel
            } else {
                let isLink = navigationAction.navigationType == .LinkActivated
                let isOther = navigationAction.navigationType == .Other

                let shouldPush = shouldPushForRequestFromWebView(webView, navigationAction: navigationAction) && isLink
                let shouldForcePush = delegate?.shouldForcePushOfNavigationAction(navigationAction) ?? false
                
                if !isOther && (shouldPush || shouldForcePush) {
                    delegate?.pushNewWebViewControllerWithURL(navigationAction.request.URL!)
                    actionPolicy = .Cancel
                }
            }


            if settings.debug {
                let actionString = (actionPolicy.rawValue == 1) ? "Allowed" : "Canceled"
                let urlString = navigationAction.request.URL?.absoluteString ?? ""
                log("URL: \(urlString)\t\t\t- \(actionString)")
            }
            
            decisionHandler(actionPolicy)
    }
    
    /**
     Log a message to the console. This can be overridded to use another logging mechanism. 
     By default we are just using print. We are only calling this if debug=true is set in the Settings.plist.
     
     - parameter message: The message that shoudl be logged.
    */
    public func log(message: String) {
        print(message)
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
     - parameter error:      The error that occured during navigation.
     */
    public func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation?, withError error: NSError) {
        delegate?.webView(webView, didFinishLoadingWithError: error)
    }
    
    // MARK: Should Push
    /**
    This is where we decide whether or not a new URL causes us to push a new web view onto the navigation stack.
    
    - parameter webView: The web view that is navigating.
    - parameter request: The request that we are about to navigate to.
    
    - returns: Whether or not to push a new web view onto the navigation stack.
    */
    public func shouldPushForRequestFromWebView(webView: WKWebView, navigationAction: WKNavigationAction) -> Bool {
        if let d = delegate where d.shouldPreventPushOfNavigationAction(navigationAction) {
            return false
        }
        guard let url = navigationAction.request.URL else {
            return false
        }

        let request = navigationAction.request
        let isInitialRequest = url.absoluteString == rootURL.absoluteString
        let isSameHost = request.URL?.host == rootURL.host
        let isSamePathAsWebView = request.URL?.path == webView.URL?.path
        let isSamePath = request.URL?.path == rootURL.path || isSamePathAsWebView
        let isFragmentOfThisPage = request.URL?.fragment != nil && isSameHost && isSamePath
        
        return !isInitialRequest && !isFragmentOfThisPage
    }
}
