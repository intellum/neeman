import UIKit
import WebKit

extension WebViewController {
    public func setupWebView() {
        let webViewConfig = WKWebViewConfiguration().setupWithSettings(settings)
        
        webView = WKWebView(frame: view.bounds, configuration: webViewConfig).setupForNeeman()
        if let url = rootURL {
            if navigationDelegate == nil {
                navigationDelegate = WebViewNavigationDelegate(rootURL: url, delegate: self, settings: settings)
            }
            webView.navigationDelegate = navigationDelegate
        }
        
        self.uiDelegate = WebViewUIDelegate(settings: settings)
        self.uiDelegate?.delegate = self
        webView.UIDelegate = self.uiDelegate
        
        view.insertSubview(webView, atIndex: 0)
        webView.translatesAutoresizingMaskIntoConstraints = false
        autolayoutWebView(webView)
    }
    
    public func autolayoutWebView(webView: WKWebView) {
        let views = ["webView":webView] as [String: AnyObject]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[webView(>=0)]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[webView(>=0)]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
 
}
