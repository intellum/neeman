import WebKit

extension WebViewController: NeemanUIDelegate {
    
    /**
     Creates a web view for a popup window. The web view is added onto of the current one. 
     You should override this if you would like to implement something like tabs.
     
     - parameter newWebView: The new web view.
     - parameter url:        The URL to load.
     */
    open func popupWebView(_ newWebView: WKWebView, withURL url: URL) {
        webViewPopup = newWebView
        guard let webViewPopup = webViewPopup else {
            return
        }
        
        uiDelegatePopup = WebViewUIDelegate(settings: settings)
        uiDelegatePopup?.delegate = self
        webViewPopup.uiDelegate = uiDelegatePopup
        webViewPopup.allowsBackForwardNavigationGestures = true
        
        let popupViewController = UIViewController()
        popupNavController = UINavigationController(rootViewController: popupViewController)
        popupViewController.modalPresentationStyle = .fullScreen
        popupViewController.view.addSubview(webViewPopup)
        
        let barButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(self.didTapDoneButton(_:)))
        popupViewController.navigationItem.rightBarButtonItem = barButton

        webViewPopup.translatesAutoresizingMaskIntoConstraints = false
        webViewPopup.frame = view.bounds
        autolayoutWebView(webViewPopup)
        present(popupNavController!, animated: true, completion: nil)
        
        webViewObserver.startObservingWebView(webViewPopup)
        
        let request = NSMutableURLRequest(url: url)
        loadPopupRequest(request)
        
    }
    
    @IBAction open func unwindToParentWebView(_ segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Load a request in the popup web view.
     
     - parameter request: The request to load in the popup.
     */
    open func loadPopupRequest(_ request: NSMutableURLRequest) {
        _ = webViewPopup?.load(request as URLRequest)
    }
    
    /**
     The done button of the popup view controller was pressed.
     
     - parameter sender: The button that was tapped.
     */
    func didTapDoneButton(_ sender: AnyObject) {
        closeWebView(webView)
    }
    
    /**
     Close the popup webview.
     
     - parameter webView: The web view to close.
     */
    open func closeWebView(_ webView: WKWebView) {
        if let popupWebView = webViewPopup {
            webViewObserver.stopObservingWebView(popupWebView)
            dismiss(animated: true, completion: nil)
            webViewPopup = nil
            popupNavController = nil
        }
    }
}
