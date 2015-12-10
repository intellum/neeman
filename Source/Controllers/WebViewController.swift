import UIKit
import WebKit
import KeychainAccess

let WebViewControllerDidLogout = "WebViewControllerDidLogout"

public class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    // MARK: Constants
    let BASE_URL = Settings.sharedInstance.baseURL
    let AUTH_COOKIE_NAME = Settings.sharedInstance.authCookieName

    // MARK: Properties
    var rootURL: NSURL?
    public var rootAbsoluteURLString : String = ""
    public var rootURLString : String? {
        didSet {
            rootAbsoluteURLString = rootURLString!
            if rootURLString!.rangeOfString("://") == nil {
                rootAbsoluteURLString = BASE_URL + rootURLString!
            }
            
            self.rootURL = NSURL(string: rootAbsoluteURLString)
        }
    }
    
    let keychain = Keychain(service: "com.intellum.level")

    var activityIndicator: UIActivityIndicatorView = {
        return UIActivityIndicatorView(activityIndicatorStyle: .White)
    }()
    public var refreshControl: UIRefreshControl!
    var hasLoadedContent: Bool = false

    public var webView: WKWebView!
    public var webViewConfig: WKWebViewConfiguration!
    static let processPool = WKProcessPool()
    
    //MARK: Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        setupNavigationBar()

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didEnterForeground:",
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didLogout:",
            name: WebViewControllerDidLogout,
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupNavigationBar() {
        activityIndicator.startAnimating()
        let activityIndicatorBBI = UIBarButtonItem(customView: activityIndicator)
        navigationItem.rightBarButtonItem = activityIndicatorBBI
        setupRefreshControll()
        
        let logoutPage = Settings.sharedInstance.logoutPage
        if let _ = self.rootURLString?.rangeOfString(logoutPage, options: .RegularExpressionSearch) {
            let title = NSLocalizedString("Logout", comment: "The label on the logout button")
            let logoutButtonItem = UIBarButtonItem(title: title, style: .Plain, target: self, action: "didTapLogout")
            navigationItem.rightBarButtonItems = [logoutButtonItem, navigationItem.rightBarButtonItem!]
        }
    }

    func didTapLogout() {
        NSNotificationCenter.defaultCenter().postNotificationName(WebViewControllerDidLogout, object: self)
        keychain["app_auth_cookie"] = nil
        showLogin()
    }
    
    func didLogout(notification: NSNotification) {
        self.hasLoadedContent = false;
        navigationController?.popToRootViewControllerAnimated(false)
    }
    
    func setupRefreshControll() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        webView.scrollView.insertSubview(refreshControl, atIndex: 0)
    }

    func setupWebView() {
        webViewConfig = WKWebViewConfiguration()
        webViewConfig.processPool = WebViewController.processPool
        webView = WKWebView(frame: view.bounds, configuration: webViewConfig)
        webView.navigationDelegate = self
        webView.UIDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        addScriptsToConfiguration(webViewConfig)

        view.insertSubview(webView, atIndex: 0)
        webView.translatesAutoresizingMaskIntoConstraints = false
        autolayoutWebView()
    }
    
    public func autolayoutWebView() {
        let views = ["webView":webView, "topLayoutGuide":self.topLayoutGuide] as [String: AnyObject]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[webView(>=0)]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[webView(>=0)]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    func loadURL(url :NSURL?) {
        guard let url = url else {
            let imageView = UIImageView(frame: self.view.bounds)
            imageView.contentMode = .ScaleAspectFit
            imageView.image = UIImage(named: "Help-URL", inBundle: NSBundle(forClass: WebViewController.self), compatibleWithTraitCollection: nil)
            self.view.addSubview(imageView)
            return
        }
       
        setErrorMessage(nil)
        hasLoadedContent = false

        let request = NSMutableURLRequest(URL: url)
        if let authCookieName = AUTH_COOKIE_NAME {
            if let authToken = keychain["app_auth_cookie"] {
                let authCookie = "\(authCookieName)=\(authToken);"
                request.setValue(authCookie, forHTTPHeaderField: "Cookie")
                webView.loadRequest(request)
            }else{
                showLogin()
            }
        } else {
            webView.loadRequest(request)
        }
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
    
    // MARK: Resume from Background
    func didEnterForeground(notification: NSNotification) {
        //refresh(self)
    }

    // MARK: Title and Loading
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard keyPath != nil else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        switch keyPath!
        {
        case "title":
            setTitle()
        case "loading":
            updateActivityIndicator()
        default:
            print("observed value not handled \(keyPath)")
        }
    }
    
    public func setTitle() {
        navigationItem.title = webView.title?.uppercaseString
    }

    //MARK: Loading
    
    func refresh(sender: AnyObject) {
        loadURL(rootURL)
    }

    public func updateActivityIndicator()
    {
        if(webView.loading && !self.refreshControl.refreshing) {
            activityIndicator.startAnimating()
        }else{
            activityIndicator.stopAnimating()
        }
    }
    
    //MARK: Javascript
    
    func addScriptsToConfiguration(config:WKWebViewConfiguration)
    {
        addScript("AtDocumentStart.js", config: webViewConfig, injectionTime: .AtDocumentStart)
        addScript("AtDocumentEnd.js", config: webViewConfig, injectionTime: .AtDocumentEnd)
        addScript("FastClick.js", config: webViewConfig, injectionTime: .AtDocumentEnd)
        addCSSScript(webViewConfig)
    }
    
    func addScript(scriptName:String, config:WKWebViewConfiguration, injectionTime:WKUserScriptInjectionTime)
    {
        let content = stringFromContentInFileName(scriptName)
        let script = WKUserScript(source: content, injectionTime: injectionTime, forMainFrameOnly: true)
        config.userContentController .addUserScript(script)
    }
    
    func addCSSScript(config:WKWebViewConfiguration)
    {
        var javascript = stringFromContentInFileName("InjectCSS.js")
        var css = stringFromContentInFileName("WebView.css")
        css = css.stringByReplacingOccurrencesOfString("\n", withString: "\\\n")
        javascript = javascript.stringByReplacingOccurrencesOfString("${CSS}", withString: css)

        let script = WKUserScript(source: javascript, injectionTime: .AtDocumentStart, forMainFrameOnly: true)
        config.userContentController .addUserScript(script)
    }

    func stringFromContentInFileName(fileName:String) -> String!
    {
        var path = NSBundle.mainBundle().pathForResource(fileName, ofType: "")
        if path == nil {
            path = NSBundle(forClass: WebViewController.self).pathForResource(fileName, ofType: "")
        }
        guard let _ = path else {
            return ""
        }
        
        do {
            let content = try String(contentsOfFile:path!, encoding: NSUTF8StringEncoding)
            return content;
        } catch _ {
        }
        return ""
    }
    
    //MARK: Cookies
    func saveCookiesFromResponse(urlResponse :NSURLResponse) {
        if let response :NSHTTPURLResponse = urlResponse as? NSHTTPURLResponse {
            guard let url = response.URL else {
                return
            }
            
            let headerFields = response.allHeaderFields as! [String:String]
            let cookies : [NSHTTPCookie] = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: url)
            for cookie in cookies {
                if cookie.name == AUTH_COOKIE_NAME {
                    keychain["app_auth_cookie"] = cookie.value
                }
            }
        }
    }
    
    //MARK: WKNavigationDelegate
    
    public func webView(webView: WKWebView,
        decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse,
        decisionHandler: (WKNavigationResponsePolicy) -> Void)
    {
        saveCookiesFromResponse(navigationResponse.response)
        decisionHandler(.Allow);
    }
    
    public func webView(webView: WKWebView,
        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
        decisionHandler: (WKNavigationActionPolicy) -> Void)
    {
        var actionPolicy :WKNavigationActionPolicy = .Allow

        let shouldPush = shouldPushNewWebView(navigationAction.request)
        if navigationAction.navigationType == .LinkActivated && shouldPush {
            pushNewWebViewControllerWithURL(navigationAction.request.URL!)
            actionPolicy = .Cancel
        }else if isLoginRequestRequest(navigationAction.request) {
            actionPolicy = .Cancel
            showLogin()
        }
        
        let actionString = (actionPolicy.rawValue == 1) ? "Allowed" : "Canceled"
        print("URL: " + (navigationAction.request.URL?.absoluteString)! + "\t\t\t- " + actionString)
        
        decisionHandler(actionPolicy)
    }
    
    func shouldPushNewWebView(request: NSURLRequest) -> Bool {
        guard let url = request.URL else {
            return false
        }
        let isInitialRequest = url.absoluteString == self.rootAbsoluteURLString
        let isSameHost = request.URL?.host == rootURL?.host
        let isSamePath = request.URL?.path == rootURL?.path
        let isFragmentOfThisPage = request.URL?.fragment != nil && isSameHost && isSamePath
        
        return !isInitialRequest && !isFragmentOfThisPage
    }
    
    func isLoginRequestRequest(request: NSURLRequest) -> Bool {
        var isLoginPath = false
        let isGroupDock = request.URL?.absoluteString.rangeOfString("://groupdock.com") != nil
        let loginPaths = ["/login", "/elogin", "/sso/launch"]
        if let path = request.URL?.path
        {
            isLoginPath = loginPaths.contains(path)
        }
        return isLoginPath || isGroupDock
    }
    
    func pushNewWebViewControllerWithURL(url :NSURL) {
        if let webViewController: WebViewController = storyboard?.instantiateViewControllerWithIdentifier(
            (NSStringFromClass(WebViewController.self) as NSString).pathExtension) as? WebViewController
        {
            let urlString = url.absoluteString
            webViewController.rootURLString = urlString
            navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
    public func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        refreshControl.endRefreshing()
        hasLoadedContent = true
        setContentInset()
    }
    
    public func setContentInset() {
    }
    
    public func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError)
    {
        var message: String?

        switch error.code {
        case NSURLErrorNotConnectedToInternet:
            message = error.localizedDescription
        default:
            message = nil
        }
        
        if #available(iOS 9.0, *) {
            if error.code == NSURLErrorAppTransportSecurityRequiresSecureConnection {
                let imageView = UIImageView(frame: self.view.bounds)
                imageView.contentMode = .ScaleAspectFit
                imageView.image = UIImage(named: "Help-Security", inBundle: NSBundle(forClass: WebViewController.self), compatibleWithTraitCollection: nil)
                self.view.addSubview(imageView)
            }
        }
        
        if let message = message {
            setErrorMessage(message)
        }
        refreshControl.endRefreshing()
    }
    
    public func setErrorMessage(message: String?) {
        self.navigationItem.prompt = message
    }
    
    public func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError)
    {
        print(error)
    }
    
    // MARK: WKUIDelegate
    public func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        print(message)
        completionHandler()
    }
    
    func showLogin() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let storyboard = UIStoryboard(name: "Neeman", bundle: NSBundle(forClass: WebViewController.self))
            if let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginNavigationController") as? UINavigationController {
                loginVC.setNavigationBarHidden(true, animated: false)
                self.view.window?.rootViewController?.presentViewController(loginVC, animated: true, completion: nil)
            }
        }
    }
}

