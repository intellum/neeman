import Foundation


public class GroupDockSingleSignOnOperation: GroupOperation, NSURLSessionDelegate {
    // MARK: Properties
    
    let errorDomain = "GroupDockSSOOperationErrorDomain"
    var appName: String
    var authToken: String
    var organization: String
    var appAuthToken: String?
    let authCookieName = "connect.sid"
    var rootURLString: String?
    
    // MARK: Initialization
    
    /// - parameter cacheFile: The file `NSURL` to which the earthquake feed will be downloaded.
    init(appName: String, organization: String, authToken: String) {
        
        self.appName = appName
        self.organization = organization
        self.authToken = authToken
        
        super.init(operations: [])
        
        self.addSubOperations()
    }
    
    func addSubOperations() {
        let url = NSURL(string: "https://www.groupdock.com/sso/" + appName + "?account=" + organization)!
        let request = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
//        request.addValue("application/json", forHTTPHeaderField:"Accept")
        request.addValue("true", forHTTPHeaderField: "noredirect")
        
        let authCookie = "\(authCookieName)=\(authToken);"
        request.setValue(authCookie, forHTTPHeaderField: "Cookie")
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        let task = session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
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
        
        if let url = response?.URL {
            rootURLString = url.scheme + "://" + url.host!
        }

        if let _ = appAuthToken {
            return
        }
        
        if let _ = data {
            let statusCode = response?.statusCode ?? 0
            var errors: [NSError] = []
            
            if case 200...299 = statusCode {
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
            
        } else if let error = error {
            aggregateError(error)
        } else {
            // Do nothing, and the operation will automatically finish.
        }
    }
    
    internal func URLSession(session: NSURLSession,
        task: NSURLSessionTask,
        willPerformHTTPRedirection response: NSHTTPURLResponse,
        newRequest request: NSURLRequest,
        completionHandler: (NSURLRequest?) -> Void) {
            
        completionHandler(request)
            
        
        if appAuthToken == nil && request.URL?.absoluteString .rangeOfString("/sso/launch") == nil {
            if let headerFields = response.allHeaderFields as? [String: String],
                urlString = headerFields["Location"],
                url = NSURL(string: urlString) {
                
                    let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: url)
                    if let urlComponents = NSURLComponents(URL: response.URL!, resolvingAgainstBaseURL: false) {
                    let connectCookies = cookies.filter({ (cookie: NSHTTPCookie) -> Bool in
                        return cookie.name == authCookieName && cookie.domain.rangeOfString(urlComponents.host!) != nil
                    })
                    if let cookie = connectCookies.first {
                        self.appAuthToken = cookie.value
                        Settings.sharedInstance.authToken = cookie.value
                        if let baseURL = request.URL?.absoluteString {
                            Settings.sharedInstance.baseURL = baseURL
                        }
                    }
                }
            }
            return
        }
    }
}
