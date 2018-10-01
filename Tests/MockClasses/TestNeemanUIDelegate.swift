import XCTest
import WebKit
import Neeman

// swiftlint:disable missing_docs

/**
 This is used to provide a default implimentation so that the unit tests are less verbose.
 */
open class TestNeemanUIDelegate: NSObject, NeemanUIDelegate {
    
    var expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    public func pushNewWebViewControllerWithURL(_ url: URL) {}
    public func popupWebView(_ newWebView: WKWebView, withURL url: URL) {}
    public func presentAlertController(_ alert: UIAlertController) {}
    public func closeWebView(_ webView: WKWebView) {}
}
