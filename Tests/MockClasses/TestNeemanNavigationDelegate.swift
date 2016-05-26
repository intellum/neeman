import XCTest
import WebKit
import Neeman

/**
 This is used to provide a default implimentation so that the unit tests are less verbose.
 */
public class TestNeemanNavigationDelegate: NSObject, NeemanNavigationDelegate {
    var expectation: XCTestExpectation?
    
    override init() {
        super.init()
    }

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    public func webView(webView: WKWebView, didReceiveServerRedirectToURL: NSURL?) {}
    public func webView(webView: WKWebView, didFinishNavigationWithURL: NSURL?) {}
    public func webView(webView: WKWebView, didFinishLoadingWithError error: NSError) {}
    public func shouldPreventNavigationAction(navigationAction: WKNavigationAction) -> Bool {
        return false
    }
    public func shouldForcePushOfNavigationAction(navigationAction: WKNavigationAction) -> Bool {
        return false
    }
    public func shouldPreventPushOfNavigationAction(navigationAction: WKNavigationAction) -> Bool {
        return false
    }
    public func pushNewWebViewControllerWithURL(url: NSURL) {}
}
