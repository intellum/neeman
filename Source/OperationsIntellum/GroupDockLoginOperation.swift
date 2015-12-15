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
    init(appName: String, username: String, password: String) {
        self.appName = appName
        self.username = username
        self.password = password
        
        super.init(operations: [])
        name = "Login"
        
        if appName == "ExampleHybridApp" {
            return;
        }

        
        let url = NSURL(string: urlString+appName)!
        let request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 10)
        
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
        request.addValue("application/json", forHTTPHeaderField:"Accept")
        request.addValue("true", forHTTPHeaderField: "noredirect")
        
        request.HTTPMethod = "POST"
        
        let params = ["username":username, "password":password]
        
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions(rawValue: 0))
        } catch {}
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
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
    
    func downloadFinished(data: NSData?, response: NSHTTPURLResponse?, error: NSError?) {
        if let localData = data {
            do {
                let statusCode = response?.statusCode ?? 0
                var errors :[NSError] = []
                if case 200...299 = statusCode {
                    if let jsonObj = try NSJSONSerialization.JSONObjectWithData(
                        localData,
                        options: NSJSONReadingOptions(rawValue:0)) as? Dictionary<String, AnyObject>
                    {
                        if let headerFields = response?.allHeaderFields as? [String: String] {
                            let url = response!.URL!
                            let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: url)
                            let connectCookies = cookies.filter({ (cookie:NSHTTPCookie) -> Bool in
                                return cookie.name == AUTH_COOKIE_NAME
                            })
                            if let cookie = connectCookies.first {
                                self.authToken = cookie.value
                            }
                        }
                        if let organization = jsonObj["organization"] as? [String: AnyObject],
                                name = organization["name"] as? String
                        {
                            self.organization = name
                        }
                    }

                    if let _ = self.authToken {
                        finish()
                    }else{
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
            }
            catch let error as NSError {
                aggregateError(error)
            }
            
        }
        else if let error = error {
            aggregateError(error)
        }
        else {
            // Do nothing, and the operation will automatically finish.
        }
    }
}