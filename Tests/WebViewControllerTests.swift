import XCTest
import WebKit
@testable import Neeman

class WebViewControllerTests: XCTestCase {
    
    var settings: NeemanSettings {
        get {
            let pathToSettings = NSBundle.init(forClass: WebViewNavigationDelegateTests.self).pathForResource("Settings", ofType: "plist")
            return NeemanSettings(path: pathToSettings)
        }
    }
    
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

    func testSettings() {
        let webViewController = WebViewController()
        let webViewController2 = WebViewController()
        webViewController2.settings = settings
        XCTAssertNotNil(webViewController.settings)
        XCTAssertFalse(settings === webViewController.settings, "Settings should be different")
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
