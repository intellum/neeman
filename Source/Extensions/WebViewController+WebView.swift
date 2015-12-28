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
        
        self.uiDelegate = WebViewUIDelegate()
        webView.UIDelegate = self.uiDelegate
        webView.allowsBackForwardNavigationGestures = true
        
        addScriptsToConfiguration(webViewConfig)
        
        view.insertSubview(webView, atIndex: 0)
        webView.translatesAutoresizingMaskIntoConstraints = false
        autolayoutWebView()
    }
    
    func autolayoutWebView() {
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
        progressView?.setProgress(0, animated: false)
        
        webView.loadRequest(request)
    }

}
