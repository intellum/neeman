import XCTest
import WebKit
@testable import Neeman

class WebViewUIDelegateTest: XCTestCase {
    let frameInfo = FrameInfo(request: URLRequest(url: URL(string: "https://intellum.com")!))

    func testCreateWebView() {
        let expectation = self.expectation(description: "Pass Error to Delegate")
        
        let url = URL(string: "https://intellum.com")!
        let request = URLRequest(url: url)
        
        class MockNeemanUIDelegate: TestNeemanUIDelegate {
            override func popupWebView(_ newWebView: WKWebView, withURL url: URL) {
                self.expectation.fulfill()
            }
        }
        let delegate = MockNeemanUIDelegate(expectation: expectation)
        let webViewUIDelegate = WebViewUIDelegate(baseURL: url)
        webViewUIDelegate.delegate = delegate
        let _ = webViewUIDelegate.webView(WKWebView(),
            createWebViewWith: WKWebViewConfiguration(),
            for: NavigationAction(request: request),
            windowFeatures: WKWindowFeatures())

        waitForExpectations(timeout: 1) { (error) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }

    func testCloseWebView() {
        let expectation = self.expectation(description: "Pass Error to Delegate")

        let url = URL(string: "https://intellum.com")!
        let webViewUIDelegate = WebViewUIDelegate(baseURL: url)

        class MockNeemanUIDelegate: TestNeemanUIDelegate {
            override func closeWebView(_ webView: WKWebView) {
                expectation.fulfill()
            }
        }
        
        let delegate = MockNeemanUIDelegate(expectation: expectation)
        webViewUIDelegate.delegate = delegate
        webViewUIDelegate.webViewDidClose(WKWebView())

        waitForExpectations(timeout: 1) { (error) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }

    func testAlert() {
        let expectation = self.expectation(description: "Pass Error to Delegate")
        
        let webViewUIDelegate =  MyWebViewUIDelegate(expectation: expectation)
        webViewUIDelegate.webView(WKWebView(), runJavaScriptAlertPanelWithMessage: "",
            initiatedByFrame: frameInfo) { () -> Void in}
        
        waitForExpectations(timeout: 1) { (error) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }

    func testAlertFromThirdParty() {
        let expectation = self.expectation(description: "Refuse Alert")
        let expectationCompletion = self.expectation(description: "Completion Handler Called")
        
        let frameInfo = FrameInfo(request: URLRequest(url: URL(string: "http://hacker.ru")!))
        
        let webViewUIDelegate = RefusingWebViewUIDelegate(expectation: expectation)
        webViewUIDelegate.webView(WKWebView(), runJavaScriptAlertPanelWithMessage: "",
            initiatedByFrame: frameInfo) { () -> Void in
                
                expectationCompletion.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }
    
    func testConfirm() {
        let expectation = self.expectation(description: "Show Confirm")
        
        let webViewUIDelegate = MyWebViewUIDelegate(expectation: expectation)
        webViewUIDelegate.webView(WKWebView(), runJavaScriptConfirmPanelWithMessage: "",
            initiatedByFrame: frameInfo) { (answer: Bool) -> Void in}
        
        waitForExpectations(timeout: 1) { (error) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }
    
    func testConfirmFromThirdParty() {
        let expectation = self.expectation(description: "Refuse Confirm")
        let expectationCompletion = self.expectation(description: "Completion Handler Called")
        
        let frameInfo = FrameInfo(request: URLRequest(url: URL(string: "http://hacker.ru")!))

        let webViewUIDelegate = RefusingWebViewUIDelegate(expectation: expectation)
        webViewUIDelegate.webView(WKWebView(), runJavaScriptConfirmPanelWithMessage: "",
            initiatedByFrame: frameInfo) { (answer: Bool) -> Void in
        
                expectationCompletion.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }
    
    func testPrompt() {
        let expectation = self.expectation(description: "Show Prompt")
        
        let webViewUIDelegate = MyWebViewUIDelegate(expectation: expectation)
        webViewUIDelegate.webView(WKWebView(), runJavaScriptTextInputPanelWithPrompt: "", defaultText: "",
            initiatedByFrame: frameInfo) { (input: String?) -> Void in}
        
        waitForExpectations(timeout: 1) { (error) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }

    func testPromptFromThirdParty() {
        let expectation = self.expectation(description: "Refuse Prompt")
        let expectationCompletion = self.expectation(description: "Completion Handler Called")
        
        let frameInfo = FrameInfo(request: URLRequest(url: URL(string: "http://hacker.ru")!))
        
        let webViewUIDelegate = RefusingWebViewUIDelegate(expectation: expectation)
        webViewUIDelegate.webView(WKWebView(), runJavaScriptTextInputPanelWithPrompt: "", defaultText: "",
            initiatedByFrame: frameInfo) { (input: String?) -> Void in
        
            expectationCompletion.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) -> Void in
            if let _ = error {
                XCTFail("Error Passing Failed")
            }
        }
    }
}

class MyWebViewUIDelegate: WebViewUIDelegate {
    var expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
        super.init(baseURL: URL(string: "https://intellum.com")!)
    }


    override internal func presentAlertController(_ alert: UIAlertController) {
        expectation.fulfill()
    }
}

class RefusingWebViewUIDelegate: WebViewUIDelegate {
    var expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
        super.init(baseURL: URL(string: "https://intellum.com")!)
    }
    
    override internal func refusedUIFromRequest(_ request: URLRequest) {
        expectation.fulfill()
    }
}
