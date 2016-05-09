import XCTest
@testable import Neeman

class SettingsTests: XCTestCase {
    func testObjectSubscript() {
        let settings = NeemanSettings(dictionary: ["baseURL": "https://intellum.com"])
        XCTAssertNotNil(settings["baseURL"])
    }
}
