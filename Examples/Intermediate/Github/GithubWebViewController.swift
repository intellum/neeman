import UIKit
import WebKit
import Neeman

class GithubWebViewController: WebViewController {
    var rightBarButtonURL: URL?
    override func viewDidLoad() {
        if rootURL?.path == "/profile" {
            if let username = UserDefaults.standard.object(forKey: "Username") {
                URLString = URLString?.replacingOccurrences(of: "/profile", with: "/\(username)")
            }
        }
        super.viewDidLoad()
    }
    
    internal override func setupWebView() {
        super.setupWebView()
        self.webView.configuration.userContentController.add(self, name: "didGetUserName")
        self.webView.configuration.userContentController.add(self, name: "didGetBarButton")
    }
    
    internal override func userContentController(_ userContentController: WKUserContentController,
                                                 didReceive message: WKScriptMessage) {
            print("Message: \(message.name)")
            if message.name == "didGetUserName" {
                if let username = message.body as? String {
                    if !username.isEmpty {
                        UserDefaults.standard.set(username, forKey: "Username")
                    } else if webView.url?.path != "/login" {
                        if let host = rootURL?.host {
                            let baseURLString = "https://\(host)"
                            loadURL(URL(string: "\(baseURLString)/login"))
                        }
                    }
                }
            } else if message.name == "didGetBarButton" {
                if let urlString = message.body as? String,
                    let url = URL(string: urlString) {
                    let barButton = UIBarButtonItem(barButtonSystemItem: .add,
                                                    target: self,
                                                    action: #selector(GithubWebViewController.didTapBarButton))
                    self.navigationItem.rightBarButtonItem = barButton
                    rightBarButtonURL = url
                }
            }
    }
    
    @objc func didTapBarButton() {
        if let url = rightBarButtonURL {
            pushNewWebViewControllerWithURL(url)
        }
    }
    
    // MARK: Notification Handlers
    @objc override internal func didLogout(_ notification: Notification) {
        loadURL(URL(string: "https://github.com/logout"))
    }

    override internal func pushNewWebViewControllerWithURL(_ url: URL) {
        print("Pushing: \(url.absoluteString)")
        if let webViewController = storyboard?.instantiateViewController(
            withIdentifier: (NSStringFromClass(GithubWebViewController.self) as NSString).pathExtension) as? GithubWebViewController {
                
                let urlString = url.absoluteString
                webViewController.URLString = urlString
                navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
    override internal func shouldForcePushOfNavigationAction(_ navigationAction: WKNavigationAction) -> Bool {
        let request = navigationAction.request
        let isSamePage = webView.url?.absoluteString == request.url?.absoluteString
        return !isSamePage && request.url?.path == "/search"
    }
}
