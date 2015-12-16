import Foundation

public class GroupDockLoginOperation: GroupOperation {
    let AUTH_COOKIE_NAME = "connect.sid"

    // MARK: Properties
    let appName: String
    let username: String
    let password: String
    let errorDomain = "LoginOperationErrorDomain"
    var authToken: String? = nil
    var organization: String? = nil
    internal let urlString = "https://www.groupdock.com/login?app="
    
    // MARK: Initialization
    
    /// - parameter cacheFile: The file `NSURL` to which the earthquake feed will be downloaded.
    public init(appName: String, username: String, password: String) {
        self.appName = appName
        self.username = username
        self.password = password
        
        super.init(operations: [])

        name = "GroupdockLogin"
        
        if appName == "ExampleHybridApp" {
            return
        }
        
        let url = NSURL(string: urlString+appName)!
        let params = ["username":username, "password":password]
        let request = requestForURL(url, params: params)
        request.HTTPMethod = "POST"
        
        addTaskOperationForRequest(request)
    }
    
    func addTaskOperationForRequest(request: NSURLRequest) {
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            let parseDataOperation = NSBlockOperation { () -> Void in
                self.downloadFinished(data, response: response as? NSHTTPURLResponse, error: error)
            }
            self.addOperation(parseDataOperation)
        }
        
        let taskOperation = URLSessionTaskOperation(task: task)
        
        let reachabilityCondition = ReachabilityCondition(host: request.URL!)
        taskOperation.addCondition(reachabilityCondition)
        
        let networkObserver = NetworkObserver()
        taskOperation.addObserver(networkObserver)
        
        addOperation(taskOperation)
    }

    func downloadFinished(data: NSData?, response: NSHTTPURLResponse?, error: NSError?) {
        if let localData = data {
            do {
                let statusCode = response?.statusCode ?? 0
                var errors: [NSError] = []
                if case 200...299 = statusCode {
                    try saveInfoFromData(localData, response: response)
                    if let _ = self.authToken {
                        finish()
                    } else {
                        let error =  NSError(domain: self.errorDomain, code: 3, userInfo: [:])
                        errors.append(error)
                    }
                } else if response?.statusCode == 401 {
                    let error =  NSError(domain: self.errorDomain, code: 1, userInfo: [:])
                    errors.append(error)
                } else {
                    let error =  NSError(domain: self.errorDomain, code: 2, userInfo: [:])
                    errors.append(error)
                }
                finish(errors)
            } catch let error as NSError {
                aggregateError(error)
            }
            
        } else if let error = error {
            aggregateError(error)
        } else {
            // Do nothing, and the operation will automatically finish.
        }
    }
    
    func saveInfoFromData(data: NSData, response: NSHTTPURLResponse?) throws {
        if let jsonObj = try NSJSONSerialization.JSONObjectWithData(
            data,
            options: NSJSONReadingOptions(rawValue:0)) as? Dictionary<String, AnyObject> {
                
                if let headerFields = response?.allHeaderFields as? [String: String] {
                    let url = response!.URL!
                    let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: url)
                    let connectCookies = cookies.filter({ (cookie: NSHTTPCookie) -> Bool in
                        return cookie.name == AUTH_COOKIE_NAME
                    })
                    if let cookie = connectCookies.first {
                        self.authToken = cookie.value
                    }
                }
                if let subdomain = jsonObj["subdomain"] as? String {
                    self.organization = subdomain
                }
        }
    }
}
