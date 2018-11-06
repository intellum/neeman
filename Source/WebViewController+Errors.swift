import UIKit

extension WebViewController {
    
    /**
      This can be overridden to display error messages received from the web view. 
     The default implementation sets the `navigationItem.prompt`
     
     - parameter message: The error message that should be presented. 
     */
    @objc open func showError(message: String?) {
        navigationItem.prompt = message
    }
    
    internal func showHTTPError(_ error: NetworkError) {
        guard hasLoadedContent else {
            showErrorViewController(withError: error)
            return
        }
        showError(message: error.description)
    }
    
    private func showErrorViewController(withError error: NetworkError) {
        errorViewController.view.removeFromSuperview()
        webView.scrollView.addSubview(errorViewController.view)
        errorViewController.error = error
        addChild(errorViewController)
    }
}
