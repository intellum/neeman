import UIKit
import WebKit

extension WebViewController {
    
    /**
     This is used for adding a logout button to the right navigation item. 
     You can over ride this or set the "logoutPage" regex in the Settings.plist.
     */
    public func setupNavigationBar() {
        setupRefreshControll()
        
        let logoutPage = Settings.sharedInstance.logoutPage
        if let _ = self.rootURLString?.rangeOfString(logoutPage, options: .RegularExpressionSearch) {
            let title = NSLocalizedString("Logout", comment: "The label on the logout button")
            let logoutButtonItem = UIBarButtonItem(title: title, style: .Plain, target: self, action: "didTapLogout:")
            if let rightBarButtonItem = navigationItem.rightBarButtonItem {
                navigationItem.rightBarButtonItems = [logoutButtonItem, rightBarButtonItem]
            } else {
                navigationItem.rightBarButtonItem = logoutButtonItem
            }
        }
    }
    
    func setupRefreshControll() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        webView.scrollView.insertSubview(refreshControl, atIndex: 0)
    }

    func refresh(sender: AnyObject) {
        loadURL(rootURL)
    }

    /**
     Called when the webView updates the value of its loading property.
     - Parameter webView: The instance of WKWebView that updated its loading property.
     - Parameter loading: The value that the WKWebView updated its loading property to.
     */
    public func webView(webView: WKWebView, didChangeLoading loading: Bool) {
        updateActivityIndicator()
        if !loading {
            refreshControl.endRefreshing()
            hasLoadedContent = true
        }
    }
    
    func updateActivityIndicator() {
        if webView.loading && !self.refreshControl.refreshing {
            activityIndicator?.startAnimating()
        } else {
            activityIndicator?.stopAnimating()
        }
    }
}
