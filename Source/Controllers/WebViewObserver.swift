import WebKit

protocol WebViewObserverDelegate: NSObjectProtocol {
    func webView(webView: WKWebView, didChangeTitle title: String?)
    func webView(webView: WKWebView, didChangeLoading loading: Bool)
    func webView(webView: WKWebView, didChangeEstimatedProgress estimatedProgress: Double)
}

class WebViewObserver: NSObject {
    var delegate: WebViewObserverDelegate?
    
    func startObservingWebView(webView: WKWebView?) {
        webView?.addObserver(self, forKeyPath: "title", options: .New, context: nil)
        webView?.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
    }
    
    func stopObservingWebView(webView: WKWebView?) {
        webView?.removeObserver(self, forKeyPath: "title")
        webView?.removeObserver(self, forKeyPath: "loading")
        webView?.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
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
