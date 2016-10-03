import WebKit

extension WebViewController {
    /**
     Sets up the main web view.
     */
    public func setupWebView() {
        let webViewConfig = WKWebViewConfiguration(settings: settings)
        
        webView = WKWebView(frame: view.bounds, configuration: webViewConfig).setupForNeeman()
        if let url = rootURL {
            if navigationDelegate == nil {
                navigationDelegate = WebViewNavigationDelegate(rootURL: url, delegate: self, settings: settings)
            }
            webView.navigationDelegate = navigationDelegate
        }
        
        uiDelegate = WebViewUIDelegate(settings: settings)
        uiDelegate?.delegate = self
        webView.uiDelegate = uiDelegate
        
        view.insertSubview(webView, at: 0)
        autolayoutWebView(webView)
    }
    
    /**
     Autolayout the main web view.
     
     - parameter webView: The web view to layout.
     */
    public func autolayoutWebView(_ webView: WKWebView) {
        webView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["webView":webView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView(>=0)]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView(>=0)]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
 
}
