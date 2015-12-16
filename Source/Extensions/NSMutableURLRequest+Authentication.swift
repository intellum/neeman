import UIKit
import KeychainAccess

extension NSMutableURLRequest {
    func authenticate() {
        guard let authCookieName = Settings.sharedInstance.authCookieName else {
            return
        }

        let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let urlComponents = NSURLComponents(string: Settings.sharedInstance.baseURL)
        let authCookies = cookieStorage.cookies?.filter({$0.name == authCookieName && $0.domain == urlComponents?.host})
        if let cookies = authCookies {
            self.allHTTPHeaderFields = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies)
        }
        
        if authCookies?.count == 0 {
            let keychain = Keychain(service: Settings.sharedInstance.keychainService)
            if let authToken = keychain["app_auth_cookie"] {
                let authCookie = "\(authCookieName)=\(authToken);"
                self.setValue(authCookie, forHTTPHeaderField: "Cookie")
            }
        }

    }
}
