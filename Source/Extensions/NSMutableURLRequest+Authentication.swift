import UIKit

extension NSMutableURLRequest {
    func authenticateWithSettings(settings: Settings) {
        guard let authCookieName = settings.authCookieName else {
            return
        }

        let authToken: String? = settings.authToken ?? authTokenFromCookie(settings)
        
        if let token = authToken {
            let authCookie = "\(authCookieName)=\(token);"
            self.setValue(authCookie, forHTTPHeaderField: "Cookie")
        }
    }
    
    func authTokenFromCookie(settings: Settings) -> String? {
        return authCookie(settings)?.value
    }

    func authCookie(settings: Settings) -> NSHTTPCookie? {
        guard let authCookieName = settings.authCookieName else {
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
}
