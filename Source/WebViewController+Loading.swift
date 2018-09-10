import UIKit
import WebKit

extension WebViewController {

    /**
     Setup the refresh control for reloading the web view.
     */
    open func setupRefreshControl() {
        let newRefreshControl = UIRefreshControl()
//        newRefreshControl.attributedTitle = NSAttributedString(string: "")
// This is a hack to improve the way the large titles work. They were not returning to the origional position in many cases.
// Pulling down fast seemed to reproduce the problem the most.
// The refresh method is now called in the scrollViewDidEndDecelerating method.
//        newRefreshControl.addTarget(self, action: #selector(WebViewController.refresh), for: UIControlEvents.valueChanged)
//        if #available(iOS 10.0, *) {
//            webView.scrollView.refreshControl = newRefreshControl
//        } else {
            webView.scrollView.insertSubview(newRefreshControl, at: 0)
//        }
        neemanRefreshControl = newRefreshControl
    }
    
    /**
     This action is called by the refresh control.
     */
    @objc open func refresh() {
        loadURL(rootURL)
    }

    /**
     This sets up progress view in the top of the view. If progressView is non-nil
     the we use that instead. If you want to create your own progress view you can override this
     method or you can set the outlet in interface builder.
     */
    open func setupProgressView() {
        if let _ = progressView {
            return
        }
        
        progressView = UIProgressView(progressViewStyle: .default)
        guard let progressView = progressView else {
            return
        }
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.accessibilityIdentifier = "NeemanProgressIndiciator"
        view.addSubview(progressView)
        
        let views = Dictionary(dictionaryLiteral: ("progressView", progressView))
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[progressView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: views)
        view.addConstraints(hConstraints)

        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[progressView(1)]",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: views)
        view.addConstraints(vConstraints)
        
        let yConstraint = NSLayoutConstraint(item: progressView,
            attribute: .top,
            relatedBy: .equal,
            toItem: topLayoutGuide,
            attribute: .bottom,
            multiplier: 1,
            constant: 0)
        view.addConstraint(yConstraint)
    }

    /**
     This sets up an activity indicator in the center of the screen. If activityIndicator is non-nil
     the we use that instead. If you want to create your own activityIndicator you can override this 
     method or you can set the outlet in interface builder.
     */
    open func setupActivityIndicator() {
        if let _ = activityIndicator {
            return
        }
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 8.5, y: 8.5, width: 24, height: 24))
        guard let activityIndicator = activityIndicator else {
            return
        }
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = true
        activityIndicator.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]

        let holder = createActivityIndicatorHolder()
        holder.addSubview(activityIndicator)
        view.addSubview(holder)
        
        activityIndicator.startAnimating()
        
        holder.translatesAutoresizingMaskIntoConstraints = false
        let xCenterConstraint = NSLayoutConstraint(item: holder,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerX,
            multiplier: 1,
            constant: 0)
        view.addConstraint(xCenterConstraint)

        let yConstraint = NSLayoutConstraint(item: holder,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: bottomLayoutGuide,
            attribute: .top,
            multiplier: 1,
            constant: -25)
        view.addConstraint(yConstraint)
        
        let widthConstraint = NSLayoutConstraint(item: holder, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: holder.frame.width)
        let heightConstraint = NSLayoutConstraint(item: holder, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: holder.frame.height)
        view.addConstraints([widthConstraint, heightConstraint])
    }
    
    fileprivate func createActivityIndicatorHolder() -> UIView {
        let holder = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        holder.layer.cornerRadius = holder.frame.height / 2
        holder.backgroundColor = .white
        holder.layer.shadowColor = UIColor.black.cgColor
        let sizeOf1 = 1.0/UIScreen.main.scale
        holder.layer.shadowOffset = CGSize(width: sizeOf1, height: sizeOf1)
        holder.layer.masksToBounds = false
        holder.layer.shadowRadius = 0.5
        holder.layer.shadowOpacity = 0.25
        holder.isUserInteractionEnabled = false
        activityIndicatorHolder = holder
        
        return holder
    }
    
    /**
     This is called when there is a posibly a need to update the status of the activity indicator. 
     For example, when the web view loading status has changed.
     
     - parameter webView: The web view whose activity we should indicate.
     */
    func updateActivityIndicatorWithWebView(_ webView: WKWebView?) {
        if let webView = webView, webView.isLoading {
            let isRefreshing = neemanRefreshControl?.isRefreshing ?? false
            if !isRefreshing {
                activityIndicator?.startAnimating()
                activityIndicatorHolder?.isHidden = false
            }
            WebViewController.networkActivityCount += 1
        } else {
            activityIndicator?.stopAnimating()
            activityIndicatorHolder?.isHidden = true
            WebViewController.networkActivityCount -= 1
        }
    }
    /**
     This is called when there is a posibly a need to update the status of the progress view.
     For example, when the web view's estimated progress has changed.
     
     - parameter webView: The web view whose progress we should indicate.
     */
    func updateProgressViewWithWebView(webView: WKWebView) {
        guard let progressView = progressView else {
            return
        }
        
        progressView.isHidden = !webView.isLoading
        if !webView.isLoading {
            progressView.setProgress(0, animated: false)
        }
    }
}

extension WebViewController: WebViewObserverDelegate {
    
    /**
     Called when the webView updates the value of its title property.
     
     - parameter webView: The instance of WKWebView that updated its title property.
     - parameter title: The value that the WKWebView updated its title property to.
     */
    @objc open func webView(_ webView: WKWebView, didChangeTitle title: String?) {
        navigationItem.title = title
    }
    
    /**
     This is called when the web view change its estimate loading progress.
     
     - parameter webView:           The web view.
     - parameter estimatedProgress: The estimated fraction of the progress toward loading the page.
     */
    open func webView(_ webView: WKWebView, didChangeEstimatedProgress estimatedProgress: Double) {
        progressView?.setProgress(Float(estimatedProgress), animated: true)
    }
    
}
