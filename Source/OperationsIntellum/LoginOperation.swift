import Foundation
import KeychainAccess

public class LoginOperation: GroupOperation, OperationObserver {
    let authCookieName = Settings.sharedInstance.authCookieName

    // MARK: Properties
    let appName: String
    let username: String
    let password: String
    public var authToken: String?
    let groupDockLoginOperation: GroupDockLoginOperation
    var groupDockSSOOperation: GroupDockSingleSignOnOperation? = nil
    
    // MARK: Initialization
    
    public init(appName: String, username: String, password: String) {
        self.appName = appName
        self.username = username
        self.password = password
        
        groupDockLoginOperation = GroupDockLoginOperation(appName: appName, username: username, password: password)
        
        super.init(operations: [groupDockLoginOperation])
        name = "Login"
        
        if appName == "ExampleHybridApp" {
            let setKeyOperation = NSBlockOperation { () -> Void in
                let authToken = "this-is-your-auth-token"
                self.didLoginWithAuthToken(authToken)
            }
            self.addOperation(setKeyOperation)
        } else {
            let ssoOperation = NSBlockOperation { [weak self] () -> Void in
                self?.addSSOOperation()
            }
            ssoOperation.addDependency(groupDockLoginOperation)
            self.addOperation(ssoOperation)
        }
    }
    
    func addSSOOperation() {
        if let authToken = self.groupDockLoginOperation.authToken,
                organization = self.groupDockLoginOperation.organization {
            let appName = Settings.sharedInstance.appName
            self.groupDockSSOOperation = GroupDockSingleSignOnOperation(appName: appName, organization: organization, authToken:authToken)
            
            self.addOperation(self.groupDockSSOOperation!)
            self.groupDockSSOOperation!.addObserver(self)
        }
    }
    
    public func operationDidStart(operation: Operation) {
    }
    
    public func operation(operation: Operation, didProduceOperation newOperation: NSOperation) {
    }
    
    public func operationDidFinish(operation: Operation, errors: [NSError]) {
        if let groupDockSSOOperation = groupDockSSOOperation,
               authToken = groupDockSSOOperation.appAuthToken {
            didLoginWithAuthToken(authToken)
        }
    }
    
    func didLoginWithAuthToken(authToken: String) {
        self.authToken = authToken
        NSURLCache.sharedURLCache().removeAllCachedResponses()
    }
}
