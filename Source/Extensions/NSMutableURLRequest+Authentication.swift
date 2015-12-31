import UIKit

extension NSMutableURLRequest {
    func authenticate() {
        guard let authCookieName = Settings.sharedInstance.authCookieName else {
            return
        }

        let authToken: String? = Settings.sharedInstance.authToken ?? authTokenFromCookie()
        
        if let token = authToken {
            let authCookie = "\(authCookieName)=\(token);"
            self.setValue(authCookie, forHTTPHeaderField: "Cookie")
        }
    }
    
    func authCookie() -> NSHTTPCookie? {
        guard let authCookieName = Settings.sharedInstance.authCookieName else {
            return nil
        }
        let cookieStore = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let url = self.URL {
            let cookies = cookieStore.cookiesForURL(url)
            if let authCookies = cookies?.filter({$0.name == authCookieName}),
                authCookie = authCookies.first {
                    return authCookie
            }
        }
        return nil
    }
    
    func authTokenFromCookie() -> String? {
        return authCookie()?.value
    }
}
