import WebKit

extension WKWebView {
    public func setupForNeeman() -> WKWebView {
        allowsBackForwardNavigationGestures = true
        return self
    }
}