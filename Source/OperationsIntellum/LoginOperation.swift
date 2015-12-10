import Foundation
import KeychainAccess

class LoginOperation: GroupOperation, OperationObserver {
    // MARK: Properties
    let appName: String
    let username: String
    let password: String
    var authToken: String?
    let groupDockLoginOperation: GroupDockLoginOperation
    var groupDockSSOOperation: GroupDockSingleSignOnOperation? = nil
    
    // MARK: Initialization
    
    init(appName: String, username: String, password: String) {
        self.appName = appName
        self.username = username
        self.password = password
        
        groupDockLoginOperation = GroupDockLoginOperation(appName: appName, username: username, password: password)
        
        super.init(operations: [groupDockLoginOperation])
        name = "Login"
        
        let ssoOperation = NSBlockOperation { () -> Void in
            print("finishOperation block")
            if let authToken = self.groupDockLoginOperation.authToken {
                let appName = Settings.sharedInstance.appName
                self.groupDockSSOOperation = GroupDockSingleSignOnOperation(appName: appName, authToken:authToken)
                
                self.addOperation(self.groupDockSSOOperation!)
                self.groupDockSSOOperation!.addObserver(self)
            }
        }
        ssoOperation.addDependency(groupDockLoginOperation)
        self.addOperation(ssoOperation)
    }
    
    func operationDidStart(operation: Operation) {
    }
    
    func operation(operation: Operation, didProduceOperation newOperation: NSOperation) {
    }
    
    func operationDidFinish(operation: Operation, errors: [NSError]) {
        if let groupDockSSOOperation = groupDockSSOOperation,
               authToken = groupDockSSOOperation.appAuthToken
        {
            self.authToken = authToken
            let keychain = Keychain(service: "com.intellum.level")
            keychain["app_auth_cookie"] = authToken
        }
    }
}