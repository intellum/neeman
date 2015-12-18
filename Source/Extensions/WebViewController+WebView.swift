import UIKit
import WebKit

extension WebViewController {
    func setupWebView() {
        webViewConfig = WKWebViewConfiguration()
        webViewConfig.processPool = WebViewController.processPool
        if #available(iOS 9.0, *) {
            webViewConfig.applicationNameForUserAgent = Settings.sharedInstance.appName
        }
        webView = WKWebView(frame: view.bounds, configuration: webViewConfig)
        if let url = rootURL {
            navigationDelegate = WebViewNavigationDelegate(rootURL: url, delegate: self)
            webView.navigationDelegate = navigationDelegate
        }
        
        webView.UIDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        addScriptsToConfiguration(webViewConfig)
        
        view.insertSubview(webView, atIndex: 0)
        webView.translatesAutoresizingMaskIntoConstraints = false
        autolayoutWebView()

        webView.addObserver(self, forKeyPath: "title", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
    }
    
    public func autolayoutWebView() {
        let views = ["webView":webView, "topLayoutGuide":self.topLayoutGuide] as [String: AnyObject]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[webView(>=0)]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[webView(>=0)]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    func loadURL(url: NSURL?) {
        guard let url = url else {
            showURLError()
            return
        }
        
        setErrorMessage(nil)
        hasLoadedContent = false
        
        let request = NSMutableURLRequest(URL: url)
        request.authenticate()
        
        webView.loadRequest(request)
    }

}
