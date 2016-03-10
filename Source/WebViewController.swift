import UIKit
import WebKit

/**
  WebViewController displays the contents of a URL and pushes a new instance of itself once the 
  user clicks on a link that causes an URL change. It also provides support for authentication. 
  It makes injecting Javascript into your webapp easy.
*/
public class WebViewController: UIViewController,
                                WebViewObserverDelegate,
                                NeemanUIDelegate,
                                NeemanNavigationDelegate,
                                WKScriptMessageHandler {
    // Outlets
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var progressView: UIProgressView?
    @IBOutlet var errorViewController: ErrorViewController?

    // MARK: Properties
    
    /// The settings to set the web view up with.
    public var settings: Settings = Settings()

    /// The navigation delegate that will receive changes in loading, estimated progress and further navigation.
    public var navigationDelegate: WebViewNavigationDelegate?
    /// The UI delegate that allows us to implement our own code to handle window.open(), alert(), confirm() and prompt().
    public var uiDelegate: WebViewUIDelegate?
    /// This is a popup window that is opened when javascript code calles window.open().
    var uiDelegatePopup: WebViewUIDelegate?
    
    /// The initial NSURL that the web view is loading. Use URLString to set the URL.
    public var rootURL: NSURL? {
        get {
            return NSURL(string: rootAbsoluteURLString ?? "")
        }
    }
    
    /** The initial URL to display in the web view. Set this in your storyboard in the "User Defined Runtime Attributes"
    You can set baseURL in Settings if you would like to use relative URLs instead.
     */
    @IBInspectable public var URLString: String?
    
    /** If URLString is not an absolute URL and if you have set the baseURL in Settings
     then this returns the absolute URL by combining the two.
     */
    var rootAbsoluteURLString: String? {
        get {
            if let urlString = URLString where !urlString.containsString("://") {
                return settings.baseURL + urlString
            }
            return URLString
        }
    }
    
    /** A UIRefreshControl is automatically added to the WKWebView.
        When you pull down your webView the page will be refreshed.
    */
    public var refreshControl: UIRefreshControl?
    
    /** This is set once the web view has successfully loaded. If for some reason the page doesn't load
        then we know know when we return we should try again.
     */
    public internal(set) var hasLoadedContent: Bool = false

    /**
     The WKWebView in which the content of the URL defined in URLString will be dispayed.
     */
    public var webView: WKWebView!
    
    /// A web view that is used to display a window that was opened with window.open().
    public var webViewPopup: WKWebView?
    
    /// Observes properties of a web view such as loading, estimatedProgress and its title.
    var webViewObserver: WebViewObserver = WebViewObserver()
    
    //MARK: Lifecycle
    
    /**
    Setup the web view, the refresh controll, the activity indicator, progress view and observers.
    */
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        setupRefreshControl()
        setupActivityIndicator()
        setupProgressView()
        addObservers()
        webViewObserver.delegate = self
        loadURL(rootURL)
    }
    
    /**
     Setup the notification handlers and KVO.
     */
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didLogout:", name: WebViewControllerDidLogout, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didLogin:", name: WebViewControllerDidLogin, object: nil)
        webViewObserver.startObservingWebView(webView)
    }
    
    /**
     Stop observing notifications and KVO.
     */
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        webViewObserver.stopObservingWebView(webViewPopup)
        webViewObserver.stopObservingWebView(webView)
    }

    /**
     In here we check to see if we have previously loaded a page successfully. If not we reload the root URL.
     
     - parameter animated: Was the appearence animated.
     */
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !hasLoadedContent && !animated {
            loadURL(rootURL)
        }
    }

    /**
     Since iOS only automatically adjusts scroll view insets for the main web view 
     we have to do it ourselves for the popup web view.
     */
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        webViewPopup?.scrollView.contentInset = webView.scrollView.contentInset
        webViewPopup?.scrollView.scrollIndicatorInsets = webView.scrollView.scrollIndicatorInsets
    }
    
    // MARK: Notification Handlers
    
    /**
    In here we set hasLoadedContent so that we reload the page after returning back.
    
    - parameter notification: The notification received.
    */
    public func didLogout(notification: NSNotification) {
        hasLoadedContent = false
    }
    
    /**
     This forces an imidiate reload of the page using the rootURL. You can override this method if you 
     would prefer instead just to call any of the web view's methods to reload.
     
     - parameter notification: The notification received.
     */
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

    /**
    Pushes a new web view onto the navigation stack.
    
    - parameter url: The URL to load in the web view.
    */
    public func pushNewWebViewControllerWithURL(url: NSURL) {
        print("Pushing: \(url.absoluteString)")
        if let webViewController = createNewWebViewController() {
                
            let urlString = url.absoluteString
            webViewController.URLString = urlString
            navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
    /**
     Creates a new web view using the Neeman.storyboard. If you would like to load a web view controller from your
     own storyboard then you should override this method and use your subclass in your storyboard.
     
     - returns: A new web view controller.
     */
    public func createNewWebViewController() -> WebViewController? {
        let neemanStoryboard = UIStoryboard(name: "Neeman", bundle: NSBundle(forClass: WebViewController.self))
        if let webViewController: WebViewController = neemanStoryboard.instantiateViewControllerWithIdentifier(
            (NSStringFromClass(WebViewController.self) as NSString).pathExtension) as? WebViewController {
                return webViewController
        }
        return nil
    }
    
    /**
     Decide if we should prevent a request from being loading in a new web view.
     It will instead be loaded in the current one.
     
     - parameter request: The request that is about to be loaded.
     
     - returns: false
     */
    public func shouldPreventPushOfNewRequest(request: NSURLRequest) -> Bool {
        return false
    }
    
    /**
     Decide if we should force the request to be loaded in a new web view.
     
     This is useful if a page is setting document.location within a click handler.
     Web kit does not realise that this was from a "link" click. In this case we can make sure it is handled like a link.
     
     - parameter request: The request that will be loaded.
     
     - returns: false
     */
    public func shouldForcePushOfNewRequest(request: NSURLRequest) -> Bool {
        return false
    }
    
    /**
     Decide if we should prevent the request from being loaded.
     
     This is useful if, for example, you would like to switch to another tab that is displaying this request.
     
     - parameter request: The request that will be loaded.
     
     - returns: Whether we should prevent the request from being loaded.
     */
    public func shouldPreventRequest(request: NSURLRequest) -> Bool {
        return false
    }

    /**
     Default implementation doesn't do anything.
     
     - parameter webView: The web view that finished navigating.
     - parameter url:     The final URL of the web view.
     */
    public func webView(webView: WKWebView, didFinishNavigationWithURL url: NSURL?) {
        errorViewController?.view.removeFromSuperview()
    }
    
    /**
     Desides how to handle an error based on its code.
     
     - parameter webView: The web view the error came from.
     - parameter error:   The error the web view incountered.
     */
    public func webView(webView: WKWebView, didFinishLoadingWithError error: NSError) {
        if #available(iOS 9.0, *) {
            if error.code == NSURLErrorAppTransportSecurityRequiresSecureConnection {
                showSSLError()
            }
        }
        
        let networkError = NetworkError(error: error)
        switch networkError {
        case .NotConnectedToInternet:
            showHTTPError(networkError)
        case .NotReachedServer:
            showHTTPError(networkError)
        default:()
        }
    }

    /**
     This is called when a message is received from your injected javascript code. 
     
     You will have to register to receive these script messages.
     
     ```swift
     webView.configuration.userContentController.addScriptMessageHandler(self, name: "yourMessageName")
     ```
     
     - parameter userContentController: The user content controller that is managing you messages.
     - parameter message:               The script message received from your javascript.
     */
    public func userContentController(userContentController: WKUserContentController,
        didReceiveScriptMessage message: WKScriptMessage) {
    }
    
    // MARK: WebView
    
    /**
    Load a new URL in the web view.
    
    - parameter URL: The URL to laod.
    */
    public func loadURL(URL: NSURL?) {
        guard let URL = URL else {
            showURLError()
            return
        }
        
        setErrorMessage(nil)
        hasLoadedContent = false
        
        progressView?.setProgress(0, animated: false)
        loadRequest(NSMutableURLRequest(URL: URL))
    }
    
    /**
     Load a new request in the web view.
     
     - parameter request: The request to load.
     */
    public func loadRequest(request: NSMutableURLRequest?) {
        if let request = request {
            webView.loadRequest(request)
        }
    }
}

// MARK: Notifications

/** Posting this will cause the didLogout(_:) method to be called. 
You can post this when you logout so that pages are reloaded after logging back in again.
*/
public let WebViewControllerDidLogout = "WebViewControllerDidLogout"

/** Posting this will cause the didLogin(_:) method to be called. You can post this from your custom native authentication code.
*/
public let WebViewControllerDidLogin = "WebViewControllerDidLogin"
