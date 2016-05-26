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
        let url = NSURL(string: "http://example.com/")
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: nil, settings: settings)
        let request = NSURLRequest(URL: url!)
        let webView = WKWebView()
        let navigationAction = NavigationAction(request: request)
        XCTAssertFalse(navigationDelegate.shouldPushForRequestFromWebView(webView, navigationAction: navigationAction),
                       "The initial request should not be pushed")
    }
    
    
    func testFaultyURLNavigation() {
        let url = NSURL(string: "http://example.com/")
        let urlFaulty = NSURL()
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: nil, settings: settings)
        let request = NSURLRequest(URL: urlFaulty)
        let navigationAction = NavigationAction(request: request)
        
        let webView = WKWebView()
        XCTAssertFalse(navigationDelegate.shouldPushForRequestFromWebView(webView, navigationAction: navigationAction),
                       "Faulty URLs should not be pushed")
    }
    
    func testHashNavigation() {
        let url = NSURL(string: "http://example.com/#hash")
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: nil, settings: settings)
        let request = NSURLRequest(URL: url!)
        let navigationAction = NavigationAction(request: request)
        
        let webView = WKWebView()
        XCTAssertFalse(navigationDelegate.shouldPushForRequestFromWebView(webView, navigationAction: navigationAction),
                       "Hash navigation should not be pushed")
    }
    
    func testNavigateForward() {
        let url1 = NSURL(string: "http://example.com/")
        let url2 = NSURL(string: "http://example.com/user/profile/me")
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url1!, delegate: nil, settings: settings)
        let request = NSURLRequest(URL: url2!)
        let navigationAction = NavigationAction(request: request)
        
        let webView = WKWebView()
        XCTAssertTrue(navigationDelegate.shouldPushForRequestFromWebView(webView, navigationAction: navigationAction),
                      "New URLs should not be pushed")
    }
    
    // MARK: Delegation
    
    func testPreventPush() {
        class NeemanWebViewController: TestNeemanNavigationDelegate {
            override func shouldPreventPushOfNavigationAction(navigationAction: WKNavigationAction) -> Bool {
                return true
            }
        }
        
        let url = NSURL(string: "https://groupdock.com/a/Level")
        let request = NSURLRequest(URL: url!)
        let navigationAction = NavigationAction(request: request)
        let delegate = NeemanWebViewController()
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: delegate, settings: settings)
        let webView = WKWebView()
        XCTAssertFalse(navigationDelegate.shouldPushForRequestFromWebView(webView, navigationAction: navigationAction),
                       "The delegate should prevent the URL being pushed")
    }
    
    func testErrorPassedToDelegate() {
        let expectation = expectationWithDescription("Pass Error to Delegate")
        class NeemanWebViewController: TestNeemanNavigationDelegate {
            override func webView(webView: WKWebView, didFinishLoadingWithError error: NSError) {
                XCTAssertNotNil(error, "The delegate should be passed a non nil error")
                expectation?.fulfill()
            }
        }
        
        let url = NSURL(string: "https://groupdock.com/a/Level")
        let delegate = NeemanWebViewController(expectation: expectation)
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: delegate, settings: settings)
        let error = NSError(domain: "", code: 1, userInfo: nil)
        navigationDelegate.webView(WKWebView(), didFailProvisionalNavigation: nil, withError: error)
        
        waitForExpectationsWithTimeout(1) { (error: NSError?) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }
    
    func testDecidePolicyForNavigationAction() {
        let expectation = expectationWithDescription("Call Callback")
        let url = NSURL(string: "https://groupdock.com/a/Level")
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: nil, settings: settings)
        let request = NSURLRequest(URL: url!)
        let navigationAction = NavigationAction(request: request)
        navigationDelegate.webView(WKWebView(), decidePolicyForNavigationAction: navigationAction) { (policy: WKNavigationActionPolicy) -> Void in
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1) { (error: NSError?) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }
    
    func testShouldPreventPushOfNewWebView() {
        class MyWKNavigation: NSObject {
        }
        class MyNeemanWebViewController: TestNeemanNavigationDelegate {
            override func shouldPreventPushOfNavigationAction(navigationAction: WKNavigationAction) -> Bool {
                return true
            }
        }
        
        let url = NSURL(string: "https://groupdock.com/a/Level")
        let delegate = MyNeemanWebViewController()
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: delegate, settings: settings)
        let webView = WKWebView()
        let navigationAction = NavigationAction(request: NSURLRequest(URL:url!))

        XCTAssertFalse(navigationDelegate.shouldPushForRequestFromWebView(webView, navigationAction: navigationAction),
                       "The delegate should prevent the URL being pushed")
    }
    
    func testDelegateDefaultImplementations() {
        class MyNeemanWebViewController: TestNeemanNavigationDelegate {
        }
        
        let webView = WKWebView()
        let navigationAction = NavigationAction(request: NSURLRequest())
        let delegate = MyNeemanWebViewController()
        delegate.webView(webView, didFinishNavigationWithURL:nil)
        delegate.webView(webView, didFinishLoadingWithError: NSError(domain: "", code: 1, userInfo: nil))
        delegate.webView(webView, didReceiveServerRedirectToURL: nil)
        delegate.shouldForcePushOfNavigationAction(navigationAction)
        delegate.pushNewWebViewControllerWithURL(NSURL())
        delegate.shouldPreventPushOfNavigationAction(navigationAction)
    }
    
    func testDelegateMethodsCalled() {
        let expectation = expectationWithDescription("Pass Error to Delegate")
        class NeemanWebViewController: TestNeemanNavigationDelegate {
            override func webView(webView: WKWebView, didFinishNavigationWithURL: NSURL?) {
                expectation?.fulfill()
            }
        }
        
        let url = NSURL(string: "https://intellum.com/cool/new/link")!
        let delegate = NeemanWebViewController(expectation: expectation)
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url, delegate: delegate, settings: settings)
        
        navigationDelegate.webView(WKWebView(), didFinishNavigation: nil)

        waitForExpectationsWithTimeout(1) { (error: NSError?) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }
    
    func testDelegateRedirectMethodsCalled() {
        let expectation = expectationWithDescription("Pass Error to Delegate")
        class NeemanWebViewController: TestNeemanNavigationDelegate {
            override func webView(webView: WKWebView, didReceiveServerRedirectToURL: NSURL?) {
                expectation?.fulfill()
            }
        }
        
        let url = NSURL(string: "https://intellum.com/cool/new/link")!
        let delegate = NeemanWebViewController(expectation: expectation)
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url, delegate: delegate, settings: settings)
        
        navigationDelegate.webView(WKWebView(), didReceiveServerRedirectForProvisionalNavigation: nil)
        
        waitForExpectationsWithTimeout(1) { (error: NSError?) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }
    
    func testPushIsCalled() {
        let expectation = expectationWithDescription("Pass Error to Delegate")
        class NeemanWebViewController: TestNeemanNavigationDelegate {
            override func shouldForcePushOfNavigationAction(navigationAction: WKNavigationAction) -> Bool {
                return true
            }
            override func pushNewWebViewControllerWithURL(url: NSURL) {
                expectation?.fulfill()
            }
        }
        class MyWKNavigationAction: NavigationAction {
            override var navigationType: WKNavigationType {
                get {
                    return .LinkActivated
                }
            }
        }
        
        let url = NSURL(string: "https://intellum.com/cool/new/link")!
        let delegate = NeemanWebViewController(expectation: expectation)
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url, delegate: delegate, settings: settings)
        let action = MyWKNavigationAction(request: NSURLRequest(URL: url))

        
        navigationDelegate.webView(WKWebView(), decidePolicyForNavigationAction: action) { (WKNavigationActionPolicy) -> Void in
            
        }
        
        waitForExpectationsWithTimeout(1) { (error: NSError?) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }
}
