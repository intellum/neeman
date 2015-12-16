import UIKit
import WebKit
import KeychainAccess

let WebViewControllerDidLogout = "WebViewControllerDidLogout"
let WebViewControllerDidLogin = "WebViewControllerDidLogin"

public class WebViewController: UIViewController, WKUIDelegate, NeemanWebViewController {
    // MARK: Constants
    let keychain = Settings.sharedInstance.keychain
    let authCookieName = Settings.sharedInstance.authCookieName

    // MARK: Properties
    var navigationDelegate: WebViewNavigationDelegate?
    var rootURL: NSURL? {
        get {
            return NSURL(string: rootAbsoluteURLString ?? "")
        }
    }
    public var rootAbsoluteURLString: String? {
        get {
            if rootURLString!.rangeOfString("://") == nil {
                return Settings.sharedInstance.baseURL + rootURLString!
            }
            return rootURLString
        }
    }
    public var rootURLString: String?
    
    var activityIndicator: UIActivityIndicatorView = {
        let style: UIActivityIndicatorViewStyle = Settings.sharedInstance.isNavbarDark ? .White : .Gray
        return UIActivityIndicatorView(activityIndicatorStyle: style)
    }()
    public var refreshControl: UIRefreshControl!
    var hasLoadedContent: Bool = false

    public var webView: WKWebView!
    public var webViewConfig: WKWebViewConfiguration!
    static var processPool = WKProcessPool()
    
    //MARK: Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        setupNavigationBar()

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didLogout:",
            name: WebViewControllerDidLogout,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didLogin:",
            name: WebViewControllerDidLogin,
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    public func setTitle() {
        navigationItem.title = webView.title?.uppercaseString
    }

    public func didTapLogout() {
        do {
            try keychain.remove("app_auth_cookie")
        } catch let error {
            print(error)
        }

        showLogin()
        clearCookies()
        WebViewController.processPool = WKProcessPool()
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        if #available(iOS 9.0, *) {
            WKWebsiteDataStore.defaultDataStore().removeDataOfTypes(
                WKWebsiteDataStore.allWebsiteDataTypes(),
                modifiedSince: NSDate(timeIntervalSince1970: 0),
                completionHandler: { () -> Void in
                
            })
        }
        NSNotificationCenter.defaultCenter().postNotificationName(WebViewControllerDidLogout, object: self)
    }
    
    func clearCookies() {
        let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = cookieStorage.cookies {
            for cookie in cookies {
                cookieStorage.deleteCookie(cookie)
            }
        }
    }
    
    public func didLogout(notification: NSNotification) {
        self.hasLoadedContent = false
        navigationController?.popToRootViewControllerAnimated(false)
    }

    public func didLogin(notification: NSNotification) {
        loadURL(rootURL)
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(self, forKeyPath: "title", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)

        if !hasLoadedContent {
            refresh(self)
        }

    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "loading")
    }
    
    // MARK: Title and Loading
    override public func observeValueForKeyPath(keyPathOpt: String?,
        ofObject object: AnyObject?,
        change: [String : AnyObject]?,
        context: UnsafeMutablePointer<Void>) {
            
        guard let keyPath = keyPathOpt else {
            super.observeValueForKeyPath(keyPathOpt, ofObject: object, change: change, context: context)
            return
        }
        
        switch keyPath {
        case "title":
            setTitle()
        case "loading":
            loadingDidChange()
        default:
            break
        }
    }
    
    //MARK: Javascript
    
    func addScriptsToConfiguration(config: WKWebViewConfiguration) {
        let js = Javascript()
        js.addScript("AtDocumentStart.js", config: webViewConfig, injectionTime: .AtDocumentStart)
        js.addScript("AtDocumentEnd.js", config: webViewConfig, injectionTime: .AtDocumentEnd)
        js.addScript("FastClick.js", config: webViewConfig, injectionTime: .AtDocumentEnd)
        js.addCSSScript(webViewConfig)
    }
    
    //MARK: NeemanWebViewController
    func pushNewWebViewControllerWithURL(url: NSURL) {
        let neemanStoryboard = UIStoryboard(name: "Neeman", bundle: NSBundle(forClass: WebViewController.self))
        if let webViewController: WebViewController = neemanStoryboard.instantiateViewControllerWithIdentifier(
            (NSStringFromClass(WebViewController.self) as NSString).pathExtension) as? WebViewController {
                
            let urlString = url.absoluteString
            webViewController.rootURLString = urlString
            navigationController?.pushViewController(webViewController, animated: true)
        }
    }

    func showLogin() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let storyboard = UIStoryboard(name: "Neeman", bundle: NSBundle(forClass: WebViewController.self))
            if let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginNavigationController") as? UINavigationController {
                loginVC.setNavigationBarHidden(true, animated: false)
                if let viewController = self.view.window?.rootViewController {
                    if viewController.presentedViewController == nil {
                        viewController.presentViewController(loginVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    public func webViewDidFinishLoadingWithError(error: NSError) {
        var message: String?

        switch error.code {
        case NSURLErrorNotConnectedToInternet:
            message = error.localizedDescription
        default:
            message = nil
        }
        
        if #available(iOS 9.0, *) {
            if error.code == NSURLErrorAppTransportSecurityRequiresSecureConnection {
                showSSLError()
            }
        }
        
        if let message = message {
            setErrorMessage(message)
        }
    }
    
    // MARK: WKUIDelegate
    public func webView(webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: () -> Void) {
            
        completionHandler()
    }
    
    // MARK: Overridable
    
    public func setContentInset() {
    }
}
