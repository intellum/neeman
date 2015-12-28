import UIKit
import WebKit

protocol NeemanNavigationDelegate: NSObjectProtocol {
    func webView(webView: WKWebView, didFinishLoadingWithError error: NSError)
    func showLogin()
    func pushNewWebViewControllerWithURL(url: NSURL)
    func shouldPreventPushOfNewWebView(request: NSURLRequest) -> Bool
}

public class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
    
    let keychain = Settings.sharedInstance.keychain
    let authCookieName = Settings.sharedInstance.authCookieName
    var rootURL: NSURL
    weak var delegate: NeemanNavigationDelegate?
    
    init(rootURL: NSURL, delegate: NeemanNavigationDelegate?) {
        self.rootURL = rootURL
        self.delegate = delegate
    }
    
    public func webView(webView: WKWebView,
        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
        decisionHandler: (WKNavigationActionPolicy) -> Void) {
            
            var actionPolicy: WKNavigationActionPolicy = .Allow
            let shouldPush = shouldPushNewWebView(navigationAction.request)
            let isLink = navigationAction.navigationType == .LinkActivated
                || navigationAction.navigationType == .Other
            if isLink
                && shouldPush {
                delegate?.pushNewWebViewControllerWithURL(navigationAction.request.URL!)
                actionPolicy = .Cancel
            } else if isLoginRequestRequest(navigationAction.request) {
                if let _ = Settings.sharedInstance.authCookieName {
                    actionPolicy = .Cancel
                    delegate?.showLogin()
                }
            }
            
            let actionString = (actionPolicy.rawValue == 1) ? "Allowed" : "Canceled"
            print("URL: " + (navigationAction.request.URL?.absoluteString)! + "\t\t\t- " + actionString)
            
            decisionHandler(actionPolicy)
    }
    
    public func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
    }
    
    public func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation?, withError error: NSError) {
        delegate?.webView(webView, didFinishLoadingWithError: error)
    }
    
    // MARK: Should Push
    
    public func shouldPushNewWebView(request: NSURLRequest) -> Bool {
        guard let url = request.URL else {
            return false
        }
        if let delegate = delegate {
            if delegate.shouldPreventPushOfNewWebView(request) {
                return false
            }
        }

        let isInitialRequest = url.absoluteString == self.rootURL.absoluteString
        let isSameHost = request.URL?.host == rootURL.host
        let isSamePath = request.URL?.path == rootURL.path
        let isFragmentOfThisPage = request.URL?.fragment != nil && isSameHost && isSamePath
        
        return !isInitialRequest && !isFragmentOfThisPage
    }
    
    func isLoginRequestRequest(request: NSURLRequest) -> Bool {
        var isLoginPath = false
        let isGroupdock = request.URL?.absoluteString.rangeOfString("groupdock.com") != nil
        let isGroupdockOrgFinder = isGroupdock && request.URL?.path?.rangeOfString("/a/") != nil
        let loginPaths = ["/login", "/elogin", "/sso/launch", "/organization_not_found"]
        if let path = request.URL?.path {
            isLoginPath = loginPaths.contains(path)
        }
        return isLoginPath || (isGroupdock && !isGroupdockOrgFinder)
    }
}
