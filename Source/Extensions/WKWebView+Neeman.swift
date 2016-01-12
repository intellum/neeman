import WebKit

extension WKWebView {
    /**
     Set some properties of the web view that we what done on all web views.
     
     - returns: The web view being set up. This allows us to chain this method on the end of an init.
     */
    public func setupForNeeman() -> WKWebView {
        allowsBackForwardNavigationGestures = true
        return self
    }
}
