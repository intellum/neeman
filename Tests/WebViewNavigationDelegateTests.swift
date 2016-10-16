import XCTest
import WebKit
@testable import Neeman

class WebViewNavigationDelegateTests: XCTestCase {
    var settings: NeemanSettings {
        get {
            let settings = NeemanSettings(dictionary: ["baseURL": "https://intellum.com"])
            return settings
        }
    }
    
    func testInitialRequest() {
        let url = URL(string: "http://example.com/")
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: nil, settings: settings)
        let request = URLRequest(url: url!)
        let webView = WKWebView()
        let navigationAction = NavigationAction(request: request)
        XCTAssertFalse(navigationDelegate.shouldPushForRequestFromWebView(webView, navigationAction: navigationAction),
                       "The initial request should not be pushed")
    }
    
    
    func testFaultyURLNavigation() {
        let url = URL(string: "http://example.com/")
        let urlFaulty = URL(string: "#hi")
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: nil, settings: settings)
        var request = URLRequest(url: urlFaulty!)
        request.url = nil
        let navigationAction = NavigationAction(request: request)
        
        let webView = WKWebView()
        XCTAssertFalse(navigationDelegate.shouldPushForRequestFromWebView(webView, navigationAction: navigationAction),
                       "Faulty URLs should not be pushed")
    }
    
    func testHashNavigation() {
        let url = URL(string: "http://example.com/#hash")
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: nil, settings: settings)
        let request = URLRequest(url: url!)
        let navigationAction = NavigationAction(request: request)
        
        let webView = WKWebView()
        XCTAssertFalse(navigationDelegate.shouldPushForRequestFromWebView(webView, navigationAction: navigationAction),
                       "Hash navigation should not be pushed")
    }
    
    func testNavigateForward() {
        let url1 = URL(string: "http://example.com/")
        let url2 = URL(string: "http://example.com/user/profile/me")
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url1!, delegate: nil, settings: settings)
        let request = URLRequest(url: url2!)
        let navigationAction = NavigationAction(request: request)
        
        let webView = WKWebView()
        XCTAssertTrue(navigationDelegate.shouldPushForRequestFromWebView(webView, navigationAction: navigationAction),
                      "New URLs should not be pushed")
    }
    
    // MARK: Delegation
    
    func testPreventPush() {
        class NeemanWebViewController: TestNeemanNavigationDelegate {
            override func shouldPreventPushOfNavigationAction(_ navigationAction: WKNavigationAction) -> Bool {
                return true
            }
        }
        
        let url = URL(string: "https://groupdock.com/a/Level")
        let request = URLRequest(url: url!)
        let navigationAction = NavigationAction(request: request)
        let delegate = NeemanWebViewController()
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: delegate, settings: settings)
        let webView = WKWebView()
        XCTAssertFalse(navigationDelegate.shouldPushForRequestFromWebView(webView, navigationAction: navigationAction),
                       "The delegate should prevent the URL being pushed")
    }
    
    func testErrorPassedToDelegate() {
        let expectation = self.expectation(description: "Pass Error to Delegate")
        class NeemanWebViewController: TestNeemanNavigationDelegate {
            override func webView(_ webView: WKWebView, didFinishLoadingWithError error: NSError) {
                XCTAssertNotNil(error, "The delegate should be passed a non nil error")
                expectation?.fulfill()
            }
        }
        
        let url = URL(string: "https://groupdock.com/a/Level")
        let delegate = NeemanWebViewController(expectation: expectation)
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: delegate, settings: settings)
        let error = NSError(domain: "", code: 1, userInfo: nil)
        navigationDelegate.webView(WKWebView(), didFailProvisionalNavigation: nil, withError: error)
        
        waitForExpectations(timeout: 1) { (error) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }
    
    func testDecidePolicyForNavigationAction() {
        let expectation = self.expectation(description: "Call Callback")
        let url = URL(string: "https://groupdock.com/a/Level")
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: nil, settings: settings)
        let request = URLRequest(url: url!)
        let navigationAction = NavigationAction(request: request)
        navigationDelegate.webView(WKWebView(), decidePolicyFor: navigationAction) { (policy: WKNavigationActionPolicy) -> Void in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1) { (error) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }
    
    func testShouldPreventPushOfNewWebView() {
        class MyWKNavigation: NSObject {
        }
        class MyNeemanWebViewController: TestNeemanNavigationDelegate {
            override func shouldPreventPushOfNavigationAction(_ navigationAction: WKNavigationAction) -> Bool {
                return true
            }
        }
        
        let url = URL(string: "https://groupdock.com/a/Level")
        let delegate = MyNeemanWebViewController()
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: delegate, settings: settings)
        let webView = WKWebView()
        let navigationAction = NavigationAction(request: URLRequest(url:url!))

        XCTAssertFalse(navigationDelegate.shouldPushForRequestFromWebView(webView, navigationAction: navigationAction),
                       "The delegate should prevent the URL being pushed")
    }
    
    func testDelegateDefaultImplementations() {
        class MyNeemanWebViewController: TestNeemanNavigationDelegate {
        }
        
        let webView = WKWebView()
        let navigationAction = NavigationAction(request: URLRequest(url: URL(string: "#hi")!))
        let delegate = MyNeemanWebViewController()
        delegate.webView(webView, didFinishNavigationWithURL:nil)
        delegate.webView(webView, didFinishLoadingWithError: NSError(domain: "", code: 1, userInfo: nil))
        delegate.webView(webView, didReceiveServerRedirectToURL: nil)
        delegate.shouldForcePushOfNavigationAction(navigationAction)
        delegate.pushNewWebViewControllerWithURL(URL(string: "#ho")!)
        delegate.shouldPreventPushOfNavigationAction(navigationAction)
    }
    
    func testDelegateMethodsCalled() {
        let expectation = self.expectation(description: "Pass Error to Delegate")
        class NeemanWebViewController: TestNeemanNavigationDelegate {
            override func webView(_ webView: WKWebView, didFinishNavigationWithURL: URL?) {
                expectation?.fulfill()
            }
        }
        
        let url = URL(string: "https://intellum.com/cool/new/link")!
        let delegate = NeemanWebViewController(expectation: expectation)
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url, delegate: delegate, settings: settings)
        
        navigationDelegate.webView(WKWebView(), didFinish: nil)

        waitForExpectations(timeout: 1) { (error) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }
    
    func testDelegateRedirectMethodsCalled() {
        let expectation = self.expectation(description: "Pass Error to Delegate")
        class NeemanWebViewController: TestNeemanNavigationDelegate {
            override func webView(_ webView: WKWebView, didReceiveServerRedirectToURL: URL?) {
                expectation?.fulfill()
            }
        }
        
        let url = URL(string: "https://intellum.com/cool/new/link")!
        let delegate = NeemanWebViewController(expectation: expectation)
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url, delegate: delegate, settings: settings)
        
        navigationDelegate.webView(WKWebView(), didReceiveServerRedirectForProvisionalNavigation: nil)
        
        waitForExpectations(timeout: 1) { (error) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }
    
    func testPushIsCalled() {
        let expectation = self.expectation(description: "Pass Error to Delegate")
        class NeemanWebViewController: TestNeemanNavigationDelegate {
            override func shouldForcePushOfNavigationAction(_ navigationAction: WKNavigationAction) -> Bool {
                return true
            }
            override func pushNewWebViewControllerWithURL(_ url: URL) {
                expectation?.fulfill()
            }
        }
        class MyWKNavigationAction: NavigationAction {
            override var navigationType: WKNavigationType {
                get {
                    return .linkActivated
                }
            }
        }
        
        let url = URL(string: "https://intellum.com/cool/new/link")!
        let delegate = NeemanWebViewController(expectation: expectation)
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url, delegate: delegate, settings: settings)
        let action = MyWKNavigationAction(request: URLRequest(url: url))

        
        navigationDelegate.webView(WKWebView(), decidePolicyFor: action) { (WKNavigationActionPolicy) -> Void in
            
        }
        
        waitForExpectations(timeout: 1) { (error) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }
}
