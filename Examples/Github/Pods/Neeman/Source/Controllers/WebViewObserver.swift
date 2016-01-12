import WebKit

/**
 *  Implement this to recieve changes to certain web view properties.
 */
protocol WebViewObserverDelegate: NSObjectProtocol {
    func webView(webView: WKWebView, didChangeTitle title: String?)
    func webView(webView: WKWebView, didChangeLoading loading: Bool)
    func webView(webView: WKWebView, didChangeEstimatedProgress estimatedProgress: Double)
}

/// Observes properties of a web view such as loading, estimatedProgress and its title.
class WebViewObserver: NSObject {
    weak var delegate: WebViewObserverDelegate?
    
    /**
     Starts observing (KVO) some properties of the supplied web view.
     
     - parameter webView: The web view to observe.
     */
    func startObservingWebView(webView: WKWebView?) {
        webView?.addObserver(self, forKeyPath: "title", options: .New, context: nil)
        webView?.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
    }
    
    /**
     Stop observing (KVO) some properties of the supplied web view.
     
     - parameter webView: The web view to stop observing.
     */
    func stopObservingWebView(webView: WKWebView?) {
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
    internal override func observeValueForKeyPath(keyPathOpt: String?,
        ofObject object: AnyObject?,
        change: [String : AnyObject]?,
        context: UnsafeMutablePointer<Void>) {
            
            guard let keyPath = keyPathOpt else {
                super.observeValueForKeyPath(keyPathOpt, ofObject: object, change: change, context: context)
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
                    delegate?.webView(currentWebView, didChangeLoading: webView.loading)
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
