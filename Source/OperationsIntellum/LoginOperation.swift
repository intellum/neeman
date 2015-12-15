import Foundation
import KeychainAccess

public class LoginOperation: GroupOperation, OperationObserver {
    let AUTH_COOKIE_NAME = Settings.sharedInstance.authCookieName

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
            let ssoOperation = NSBlockOperation { () -> Void in
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

        
    }
    
    public func operationDidStart(operation: Operation) {
    }
    
    public func operation(operation: Operation, didProduceOperation newOperation: NSOperation) {
    }
    
    public func operationDidFinish(operation: Operation, errors: [NSError]) {
        if let groupDockSSOOperation = groupDockSSOOperation,
               authToken = groupDockSSOOperation.appAuthToken
        {
            didLoginWithAuthToken(authToken)
        }
    }
    
    func didLoginWithAuthToken(authToken: String) {
        self.authToken = authToken
        let keychain = Keychain(service: "com.intellum.level")
        keychain["app_auth_cookie"] = authToken
        
        var expiresDateString = NSDate().dateByAddingTimeInterval(60*60*24*365)

        let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let groupdockCookie = cookieStorage.cookies?.filter({$0.name == AUTH_COOKIE_NAME && $0.domain == "www.groupdock.com"}),
            cookie = groupdockCookie.first
        {
            if let date = cookie.properties?[NSHTTPCookieExpires] as? NSDate {
                expiresDateString = date
            }
        }

        if let cookieName = Settings.sharedInstance.authCookieName,
            urlComponents = NSURLComponents(string: Settings.sharedInstance.baseURL),
            host = urlComponents.host
        {
            let properties = [
                NSHTTPCookieName:cookieName,
                NSHTTPCookieValue:authToken,
                NSHTTPCookieDomain:host,
                NSHTTPCookieOriginURL:host,
                NSHTTPCookiePath:"/",
                NSHTTPCookieExpires: expiresDateString
            ];
            if let cookie = NSHTTPCookie(properties: properties) {
                cookieStorage.setCookie(cookie)
            }
         }
    }
    
    func authTokenName() {
        
    }
}