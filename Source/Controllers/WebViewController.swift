import UIKit
import WebKit

/**
  WebViewController displays the contents of a URL and pushes a new instance of itself once the 
  user clicks on a link that causes an URL change. It also provides support for authentication. 
  It makes injecting Javascript into your webapp easy.
*/
public class WebViewController: UIViewController, NeemanUIDelegate, NeemanNavigationDelegate {
    // MARK: Constants
    let keychain = Settings.sharedInstance.keychain

    // Outlets
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var progressView: UIProgressView?

    // MARK: Properties
    var navigationDelegate: WebViewNavigationDelegate?
    var navigationDelegatePopup: WebViewNavigationDelegate?
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
    
    /**
     This is used mostly for injecting javascript and for sharing cookies between different WebViewControllers.
     */
    public var webViewConfig: WKWebViewConfiguration!
    static var processPool = WKProcessPool()
    
    //MARK: Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = true

        setupWebView()
        setupNavigationBar()
        setupActivityIndicator()
        setupProgressView()

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didLogout:",
            name: WebViewControllerDidLogout, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didLogin:",
            name: WebViewControllerDidLogin, object: nil)
    }
    
    deinit {
        webViewPopup?.removeObserver(self, forKeyPath: "loading")
        webViewPopup?.removeObserver(self, forKeyPath: "estimatedProgress")

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !hasLoadedContent {
            refresh(self)
        }
        
        webView.addObserver(self, forKeyPath: "title", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
    }

    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "loading")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
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
    }

    // MARK: Notification Handlers
    public func didLogout(notification: NSNotification) {
        self.hasLoadedContent = false
        navigationController?.popToRootViewControllerAnimated(false)
    }
    
    public func didLogin(notification: NSNotification) {
        loadURL(rootURL)
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
            webView(webView, didChangeTitle: webView.title)
        case "loading":
            if let currentWebView = object as? WKWebView {
                webView(currentWebView, didChangeLoading: webView.loading)
            }
        case "estimatedProgress":
            if let currentWebView = object as? WKWebView {
                webView(currentWebView, didChangeEstimatedProgress: currentWebView.estimatedProgress)
            }
        default:
            break
        }
    }
    
    /**
     Called when the webView updates the value of its title property.
     - Parameter webView: The instance of WKWebView that updated its title property.
     - Parameter loading: The value that the WKWebView updated its title property to.
     */
    public func webView(webView: WKWebView, didChangeTitle title: String?) {
        navigationItem.title = title?.uppercaseString
    }
    
    //MARK: Javascript
    
    func addScriptsToConfiguration(config: WKWebViewConfiguration) {
        let js = Javascript()
        js.addScript("AtDocumentStart.js", config: webViewConfig, injectionTime: .AtDocumentStart)
        js.addScript("AtDocumentEnd.js", config: webViewConfig, injectionTime: .AtDocumentEnd)
//        js.addScript("FastClick.js", config: webViewConfig, injectionTime: .AtDocumentEnd)
        js.addCSSScript(webViewConfig)
        
        addAuthentication(webViewConfig)
    }

    func addAuthentication(config: WKWebViewConfiguration) {
        let js = Javascript()
        if let cookie = authCookie() {
            js.setCookie(cookie, config: webViewConfig)
        }
    }
    
    func authCookie() -> NSHTTPCookie? {
        guard let authCookieName = Settings.sharedInstance.authCookieName else {
            return nil
        }
        let cookieStore = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let url = self.rootURL {
            let cookies = cookieStore.cookiesForURL(url)
            if let authCookies = cookies?.filter({$0.name == authCookieName}),
                authCookie = authCookies.first {
                    return authCookie
            }
        }
        
        if let authToken = Settings.sharedInstance.authToken,
            url = rootURL {
            let properties: [String: AnyObject] = [
                NSHTTPCookieName:authCookieName,
                NSHTTPCookieValue:authToken,
                NSHTTPCookieDomain:url.host!,
                NSHTTPCookieOriginURL:url.host!,
                NSHTTPCookiePath:"/"
            ]
            
            if let cookie = NSHTTPCookie(properties: properties) {
                return cookie
            }
        }
        return nil
    }

    //MARK: NeemanUIDelegate
    func openURL(url:NSURL, inNewWebView newWebView: WKWebView) {
        webViewPopup = newWebView
        guard let webViewPopup = webViewPopup else {
            return
        }

        let request = NSMutableURLRequest(URL: url)
        request.authenticate()
        webViewPopup.loadRequest(request)

        uiDelegatePopup = WebViewUIDelegate()
        uiDelegatePopup?.delegate = self
        webViewPopup.UIDelegate = uiDelegatePopup
        webViewPopup.allowsBackForwardNavigationGestures = true
        
        addAuthentication(webViewPopup.configuration)
        
        view.insertSubview(webViewPopup, aboveSubview: webView)
        webViewPopup.translatesAutoresizingMaskIntoConstraints = false
        webViewPopup.frame = view.bounds
        autolayoutWebView(webViewPopup)

        webViewPopup.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        webViewPopup.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
    }
    
    func closeWebView(webView: WKWebView) {
        webViewPopup?.removeObserver(self, forKeyPath: "loading")
        webViewPopup?.removeObserver(self, forKeyPath: "estimatedProgress")
        webViewPopup?.removeFromSuperview()
        webViewPopup = nil
        loadURL(rootURL)
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
        print("Impement showLogin() to display your custom login UI.")
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

}

// MARK: Notifications

/** Posted when the user logged out though the WebViewController.didTapLogout:sender method.
*/
public let WebViewControllerDidLogout = "WebViewControllerDidLogout"

/** Posting this will cause the didLogin(_:) method to be called. You can post this from your custom native authentication code.
*/
public let WebViewControllerDidLogin = "WebViewControllerDidLogin"
