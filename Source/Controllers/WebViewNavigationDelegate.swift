import UIKit
import WebKit

public protocol NeemanNavigationDelegate: NSObjectProtocol {
    func webView(webView: WKWebView, didFinishLoadingWithError error: NSError)
    func pushNewWebViewControllerWithURL(url: NSURL)
    func shouldPreventPushOfNewWebView(request: NSURLRequest) -> Bool
}

public class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
    
    var rootURL: NSURL
    var name: String?
    weak var delegate: NeemanNavigationDelegate?
    public var settings: Settings
    
    public init(rootURL: NSURL, delegate: NeemanNavigationDelegate?, settings: Settings) {
        self.rootURL = rootURL
        self.delegate = delegate
        self.name = nil
        self.settings = settings
    }
    
    public func webView(webView: WKWebView,
        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
        decisionHandler: (WKNavigationActionPolicy) -> Void) {
            
            var actionPolicy: WKNavigationActionPolicy = .Allow
            let shouldPush = shouldPushNewWebView(navigationAction.request)

            let isLink = navigationAction.navigationType == .LinkActivated
            if isLink && shouldPush {
                delegate?.pushNewWebViewControllerWithURL(navigationAction.request.URL!)
                actionPolicy = .Cancel
            }
            
            let actionString = (actionPolicy.rawValue == 1) ? "Allowed" : "Canceled"
            var nameString = ""
            if let _ = name {
                nameString = "(\(name!))"
            }
            print("URL\(nameString): " + (navigationAction.request.URL?.absoluteString)! + "\t\t\t- " + actionString)
            
            decisionHandler(actionPolicy)
    }
    
    public func webView(webView: WKWebView,
        didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("Redirecting")
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
}
