import UIKit

extension Operation {
    func requestForURL(url: NSURL, params: [String: AnyObject]) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 10)
        
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
        request.addValue("application/json", forHTTPHeaderField:"Accept")
        request.addValue("true", forHTTPHeaderField: "noredirect")

        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions(rawValue: 0))
        } catch {}

        return request
    }
}