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

    // MARK: Properties
    var navigationDelegate: WebViewNavigationDelegate?
    var uiDelegate: WebViewUIDelegate?
    
    /// The initial NSURL to display in the web view.
    public var rootURL: NSURL? {
        get {
            return NSURL(string: rootAbsoluteURLString ?? "")
        }
    }
    /// The initial URL to display in the web view. Set this in your storyboard in the "User Defined Runtime Attributes"
    public var rootURLString: String?
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
    public var webView: WKWebView! {
        didSet {
            print(webView)
        }
    }
    /**
     This is used mostly for injecting javascript and for sharing cookies between different WebViewControllers.
     */
    public var webViewConfig: WKWebViewConfiguration!
    static var processPool = WKProcessPool()
    
    //MARK: Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        setupNavigationBar()

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didLogout:",
            name: WebViewControllerDidLogout, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didLogin:",
            name: WebViewControllerDidLogin, object: nil)
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !hasLoadedContent {
            refresh(self)
        }
        
        webView.addObserver(self, forKeyPath: "title", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
    }

    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "loading")
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
            webView(webView, didChangeLoading: webView.loading)
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
        js.addScript("FastClick.js", config: webViewConfig, injectionTime: .AtDocumentEnd)
        js.addCSSScript(webViewConfig)
    }
    
    //MARK: NeemanNavigationDelegate
    public func pushNewWebViewControllerWithURL(url: NSURL) {
        let neemanStoryboard = UIStoryboard(name: "Neeman", bundle: NSBundle(forClass: WebViewController.self))
        if let webViewController: WebViewController = neemanStoryboard.instantiateViewControllerWithIdentifier(
            (NSStringFromClass(WebViewController.self) as NSString).pathExtension) as? WebViewController {
                
            let urlString = url.absoluteString
            webViewController.rootURLString = urlString
            navigationController?.pushViewController(webViewController, animated: true)
        }
    }

    // MARK: Authentication
    public func showLogin() {
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
