import XCTest
import WebKit
@testable import Neeman

class WebViewControllerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testView() {
        let webViewController = WebViewController()
        XCTAssertNotNil(webViewController.view)
    }

    func testRootURL() {
        let webViewController = WebViewController()
        webViewController.URLString = "https://intellum.com/index.cfm"
        XCTAssertNotNil(webViewController.rootURL)
    }
    
    func testPartialRootURL() {
        let webViewController = WebViewController()
        webViewController.URLString = "/index.cfm"
        XCTAssertNotNil(webViewController.rootURL)
    }
    
    func testNoRootURLString() {
        let webViewController = WebViewController()
        XCTAssertNil(webViewController.rootURL, "The URL should be empty")
    }
}
