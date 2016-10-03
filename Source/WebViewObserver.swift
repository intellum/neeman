import WebKit

/**
 *  Implement this to recieve changes to certain web view properties.
 */
protocol WebViewObserverDelegate: NSObjectProtocol {
    func webView(_ webView: WKWebView, didChangeTitle title: String?)
    func webView(_ webView: WKWebView, didChangeLoading loading: Bool)
    func webView(_ webView: WKWebView, didChangeEstimatedProgress estimatedProgress: Double)
}

/// Observes properties of a web view such as loading, estimatedProgress and its title.
class WebViewObserver: NSObject {
    weak var delegate: WebViewObserverDelegate?
    
    /**
     Starts observing (KVO) some properties of the supplied web view.
     
     - parameter webView: The web view to observe.
     */
    func startObservingWebView(_ webView: WKWebView?) {
        webView?.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        webView?.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    /**
     Stop observing (KVO) some properties of the supplied web view.
     
     - parameter webView: The web view to stop observing.
     */
    func stopObservingWebView(_ webView: WKWebView?) {
        webView?.removeObserver(self, forKeyPath: "title")
        webView?.removeObserver(self, forKeyPath: "loading")
        webView?.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    /**
     Handle an observed change in a key path.
     
     - parameter keyPathOpt: The key path, relative to object, to the value that has changed.
     - parameter object:     The source object of the key path keyPath.
     - parameter change:     A dictionary that describes the changes that have been made to the value of the property at the key path.
     - parameter context:    The value that was provided when the receiver was registered to receive key-value observation notifications.
     */
    internal override func observeValue(forKeyPath keyPathOpt: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?) {
            
            guard let keyPath = keyPathOpt else {
                super.observeValue(forKeyPath: keyPathOpt, of: object, change: change, context: context)
                return
            }
            guard let webView = object as? WKWebView else {
                return
            }
            
            switch keyPath {
            case "title":
                delegate?.webView(webView, didChangeTitle: webView.title)
            case "loading":
                if let currentWebView = object as? WKWebView {
                    delegate?.webView(currentWebView, didChangeLoading: webView.isLoading)
                }
            case "estimatedProgress":
                if let currentWebView = object as? WKWebView {
                    delegate?.webView(currentWebView, didChangeEstimatedProgress: currentWebView.estimatedProgress)
                }
            default:
                break
            }
    }
}
