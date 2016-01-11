import XCTest
import WebKit
@testable import Neeman

class WebViewUIDelegateTest: XCTestCase {
    let settings = Settings(dictionary: ["baseURL": "https://intellum.com"])
    let frameInfo = FrameInfo(request: NSURLRequest(URL: NSURL(string: "https://intellum.com")!))

    func testCreateWebView() {
        let expectation = expectationWithDescription("Pass Error to Delegate")
        
        let url = NSURL(string: settings.baseURL)!
        let request = NSURLRequest(URL: url)
        
        class MockNeemanUIDelegate: TestNeemanUIDelegate {
            override func popupWebView(newWebView: WKWebView, withURL url: NSURL) {
                self.expectation.fulfill()
            }
        }
        let delegate = MockNeemanUIDelegate(expectation: expectation)
        let webViewUIDelegate = WebViewUIDelegate(settings: settings)
        webViewUIDelegate.delegate = delegate
        webViewUIDelegate.webView(WKWebView(),
            createWebViewWithConfiguration: WKWebViewConfiguration(),
            forNavigationAction: NavigationAction(request: request),
            windowFeatures: WKWindowFeatures())

        waitForExpectationsWithTimeout(1) { (error: NSError?) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }

    func testCloseWebView() {
        let expectation = expectationWithDescription("Pass Error to Delegate")

        let webViewUIDelegate = WebViewUIDelegate(settings: settings)
        
        class MockNeemanUIDelegate: TestNeemanUIDelegate {
            override func closeWebView(webView: WKWebView) {
                expectation.fulfill()
            }
        }
        
        let delegate = MockNeemanUIDelegate(expectation: expectation)
        webViewUIDelegate.delegate = delegate
        webViewUIDelegate.webViewDidClose(WKWebView())

        waitForExpectationsWithTimeout(1) { (error: NSError?) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }

    func testAlert() {
        let expectation = expectationWithDescription("Pass Error to Delegate")
        
        let webViewUIDelegate = MyWebViewUIDelegate(settings: settings, expectation: expectation)
        webViewUIDelegate.webView(WKWebView(), runJavaScriptAlertPanelWithMessage: "",
            initiatedByFrame: frameInfo) { () -> Void in}
        
        waitForExpectationsWithTimeout(1) { (error: NSError?) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }

    func testConfirm() {
        let expectation = expectationWithDescription("Show Confirm")
        
        let webViewUIDelegate = MyWebViewUIDelegate(settings: settings, expectation: expectation)
        webViewUIDelegate.webView(WKWebView(), runJavaScriptConfirmPanelWithMessage: "",
            initiatedByFrame: frameInfo) { (answer: Bool) -> Void in}
        
        waitForExpectationsWithTimeout(1) { (error: NSError?) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }
    
    func testConfirmFromThirdParty() {
        let expectation = expectationWithDescription("Refuse Confirm")
        
        let frameInfo = FrameInfo(request: NSURLRequest(URL: NSURL(string: "http://hacker.ru")!))

        let webViewUIDelegate = RefusingWebViewUIDelegate(settings: settings, expectation: expectation)
        webViewUIDelegate.webView(WKWebView(), runJavaScriptConfirmPanelWithMessage: "",
            initiatedByFrame: frameInfo) { (answer: Bool) -> Void in}
        
        waitForExpectationsWithTimeout(1) { (error: NSError?) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }
    
    func testPrompt() {
        let expectation = expectationWithDescription("Show Prompt")
        
        let webViewUIDelegate = MyWebViewUIDelegate(settings: settings, expectation: expectation)
        webViewUIDelegate.webView(WKWebView(), runJavaScriptTextInputPanelWithPrompt: "", defaultText: "",
            initiatedByFrame: frameInfo) { (input: String?) -> Void in}
        
        waitForExpectationsWithTimeout(1) { (error: NSError?) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }

    func testPromptFromThirdParty() {
        let expectation = expectationWithDescription("Refuse Prompt")
        
        let frameInfo = FrameInfo(request: NSURLRequest(URL: NSURL(string: "http://hacker.ru")!))
        
        let webViewUIDelegate = RefusingWebViewUIDelegate(settings: settings, expectation: expectation)
        webViewUIDelegate.webView(WKWebView(), runJavaScriptTextInputPanelWithPrompt: "", defaultText: "",
            initiatedByFrame: frameInfo) { (input: String?) -> Void in}
        
        waitForExpectationsWithTimeout(1) { (error: NSError?) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }
}

class MyWebViewUIDelegate: WebViewUIDelegate {
    var expectation: XCTestExpectation
    
    init(settings: Settings, expectation: XCTestExpectation) {
        self.expectation = expectation
        super.init(settings: settings)
    }

    override internal func presentAlertController(alert: UIAlertController) {
        expectation.fulfill()
    }
}

class RefusingWebViewUIDelegate: WebViewUIDelegate {
    var expectation: XCTestExpectation
    
    init(settings: Settings, expectation: XCTestExpectation) {
        self.expectation = expectation
        super.init(settings: settings)
    }
    
    override internal func refusedUIFromRequest(request: NSURLRequest) {
        expectation.fulfill()
    }
}
