import UIKit
import WebKit

protocol NeemanUIDelegate: NSObjectProtocol {
    func pushNewWebViewControllerWithURL(url: NSURL)
}

public class WebViewUIDelegate: NSObject, WKUIDelegate {
    
    weak var delegate: NeemanUIDelegate?

    public func webView(webView: WKWebView,
        createWebViewWithConfiguration configuration: WKWebViewConfiguration,
        forNavigationAction navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures) -> WKWebView? {
            
            if let url = navigationAction.request.URL {
                delegate?.pushNewWebViewControllerWithURL(url)
            }
            return nil
    }
    
    public func webViewDidClose(webView: WKWebView) {
        
    }
    
    public func webView(webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: () -> Void) {
            
            completionHandler()
    }
    
    public func webView(webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: (Bool) -> Void) {
            
    }
    
    public func webView(webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: (String?) -> Void) {
            
    }

}