import UIKit
import WebKit

public protocol NeemanNavigationDelegate: NSObjectProtocol {
    func pushNewWebViewControllerWithURL(url: NSURL)
    func shouldPreventPushOfNewWebView(request: NSURLRequest) -> Bool
    func shouldForcePushOfNewRequest(request: NSURLRequest) -> Bool
    func webView(webView: WKWebView, didFinishLoadingWithError error: NSError)
    func webView(webView: WKWebView, didFinishNavigationWithURL: NSURL?)
    func webView(webView: WKWebView, didReceiveServerRedirectToURL: NSURL?)
}

extension NeemanNavigationDelegate {
    public func pushNewWebViewControllerWithURL(url: NSURL) {}
    public func shouldPreventPushOfNewWebView(request: NSURLRequest) -> Bool { return false }
    public func shouldForcePushOfNewRequest(request: NSURLRequest) -> Bool { return false }
    public func webView(webView: WKWebView, didFinishLoadingWithError error: NSError) {}
    public func webView(webView: WKWebView, didFinishNavigationWithURL: NSURL?) {}
    public func webView(webView: WKWebView, didReceiveServerRedirectToURL: NSURL?) {}
}

public class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
    
    var rootURL: NSURL
    weak var delegate: NeemanNavigationDelegate?
    public var settings: Settings
    
    public init(rootURL: NSURL, delegate: NeemanNavigationDelegate?, settings: Settings) {
        self.rootURL = rootURL
        self.delegate = delegate
        self.settings = settings
    }
    
    public func webView(webView: WKWebView,
        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
        decisionHandler: (WKNavigationActionPolicy) -> Void) {
            
            var actionPolicy: WKNavigationActionPolicy = .Allow
            let shouldPush = shouldPushNewWebViewForRequest(navigationAction.request)

            let isLink = navigationAction.navigationType == .LinkActivated
            let shouldForcePush = delegate?.shouldForcePushOfNewRequest(navigationAction.request) ?? false
            if (isLink && shouldPush) || shouldForcePush {
                delegate?.pushNewWebViewControllerWithURL(navigationAction.request.URL!)
                actionPolicy = .Cancel
            }

            let actionString = (actionPolicy.rawValue == 1) ? "Allowed" : "Canceled"
            print("URL: " + (navigationAction.request.URL?.absoluteString)! + "\t\t\t- " + actionString)
            
            decisionHandler(actionPolicy)
    }
    
    public func webView(webView: WKWebView,
        didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation?) {
        delegate?.webView(webView, didReceiveServerRedirectToURL: webView.URL)
    }
    
    public func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation?) {
        delegate?.webView(webView, didFinishNavigationWithURL: webView.URL)
    }
    
    public func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation?, withError error: NSError) {
        delegate?.webView(webView, didFinishLoadingWithError: error)
    }
    
    // MARK: Should Push
    
    public func shouldPushNewWebViewForRequest(request: NSURLRequest) -> Bool {
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
