import XCTest
import WebKit
import Neeman

/**
 This is used to provide a default implimentation so that the unit tests are less verbose.
 */
public class TestNeemanUIDelegate: NSObject, NeemanUIDelegate {
    var expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    public func pushNewWebViewControllerWithURL(url: NSURL) {}
    public func popupWebView(newWebView: WKWebView, withURL url: NSURL) {}
    public func closeWebView(webView: WKWebView) {}
}
