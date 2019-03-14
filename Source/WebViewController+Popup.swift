import WebKit

extension WebViewController: NeemanUIDelegate {
        
    @IBAction open func unwindToParentWebView(_ segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Load a request in the popup web view.
     
     - parameter request: The request to load in the popup.
     */
    @objc open func loadPopupRequest(_ request: NSMutableURLRequest) {
        _ = webViewPopup?.load(request as URLRequest)
    }
    
    /**
     The done button of the popup view controller was pressed.
     
     - parameter sender: The button that was tapped.
     */
    @objc open func didTapDoneButton(_ sender: AnyObject) {
        closeWebView(webView)
    }
    
    /**
     Close the popup webview.
     
     - parameter webView: The web view to close.
     */
    @objc open func closeWebView(_ webView: WKWebView) {
        if let popupWebView = webViewPopup {
            webViewObserver.stopObservingWebView(popupWebView)
            webViewPopup = nil
            popupNavController = nil
        }
        dismiss(animated: true)
    }
    
    /**
     Presents the alert controller in the windows root view controller.
     
     - parameter alert: The alert controller to present.
     */
    open func presentAlertController(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
}
