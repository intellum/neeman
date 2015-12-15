import UIKit
import XCTest
import Neeman

class GroupDockLoginOperationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLogin() {
        let username = "stephen_test"
        let password = "st3ph3n"
        
        
        class LoginDelegate: OperationObserver {
            var expectation: XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func operationDidStart(operation: Operation) {}
            func operation(operation: Operation, didProduceOperation newOperation: NSOperation) {}
            func operationDidFinish(operation: Operation, errors: [NSError]) {
                expectation.fulfill()
            }
        }
        
        let expectation = expectationWithDescription("loggin")
        
        let loginOperation = GroupDockLoginOperation(appName: "Level", username: username, password: password)
        loginOperation.addObserver(LoginDelegate(expectation: expectation))
        let operationQueue = OperationQueue()
        operationQueue.addOperation(loginOperation)

        waitForExpectationsWithTimeout(30) { (error: NSError?) -> Void in
            if let _ = error {
                XCTFail("Login Failed")
            }
        }
    }
}
