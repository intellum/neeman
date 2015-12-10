import Foundation


public class GroupDockSingleSignOnOperation: GroupOperation, NSURLSessionDelegate {
    // MARK: Properties
    
    let errorDomain = "GroupDockSSOOperationErrorDomain"
    var appName: String
    var authToken: String
    var appAuthToken: String?
    let AUTH_COOKIE_NAME = "connect.sid"
    
    // MARK: Initialization
    
    /// - parameter cacheFile: The file `NSURL` to which the earthquake feed will be downloaded.
    init(appName: String, authToken: String) {
        
        self.appName = appName
        self.authToken = authToken
        
        super.init(operations: [])
        
        self.addSubOperations()
    }
    
    func addSubOperations() {
        let url = NSURL(string: "https://www.groupdock.com/sso/" + appName + "?account=intellum")!
        let request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 10)
        
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
//        request.addValue("application/json", forHTTPHeaderField:"Accept")
        request.addValue("true", forHTTPHeaderField: "noredirect")
        
        let authCookie = "\(AUTH_COOKIE_NAME)=\(authToken);"
        request.setValue(authCookie, forHTTPHeaderField: "Cookie")
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
//        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            let parseDataOperation = NSBlockOperation { () -> Void in
                self.downloadFinished(data, response: response as? NSHTTPURLResponse, error: error)
            }
            self.addOperation(parseDataOperation)
        }
        
        let taskOperation = URLSessionTaskOperation(task: task)
        
        let reachabilityCondition = ReachabilityCondition(host: url)
        taskOperation.addCondition(reachabilityCondition)
        
        let networkObserver = NetworkObserver()
        taskOperation.addObserver(networkObserver)
        
        addOperation(taskOperation)
    }
    
    override func execute() {
        super.execute()
    }
    
    func downloadFinished(data: NSData?, response: NSHTTPURLResponse?, error: NSError?) {
        if let _ = appAuthToken {
            finish()
        }
        
        if let _ = data {
            let statusCode = response?.statusCode ?? 0
            var errors :[NSError] = []
            
            if case 200...299 = statusCode {
                if let headerFields = response?.allHeaderFields as? [String: String] {
                    let url = response!.URL!
                    let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: url)
                    let connectCookies = cookies.filter({ (cookie:NSHTTPCookie) -> Bool in
                        return cookie.name == AUTH_COOKIE_NAME
                    })
                    if let cookie = connectCookies.first {
                        self.appAuthToken = cookie.value
                    }
                }

                finish()
            } else if response?.statusCode == 401 {
                let error =  NSError(domain: self.errorDomain, code: 401, userInfo: [:])
                errors.append(error)
            } else if response?.statusCode == 403 {
                let error =  NSError(domain: self.errorDomain, code: 403, userInfo: [:])
                errors.append(error)
            } else {
                let error =  NSError(domain: self.errorDomain, code: 2, userInfo: [:])
                errors.append(error)
            }
            finish(errors)
            
        }
        else if let error = error {
            aggregateError(error)
        }
        else {
            // Do nothing, and the operation will automatically finish.
        }
    }
    
    internal func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void)
    {
        completionHandler(request)
        
        guard let _ = self.appAuthToken else {
            
            if let headerFields = response.allHeaderFields as? [String: String] {
                let url = response.URL!
                let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: url)
                let connectCookies = cookies.filter({ (cookie:NSHTTPCookie) -> Bool in
                    return cookie.name == AUTH_COOKIE_NAME && cookie.domain.rangeOfString("groupdock.com")==nil
                })
                if let cookie = connectCookies.first {
                    self.appAuthToken = cookie.value
                }
            }
            return
        }
    }
}