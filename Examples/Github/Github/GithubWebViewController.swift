import UIKit
import WebKit
import Neeman

class GithubWebViewController: WebViewController {
    var rightBarButtonURL: NSURL?
    override func viewDidLoad() {
        if rootURL?.path == "/profile" {
            if let username = NSUserDefaults.standardUserDefaults().objectForKey("Username") {
                rootURLString = rootURLString?.stringByReplacingOccurrencesOfString("/profile", withString: "/\(username)")
            }
        }
        super.viewDidLoad()
    }
    
    internal override func setupWebView() {
        super.setupWebView()
        self.webView.configuration.userContentController.addScriptMessageHandler(self, name: "didGetUserName")
        self.webView.configuration.userContentController.addScriptMessageHandler(self, name: "didGetBarButton")
    }
    
    internal override func userContentController(userContentController: WKUserContentController,
        didReceiveScriptMessage message: WKScriptMessage) {
            print("Message: \(message.name)")
            if message.name == "didGetUserName" {
                if let username = message.body as? String {
                    if username.characters.count > 0 {
                        NSUserDefaults.standardUserDefaults().setObject(username, forKey: "Username")
                    } else if webView.URL?.path != "/login" {
                        loadURL(NSURL(string: "\(settings.baseURL)/login"))
                    }
                }
            } else if message.name == "didGetBarButton" {
                if let urlString = message.body as? String,
                    url = NSURL(string: urlString) {
                    let barButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "didTapBarButton")
                    self.navigationItem.rightBarButtonItem = barButton
                    rightBarButtonURL = url
                }
            }
    }
    
    func didTapBarButton() {
        if let url = rightBarButtonURL {
            pushNewWebViewControllerWithURL(url)
        }
    }
    
    // MARK: Notification Handlers
    override internal func didLogout(notification: NSNotification) {
        loadURL(NSURL(string: "\(settings.baseURL)/logout"))
    }

     override internal func pushNewWebViewControllerWithURL(url: NSURL) {
        print("Pushing: \(url.absoluteString)")
        if let webViewController = storyboard?.instantiateViewControllerWithIdentifier(
            (NSStringFromClass(GithubWebViewController.self) as NSString).pathExtension) as? GithubWebViewController {
                
                let urlString = url.absoluteString
                webViewController.rootURLString = urlString
                navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
    override internal func shouldForcePushOfNewRequest(request: NSURLRequest) -> Bool {
        let isSamePage = webView.URL?.absoluteString == request.URL?.absoluteString
        return !isSamePage && request.URL?.path == "/search"
    }
}
