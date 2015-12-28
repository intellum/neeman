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
    
    public func webView(webView: WKWebView, didChangeEstimatedProgress estimatedProgress: Double) {
        progressView?.setProgress(Float(estimatedProgress), animated: true)
    }
    
    /**
     This sets up progress view in the top of the view. If progressView is non-nil
     the we use that instead. If you want to create your own progress view you can override this
     method or you can set the outlet in interface builder.
     */
    public func setupProgressView() {
        if let _ = progressView {
            return
        }
        
        progressView = UIProgressView(progressViewStyle: .Default)
        guard let progressView = progressView else {
            return
        }
        progressView.backgroundColor = UIColor.magentaColor()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        let views = Dictionary(dictionaryLiteral: ("progressView", progressView))
        
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[progressView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: views)
        view.addConstraints(hConstraints)

        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[progressView(1)]",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: views)
        view.addConstraints(vConstraints)
        
        let yConstraint = NSLayoutConstraint(item: progressView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: topLayoutGuide,
            attribute: .Bottom,
            multiplier: 1,
            constant: 0)
        view.addConstraint(yConstraint)

        
    }

    /**
     This sets up an activity indicator in the center of the screen. If activityIndicator is non-nil
     the we use that instead. If you want to create your own activityIndicator you can override this 
     method or you can set the outlet in interface builder.
     */
    public func setupActivityIndicator() {
        if let _ = activityIndicator {
            return
        }
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50))
        guard let activityIndicator = activityIndicator else {
            return
        }
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let xCenterConstraint = NSLayoutConstraint(item: activityIndicator,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterX,
            multiplier: 1,
            constant: 0)
        view.addConstraint(xCenterConstraint)
        
        let yConstraint = NSLayoutConstraint(item: activityIndicator,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: bottomLayoutGuide,
            attribute: .Top,
            multiplier: 1,
            constant: -20)
        view.addConstraint(yConstraint)
    }
    
    func updateActivityIndicator() {
        if webView.loading {
            if !self.refreshControl.refreshing {
                activityIndicator?.startAnimating()
            }
            progressView?.hidden = false
        } else {
            activityIndicator?.stopAnimating()
            progressView?.hidden = true
            progressView?.setProgress(0, animated: false)
        }
    }
}
