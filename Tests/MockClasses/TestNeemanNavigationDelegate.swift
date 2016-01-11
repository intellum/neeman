import XCTest
import WebKit
import Neeman

public class TestNeemanNavigationDelegate: NSObject, NeemanNavigationDelegate {
    var expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    public func webView(webView: WKWebView, didReceiveServerRedirectToURL: NSURL?) {}
    public func webView(webView: WKWebView, didFinishNavigationWithURL: NSURL?) {}
    public func webView(webView: WKWebView, didFinishLoadingWithError error: NSError) {}
    public func shouldForcePushOfNewRequest(request: NSURLRequest) -> Bool {
        return false
    }
    public func pushNewWebViewControllerWithURL(url: NSURL) {}
}
