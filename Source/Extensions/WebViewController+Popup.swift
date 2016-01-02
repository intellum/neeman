import WebKit

extension WebViewController {
    func popupWebView(newWebView: WKWebView, withURL url:NSURL) {
        webViewPopup = newWebView
        guard let webViewPopup = webViewPopup else {
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.authenticateWithSettings(settings)
        webViewPopup.loadRequest(request)
        
        uiDelegatePopup = WebViewUIDelegate(settings: settings)
        uiDelegatePopup?.delegate = self
        webViewPopup.UIDelegate = uiDelegatePopup
        webViewPopup.allowsBackForwardNavigationGestures = true
        
        webViewPopup.configuration.addAuthenticationForURL(rootURL, settings: settings)
        
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