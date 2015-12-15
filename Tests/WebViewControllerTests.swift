import XCTest
import WebKit
import Neeman

class WebViewControllerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitialRequest() {
        let webViewController = WebViewController()
        let urlString = "http://example.com/"
        webViewController.rootURLString = urlString
        let request = NSURLRequest(URL: NSURL(string: urlString)!)
        XCTAssertFalse(webViewController.shouldPushNewWebView(request), "The initial request should not be pushed")
    }
    

    func testHashNavigation() {
        let webViewController = WebViewController()
        webViewController.rootURLString = "http://example.com/"
        let request = NSURLRequest(URL: NSURL(string: "http://example.com/#hash")!)
        
        XCTAssertFalse(webViewController.shouldPushNewWebView(request), "Hash navigation should not be pushed")
    }
    
    func testLogin() {
        let webViewController = WebViewController()
        webViewController.rootURLString = "http://example.com/"
        let request = NSURLRequest(URL: NSURL(string: "http://example.com/login")!)
        
        XCTAssert(webViewController.isLoginRequestRequest(request), "Login should recognized")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
