import XCTest
import WebKit
@testable import Neeman

class WebViewNavigationDelegateTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialRequest() {
        let url = NSURL(string: "http://example.com/")
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: nil)
        let request = NSURLRequest(URL: url!)
        XCTAssertFalse(navigationDelegate.shouldPushNewWebView(request), "The initial request should not be pushed")
    }
    
    
    func testFaultyURLNavigation() {
        let url = NSURL(string: "http://example.com/")
        let urlFaulty = NSURL()
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: nil)
        let request = NSURLRequest(URL: urlFaulty)
        
        XCTAssertFalse(navigationDelegate.shouldPushNewWebView(request), "Faulty URLs should not be pushed")
    }
    
    func testHashNavigation() {
        let url = NSURL(string: "http://example.com/#hash")
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: nil)
        let request = NSURLRequest(URL: url!)
        
        XCTAssertFalse(navigationDelegate.shouldPushNewWebView(request), "Hash navigation should not be pushed")
    }
    
    func testNavigateForward() {
        let url1 = NSURL(string: "http://example.com/")
        let url2 = NSURL(string: "http://example.com/user/profile/me")
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url1!, delegate: nil)
        let request = NSURLRequest(URL: url2!)
        
        XCTAssertTrue(navigationDelegate.shouldPushNewWebView(request), "New URLs should not be pushed")
    }
    
    func testLogin() {
        let url = NSURL(string: "http://example.com/login")
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: nil)
        let request = NSURLRequest(URL: url!)
        
        XCTAssert(navigationDelegate.isLoginRequestRequest(request), "Login should recognized")
    }
    
    func testOrgNotFoundNavigation() {
        let url = NSURL(string: "https://groupdock.com/a/Level")
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: nil)
        let request = NSURLRequest(URL: url!)
        
        XCTAssertFalse(navigationDelegate.isLoginRequestRequest(request), "Organisation not found should not be pushed")
    }
    
    // MARK: Delegation
    
    func testErrorPassedToDelegate() {
        let expectation = expectationWithDescription("Pass Error to Delegate")
        class MyWKNavigation: NSObject {
        }
        class MyNeemanWebViewController: NSObject, NeemanNavigationDelegate {
            var expectation: XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func webView(webView: WKWebView, didFinishLoadingWithError error: NSError) {
                XCTAssertNotNil(error, "The delegate should be passed a non nil error")
                expectation.fulfill()
            }
            func showLogin() {
                
            }
            func pushNewWebViewControllerWithURL(url: NSURL) {
                
            }
        }
        
        let url = NSURL(string: "https://groupdock.com/a/Level")
        let delegate = MyNeemanWebViewController(expectation: expectation)
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: delegate)
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
        class MyWKNavigationAction: WKNavigationAction {
            var myRequest: NSURLRequest
            override var request: NSURLRequest {
                get {
                    return myRequest
                }
            }
            init(request: NSURLRequest) {
                myRequest = request
            }
        }
        let url = NSURL(string: "https://groupdock.com/a/Level")
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: nil)
        let request = NSURLRequest(URL: url!)
        let navigationAction = MyWKNavigationAction(request: request)
        navigationDelegate.webView(WKWebView(), decidePolicyForNavigationAction: navigationAction) { (policy: WKNavigationActionPolicy) -> Void in
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1) { (error: NSError?) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }
}
