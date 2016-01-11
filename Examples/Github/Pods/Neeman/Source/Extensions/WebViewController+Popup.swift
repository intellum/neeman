import WebKit

extension WebViewController {
    public func popupWebView(newWebView: WKWebView, withURL url: NSURL) {
        webViewPopup = newWebView
        guard let webViewPopup = webViewPopup else {
            return
        }
        
        uiDelegatePopup = WebViewUIDelegate(settings: settings)
        uiDelegatePopup?.delegate = self
        webViewPopup.UIDelegate = uiDelegatePopup
        webViewPopup.allowsBackForwardNavigationGestures = true
        
        view.insertSubview(webViewPopup, aboveSubview: webView)
        webViewPopup.translatesAutoresizingMaskIntoConstraints = false
        webViewPopup.frame = view.bounds
        autolayoutWebView(webViewPopup)
        
        webViewObserver.startObservingWebView(webViewPopup)
        
        let request = NSMutableURLRequest(URL: url)
        loadPopupRequest(request)
        
    }
    
    public func loadPopupRequest(request: NSMutableURLRequest) {
        webViewPopup?.loadRequest(request)
    }
    
    public func closeWebView(webView: WKWebView) {
        if let popupWebView = webViewPopup {
            webViewObserver.stopObservingWebView(popupWebView)
            popupWebView.removeFromSuperview()
            webViewPopup = nil
        }
        loadURL(rootURL)
    }
}
