import WebKit

extension WebViewController: NeemanUIDelegate {
    
    /**
     Creates a web view for a popup window. The web view is added onto of the current one. 
     You should override this if you would like to implement something like tabs.
     
     - parameter newWebView: The new web view.
     - parameter url:        The URL to load.
     */
    public func popupWebView(_ newWebView: WKWebView, withURL url: URL) {
        webViewPopup = newWebView
        guard let webViewPopup = webViewPopup else {
            return
        }
        
        uiDelegatePopup = WebViewUIDelegate(settings: settings)
        uiDelegatePopup?.delegate = self
        webViewPopup.uiDelegate = uiDelegatePopup
        webViewPopup.allowsBackForwardNavigationGestures = true
        
        view.insertSubview(webViewPopup, aboveSubview: webView)
        webViewPopup.translatesAutoresizingMaskIntoConstraints = false
        webViewPopup.frame = view.bounds
        autolayoutWebView(webViewPopup)
        
        webViewObserver.startObservingWebView(webViewPopup)
        
        let request = NSMutableURLRequest(url: url)
        loadPopupRequest(request)
        
    }
    
    /**
     Load a request in the popup web view.
     
     - parameter request: The request to load in the popup.
     */
    public func loadPopupRequest(_ request: NSMutableURLRequest) {
        webViewPopup?.load(request as URLRequest)
    }
    
    /**
     Close the popup webview.
     
     - parameter webView: The web view to close.
     */
    public func closeWebView(_ webView: WKWebView) {
        if let popupWebView = webViewPopup {
            webViewObserver.stopObservingWebView(popupWebView)
            popupWebView.removeFromSuperview()
            webViewPopup = nil
        }
        loadURL(rootURL)
    }
}
