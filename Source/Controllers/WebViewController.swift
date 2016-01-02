import UIKit
import WebKit

/**
  WebViewController displays the contents of a URL and pushes a new instance of itself once the 
  user clicks on a link that causes an URL change. It also provides support for authentication. 
  It makes injecting Javascript into your webapp easy.
*/
public class WebViewController: UIViewController, WebViewObserverDelegate, NeemanUIDelegate, NeemanNavigationDelegate, WKScriptMessageHandler {
    // MARK: Constants
    let keychain = Settings.sharedInstance.keychain

    // Outlets
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var progressView: UIProgressView?

    // MARK: Properties
    var navigationDelegate: WebViewNavigationDelegate?
    var uiDelegate: WebViewUIDelegate?
    var uiDelegatePopup: WebViewUIDelegate?
    
    /// The initial NSURL to display in the web view.
    public var rootURL: NSURL? {
        get {
            return NSURL(string: rootAbsoluteURLString ?? "")
        }
    }
    /// The initial URL to display in the web view. Set this in your storyboard in the "User Defined Runtime Attributes"
    @IBInspectable public var rootURLString: String?
    var rootAbsoluteURLString: String? {
        get {
            if rootURLString!.rangeOfString("://") == nil {
                return Settings.sharedInstance.baseURL + rootURLString!
            }
            return rootURLString
        }
    }
    
    /** A UIRefreshControl is automatically added to the WKWebView.
        When you pull down your webView the page will be refreshed.
    */
    public var refreshControl: UIRefreshControl!
    var hasLoadedContent: Bool = false

    /**
     The WKWebView in which the content of the URL defined in rootURLString will be dispayed.
     */
    public var webView: WKWebView!
    var webViewPopup: WKWebView?
    
    var webViewObserver: WebViewObserver = WebViewObserver()
    
    static var processPool = WKProcessPool()
    
    //MARK: Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        setupNavigationBar()
        setupActivityIndicator()
        setupProgressView()
        addObservers()
        webViewObserver.delegate = self
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didLogout:",
            name: WebViewControllerDidLogout, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didLogin:",
            name: WebViewControllerDidLogin, object: nil)
    }
    
    deinit {
        webViewObserver.stopObservingWebView(webViewPopup)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !hasLoadedContent {
            loadURL(rootURL)
        }
        webViewObserver.startObservingWebView(webView)
    }

    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        webViewObserver.stopObservingWebView(webView)
    }

    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.webViewPopup?.scrollView.contentInset = self.webView.scrollView.contentInset
        self.webViewPopup?.scrollView.scrollIndicatorInsets = self.webView.scrollView.scrollIndicatorInsets
    }
    
    // MARK: Actions
    /**
    This performs some clean up of cookies, authentication and sends a notification named WebViewControllerDidLogout.
    */
    public func didTapLogout(sender: AnyObject) {
        Settings.sharedInstance.authToken = nil

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
        navigationController?.popToRootViewControllerAnimated(false)
    }

    // MARK: Notification Handlers
    public func didLogout(notification: NSNotification) {
        self.hasLoadedContent = false
    }
    
    public func didLogin(notification: NSNotification) {
        loadURL(rootURL)
    }
    
    // MARK: Title and Loading
    
    /**
     Called when the webView updates the value of its title property.
     - Parameter webView: The instance of WKWebView that updated its title property.
     - Parameter loading: The value that the WKWebView updated its title property to.
     */
    public func webView(webView: WKWebView, didChangeTitle title: String?) {
        navigationItem.title = title
    }

    //MARK: NeemanNavigationDelegate
    public func pushNewWebViewControllerWithURL(url: NSURL) {
        print("Pushing: \(url.absoluteString)")
        let neemanStoryboard = UIStoryboard(name: "Neeman", bundle: NSBundle(forClass: WebViewController.self))
        if let webViewController: WebViewController = neemanStoryboard.instantiateViewControllerWithIdentifier(
            (NSStringFromClass(WebViewController.self) as NSString).pathExtension) as? WebViewController {
                
            let urlString = url.absoluteString
            webViewController.rootURLString = urlString
            navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
    public func shouldPreventPushOfNewWebView(request: NSURLRequest) -> Bool {
        return false
    }
    
    public func loginPaths() -> [String]? {
        return nil
    }

    public func isLoginRequest(request: NSURLRequest) -> Bool {
        return false
    }
    
    // MARK: Authentication
    public func showLogin() {
        print("Implement showLogin() to display your custom login UI.")
    }

    func clearCookies() {
        let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = cookieStorage.cookies {
            for cookie in cookies {
                cookieStorage.deleteCookie(cookie)
            }
        }
    }
    
    func webView(webView: WKWebView, didFinishLoadingWithError error: NSError) {
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

    public func userContentController(userContentController: WKUserContentController,
        didReceiveScriptMessage message: WKScriptMessage) {
    }
}

// MARK: Notifications

/** Posted when the user logged out though the WebViewController.didTapLogout:sender method.
*/
public let WebViewControllerDidLogout = "WebViewControllerDidLogout"

/** Posting this will cause the didLogin(_:) method to be called. You can post this from your custom native authentication code.
*/
public let WebViewControllerDidLogin = "WebViewControllerDidLogin"
