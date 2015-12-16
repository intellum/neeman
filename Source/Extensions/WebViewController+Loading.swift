import UIKit

extension WebViewController {
    public func setupNavigationBar() {
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
    
    func setupRefreshControll() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        webView.scrollView.insertSubview(refreshControl, atIndex: 0)
    }

    func refresh(sender: AnyObject) {
        loadURL(rootURL)
    }
    
    func loadingDidChange() {
        updateActivityIndicator()
        if !webView.loading {
            refreshControl.endRefreshing()
            hasLoadedContent = true
            setContentInset()
        }
        refreshControl.endRefreshing()
    }
    
    public func updateActivityIndicator() {
        if webView.loading && !self.refreshControl.refreshing {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}
