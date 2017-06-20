//import UIKit
import WebKit

/**
 Represents an object that can be used to display web page.
 */
public protocol NeemanViewController {
    /** The initial URL to display in the web view. Set this in your storyboard in the "User Defined Runtime Attributes" */
    var URLString: String? { get set }
    /** This is called when the initial page needs to be reloaded. */
    func refresh()
}

/**
  WebViewController displays the contents of a URL and pushes a new instance of itself once the 
  user clicks on a link that causes an URL change. It also provides support for authentication. 
  It makes injecting Javascript into your webapp easy.
*/
open class WebViewController: UIViewController,
                                NeemanViewController,
                                WKScriptMessageHandler {
    
    // MARK: Outlets
    /// Shows that the web view is still loading the page.
    @IBOutlet open var activityIndicator: UIActivityIndicatorView?
    
    /// Shows the progress toward loading the page.
    @IBOutlet open var progressView: UIProgressView?
    
    /// Displays an error the occured whilst loading the page.
    @IBOutlet var errorViewController: ErrorViewController?

    // MARK: Properties
    
    /// The settings to set the web view up with.
    open var settings: NeemanSettings = NeemanSettings()

    /// The navigation delegate that will receive changes in loading, estimated progress and further navigation.
    open var navigationDelegate: WebViewNavigationDelegate?
    /// The UI delegate that allows us to implement our own code to handle window.open(), alert(), confirm() and prompt().
    open var uiDelegate: WebViewUIDelegate?
    /// This is a popup window that is opened when javascript code calles window.open().
    var uiDelegatePopup: WebViewUIDelegate?
    /// This is a navigation controller that is used to present a popup webview modally.
    var popupNavController: UINavigationController?
    
    /// This is the count of how many web view controllers are currently loading.
    static var networkActivityCount: Int = 0 {
        didSet {
            networkActivityCount = max(0, networkActivityCount)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIApplication.shared.isNetworkActivityIndicatorVisible = networkActivityCount > 0
            }

        }
    }
    
    /// The initial NSURL that the web view is loading. Use URLString to set the URL.
    open var rootURL: URL? {
        get {
            return (absoluteURLString != nil) ? URL(string: absoluteURLString!) : nil
        }
    }
    
    /** The initial URL to display in the web view. Set this in your storyboard in the "User Defined Runtime Attributes"
    You can set baseURL in Settings if you would like to use relative URLs instead.
     */
    @IBInspectable open var URLString: String?
    
    /** If URLString is not an absolute URL and if you have set the baseURL in Settings
     then this returns the absolute URL by combining the two.
     */
    var absoluteURLString: String? {
        get {
            if let urlString = URLString, !urlString.contains("://"), urlString != "about:blank" {
                return settings.baseURL + urlString
            }
            return URLString
        }
    }
    
    /** A UIRefreshControl is automatically added to the WKWebView.
        When you pull down your webView the page will be refreshed.
    */
    open var refreshControl: UIRefreshControl?
    
    /** This is set once the web view has successfully loaded. If for some reason the page doesn't load
        then we know know when we return we should try again.
     */
    open internal(set) var hasLoadedContent: Bool = false

    /**
     The WKWebView in which the content of the URL defined in URLString will be dispayed.
     */
    open var webView: WKWebView!
    
    /// A web view that is used to display a window that was opened with window.open().
    open var webViewPopup: WKWebView?
    
    /// Observes properties of a web view such as loading, estimatedProgress and its title.
    var webViewObserver: WebViewObserver = WebViewObserver()
    
    //MARK: Lifecycle
    
    /**
    Setup the web view, the refresh controll, the activity indicator, progress view and observers.
    */
    override open func viewDidLoad() {
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
        NotificationCenter.default.addObserver(self,
            selector: #selector(self.didLogout(_:)), name: NSNotification.Name(rawValue: WebViewControllerDidLogout), object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(self.didLogin(_:)), name: NSNotification.Name(rawValue: WebViewControllerDidLogin), object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(self.didBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(self.forceReloadOnAppear(_:)),
            name: NSNotification.Name(rawValue: WebViewControllerForceReloadOnAppear), object: nil)
        webViewObserver.startObservingWebView(webView)
    }
    
    /**
     Stop observing notifications and KVO.
     */
    deinit {
        NotificationCenter.default.removeObserver(self)
        webViewObserver.stopObservingWebView(webViewPopup)
        webViewObserver.stopObservingWebView(webView)
        if webView != nil && webView.isLoading {
            WebViewController.networkActivityCount -= 1
        }
    }

    /**
     In here we check to see if we have previously loaded a page successfully. If not we reload the root URL.
     
     - parameter animated: Was the appearence animated.
     */
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldReloadOnViewWillAppear(animated) && !webView.isLoading {
            loadURL(rootURL)
        }
    }
    
    /**
     This action is called by as a result of a UIApplicationDidBecomeActiveNotification.
     */
    open func didBecomeActive(_ notification: Notification) {
        if !hasLoadedContent {
            loadURL(rootURL)
        }
    }
    
    /**
     This action is called by as a result of a UIApplicationDidBecomeActiveNotification.
     */
    open func forceReloadOnAppear(_ notification: Notification) {
        hasLoadedContent = false
    }
    
    /**
     This is called from viewWillAppear and reloads the page if the page has not yet been successfully loaded.
     If you want to do something different you can override this method 
     and place additional logic in the viewWill* and viewDid* events.
     
     - parameter animated: Whether the appearance is happening with animation or not.
     - returns: Whether the page should be reloaded.
    */
    open func shouldReloadOnViewWillAppear(_ animated: Bool) -> Bool {
        if !hasLoadedContent {
            return true
        }
        
        if webView.url?.absoluteString == "about:blank" {
            return true
        }
        
        return false
    }

    /**
     Since iOS only automatically adjusts scroll view insets for the main web view 
     we have to do it ourselves for the popup web view.
     */
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        webViewPopup?.scrollView.contentInset = webView.scrollView.contentInset
        webViewPopup?.scrollView.scrollIndicatorInsets = webView.scrollView.scrollIndicatorInsets
    }
    
    // MARK: Notification Handlers
    
    /**
    In here we set hasLoadedContent so that we reload the page after returning back.
    
    - parameter notification: The notification received.
    */
    open func didLogout(_ notification: Notification) {
        hasLoadedContent = false
    }
    
    /**
     This forces an imidiate reload of the page using the rootURL. You can override this method if you 
     would prefer instead just to call any of the web view's methods to reload.
     
     - parameter notification: The notification received.
     */
    open func didLogin(_ notification: Notification) {
        if isViewLoaded && view.window != nil {
            loadURL(rootURL)
        }
    }
   

    
    /**
     Desides how to handle an error based on its code.
     
     - parameter webView: The web view the error came from.
     - parameter error:   The error the web view incountered.
     */
    open func webView(_ webView: WKWebView, didFinishLoadingWithError error: NSError) {
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
     Creates a new web view using the Neeman.storyboard. If you would like to load a web view controller from your
     own storyboard then you should override this method and use your subclass in your storyboard.
     
     - returns: A new web view controller.
     */
    open func createNewWebViewController() -> NeemanViewController? {
        let neemanStoryboard = UIStoryboard(name: "Neeman", bundle: Bundle(for: WebViewController.self))
        if let webViewController: WebViewController = neemanStoryboard.instantiateViewController(
            withIdentifier: (NSStringFromClass(WebViewController.self) as NSString).pathExtension) as? WebViewController {
            return webViewController
        }
        return nil
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
    open func userContentController(_ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage) {
    }
    
    // MARK: WebView
    
    /**
    Load a new URL in the web view.
    
    - parameter URL: The URL to laod.
    */
    open func loadURL(_ URL: Foundation.URL?) {
        guard let URL = URL else {
            showURLError()
            return
        }
        
        setErrorMessage(nil)
        hasLoadedContent = false
        
        progressView?.setProgress(0, animated: false)
        loadRequest(NSMutableURLRequest(url: URL))
    }
    
    /**
     Load a new request in the web view.
     
     - parameter request: The request to load.
     */
    open func loadRequest(_ request: NSMutableURLRequest?) {
        guard let webView = webView else { return }
        if let url = request?.url, let cookies = HTTPCookieStorage.shared.cookies(for: url) {
            request?.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
        }
        if let request = request {
            webView.load(request as URLRequest)
        }
    }
}

extension WebViewController: NeemanNavigationDelegate {
    //MARK: NeemanNavigationDelegate
    
    
    /**
     Pushes a new web view onto the navigation stack.
     
     - parameter url: The URL to load in the web view.
     */
    open func pushNewWebViewControllerWithURL(_ url: URL) {
        let urlString = url.absoluteString
        print("Pushing: \(urlString)")
        if var webViewController = createNewWebViewController() {
            webViewController.URLString = urlString
            if let viewController = webViewController as? UIViewController {
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    /**
     Decide if we should prevent a navigation action from being loading in a new web view.
     It will instead be loaded in the current one.
     
     - parameter navigationAction: The navigation action that will be loaded.
     
     - returns: false
     */
    open func shouldPreventPushOfNavigationAction(_ navigationAction: WKNavigationAction) -> Bool {
        return false
    }

    /**
     Decide if we should force the navigation action to be loaded in a new web view.
     
     This is useful if a page is setting document.location within a click handler.
     Web kit does not realise that this was from a "link" click. In this case we can make sure it is handled like a link.
     
     - parameter navigationAction: The navigation action that will be loaded.
     
     - returns: false
     */
    open func shouldForcePushOfNavigationAction(_ navigationAction: WKNavigationAction) -> Bool {
        return false
    }
    
    /**
     Decide if we should prevent the navigation action from being loaded.
     
     This is useful if, for example, you would like to switch to another tab that is displaying this request.
     
     - parameter navigationAction: The navigation action that will be loaded.
     
     - returns: Whether we should prevent the request from being loaded.
     */
    open func shouldPreventNavigationAction(_ navigationAction: WKNavigationAction) -> Bool {
        return false
    }
    
    /**
     Default implementation doesn't do anything.
     
     - parameter webView: The web view that finished navigating.
     - parameter url:     The final URL of the web view.
     */
    open func webView(_ webView: WKWebView, didFinishNavigationWithURL url: URL?) {
        errorViewController?.view.removeFromSuperview()
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

/** Posting this will cause the web view to reload it's content next time the viewDidAppear is called.
 */
public let WebViewControllerForceReloadOnAppear = "WebViewControllerForceReloadOnAppear"

/** Posting this will enable you to show a modal login view controller.
 */
public let WebViewControllerDidRequestLogin = "WebViewControllerDidRequestLogin"
