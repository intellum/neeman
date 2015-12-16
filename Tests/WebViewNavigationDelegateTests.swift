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
    

    func testHashNavigation() {
        let url = NSURL(string: "http://example.com/")
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: nil)
        let request = NSURLRequest(URL: NSURL(string: "http://example.com/#hash")!)
        
        XCTAssertFalse(navigationDelegate.shouldPushNewWebView(request), "Hash navigation should not be pushed")
    }
    
    func testLogin() {
        let url = NSURL(string: "http://example.com/")
        let navigationDelegate = WebViewNavigationDelegate(rootURL: url!, delegate: nil)
        let request = NSURLRequest(URL: NSURL(string: "http://example.com/login")!)
        
        XCTAssert(navigationDelegate.isLoginRequestRequest(request), "Login should recognized")
    }
}
