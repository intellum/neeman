import UIKit
import KeychainAccess

extension NSMutableURLRequest {
    func authenticate() {
        guard let authCookieName = Settings.sharedInstance.authCookieName else {
            return
        }

        let keychain = Settings.sharedInstance.keychain
        if let authToken = keychain["app_auth_cookie"] {
            let authCookie = "\(authCookieName)=\(authToken);"
            self.setValue(authCookie, forHTTPHeaderField: "Cookie")
        }

    }
}
