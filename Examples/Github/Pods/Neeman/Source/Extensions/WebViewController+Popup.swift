import WebKit

extension WebViewController {
    
    /**
     Creates a web view for a popup window. The web view is added onto of the current one. 
     You should override this if you would like to implement something like tabs.
     
     - parameter newWebView: The new web view.
     - parameter url:        The URL to load.
     */
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
    
    /**
     Load a request in the popup web view.
     
     - parameter request: The request to load in the popup.
     */
    public func loadPopupRequest(request: NSMutableURLRequest) {
        webViewPopup?.loadRequest(request)
    }
    
    /**
     Close the popup webview.
     
     - parameter webView: The web view to close.
     */
    public func closeWebView(webView: WKWebView) {
        if let popupWebView = webViewPopup {
            webViewObserver.stopObservingWebView(popupWebView)
            popupWebView.removeFromSuperview()
            webViewPopup = nil
        }
        loadURL(rootURL)
    }
}
