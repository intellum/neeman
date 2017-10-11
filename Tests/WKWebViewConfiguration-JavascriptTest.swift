import XCTest
import WebKit
@testable import Neeman

class WKWebViewConfigurationJavascriptTest: XCTestCase {
    func testExistingFile() {
        let config = WKWebViewConfiguration()
        let contents = config.contentsOfFileNamed("Test.js", inBundle: Bundle(for: object_getClass(self)))
        XCTAssertNotEqual(contents, "")
    }
    
    func testNotExistingFile() {
        let config = WKWebViewConfiguration()
        let path = "NotExistingFilePath"
        let contents = config.contentsOfFileAtPath(path)
        XCTAssertEqual(contents, "")
    }

//    func testCombinedFiles() {
//        class WebViewConfiguration: WKWebViewConfiguration {
//            override func contentsOfNeemansWithName(_ fileName: String) -> String {
//                return "1"
//            }
//            override func contentsOfMainBundlesFileWithName(_ fileName: String) -> String {
//                return "2"
//            }
//        }
//        let webViewConfiguration = WebViewConfiguration()
//        XCTAssertEqual(webViewConfiguration.stringFromContentInFileName("hello.test"), "12")
//    }
}
