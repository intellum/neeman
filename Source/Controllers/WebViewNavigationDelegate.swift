import UIKit
import WebKit
import KeychainAccess

protocol NeemanWebViewController {
    func webViewDidFinishLoadingWithError(error: NSError)
    func showLogin()
    func pushNewWebViewControllerWithURL(url: NSURL)
}

class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
    
    let keychain = Settings.sharedInstance.keychain
    let authCookieName = Settings.sharedInstance.authCookieName
    var rootURL: NSURL
    var delegate: NeemanWebViewController?
    
    init(rootURL: NSURL, delegate: NeemanWebViewController?) {
        self.rootURL = rootURL
        self.delegate = delegate
    }
    
    func webView(webView: WKWebView,
        decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse,
        decisionHandler: (WKNavigationResponsePolicy) -> Void) {
            saveCookiesFromResponse(navigationResponse.response)
            decisionHandler(.Allow)
    }
    
    func webView(webView: WKWebView,
        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
        decisionHandler: (WKNavigationActionPolicy) -> Void) {
            
            var actionPolicy: WKNavigationActionPolicy = .Allow
            
            let shouldPush = shouldPushNewWebView(navigationAction.request)
            if navigationAction.navigationType == .LinkActivated && shouldPush {
                delegate?.pushNewWebViewControllerWithURL(navigationAction.request.URL!)
                actionPolicy = .Cancel
            } else if isLoginRequestRequest(navigationAction.request) {
                actionPolicy = .Cancel
                delegate?.showLogin()
            }
            
            let actionString = (actionPolicy.rawValue == 1) ? "Allowed" : "Canceled"
            print("URL: " + (navigationAction.request.URL?.absoluteString)! + "\t\t\t- " + actionString)
            
            decisionHandler(actionPolicy)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        delegate?.webViewDidFinishLoadingWithError(error)
    }
    
    // MARK: Should Push
    
    func shouldPushNewWebView(request: NSURLRequest) -> Bool {
        guard let url = request.URL else {
            return false
        }
        let isInitialRequest = url.absoluteString == self.rootURL.absoluteString
        let isSameHost = request.URL?.host == rootURL.host
        let isSamePath = request.URL?.path == rootURL.path
        let isFragmentOfThisPage = request.URL?.fragment != nil && isSameHost && isSamePath
        
        return !isInitialRequest && !isFragmentOfThisPage
    }
    
    func isLoginRequestRequest(request: NSURLRequest) -> Bool {
        var isLoginPath = false
        let isGroupDock = request.URL?.absoluteString.rangeOfString("://groupdock.com") != nil
        let isGroupDockOrgFinder = request.URL?.path?.rangeOfString("/a/") != nil
        let loginPaths = ["/login", "/elogin", "/sso/launch", "/organization_not_found"]
        if let path = request.URL?.path {
            isLoginPath = loginPaths.contains(path)
        }
        return isLoginPath || (isGroupDock && !isGroupDockOrgFinder)
    }
    
    // MARK: Cookies
    func saveCookiesFromResponse(urlResponse: NSURLResponse) {
        if let response: NSHTTPURLResponse = urlResponse as? NSHTTPURLResponse {
            guard let url = response.URL else {
                return
            }
            
            guard let headerFields = response.allHeaderFields as? [String:String] else {
                return
            }
            
            let cookies: [NSHTTPCookie] = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: url)
            for cookie in cookies {
                if cookie.name == authCookieName {
                    //keychain["app_auth_cookie"] = cookie.value
                }
            }
        }
    }
}
