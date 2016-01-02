import WebKit

extension WebViewController {
    func popupWebView(newWebView: WKWebView, withURL url:NSURL) {
        webViewPopup = newWebView
        guard let webViewPopup = webViewPopup else {
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.authenticate()
        webViewPopup.loadRequest(request)
        
        uiDelegatePopup = WebViewUIDelegate()
        uiDelegatePopup?.delegate = self
        webViewPopup.UIDelegate = uiDelegatePopup
        webViewPopup.allowsBackForwardNavigationGestures = true
        
        webViewPopup.configuration.addAuthenticationForURL(rootURL)
        
        view.insertSubview(webViewPopup, aboveSubview: webView)
        webViewPopup.translatesAutoresizingMaskIntoConstraints = false
        webViewPopup.frame = view.bounds
        autolayoutWebView(webViewPopup)
        
        webViewObserver.startObservingWebView(webViewPopup)
    }
    
    func closeWebView(webView: WKWebView) {
        if let popupWebView = webViewPopup {
            webViewObserver.stopObservingWebView(popupWebView)
            popupWebView.removeFromSuperview()
            webViewPopup = nil
        }
        loadURL(rootURL)
    }
}