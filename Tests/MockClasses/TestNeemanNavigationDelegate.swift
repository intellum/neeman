import XCTest
import WebKit
import Neeman

/**
 This is used to provide a default implimentation so that the unit tests are less verbose.
 */
open class TestNeemanNavigationDelegate: NSObject, NeemanNavigationDelegate {
    var expectation: XCTestExpectation?
    
    override init() {
        super.init()
    }

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    open func webView(_ webView: WKWebView, didReceiveServerRedirectToURL: URL?) {}
    open func webView(_ webView: WKWebView, didFinishNavigationWithURL: URL?) {}
    open func webView(_ webView: WKWebView, didFinishLoadingWithError error: NSError) {}
    open func shouldPreventNavigationAction(_ navigationAction: WKNavigationAction) -> Bool {
        return false
    }
    open func shouldForcePushOfNavigationAction(_ navigationAction: WKNavigationAction) -> Bool {
        return false
    }
    open func shouldPreventPushOfNavigationAction(_ navigationAction: WKNavigationAction) -> Bool {
        return false
    }
    open func pushNewWebViewControllerWithURL(_ url: URL) {}
}
