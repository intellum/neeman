import UIKit

extension WebViewController {
    
    /**
      This can be overridden to display error messages received from the web view. 
     The default implementation sets the `navigationItem.prompt`
     
     - parameter message: The error message that should be presented. 
     */
    public func setErrorMessage(message: String?) {
        navigationItem.prompt = message
    }
    
    /**
     Adds an image view which shows how to set the URLString.
     */
    func showURLError() {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .ScaleAspectFit
        imageView.image = UIImage(named: "Help-URL", inBundle: NSBundle(forClass: WebViewController.self), compatibleWithTraitCollection: nil)
        view.addSubview(imageView)
    }
    
    /**
     Adds and image view which shows what to do when you are getting app transport security error.
     */
    func showSSLError() {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .ScaleAspectFit
        imageView.image = UIImage(named: "Help-Security",
            inBundle: NSBundle(forClass: WebViewController.self),
            compatibleWithTraitCollection: nil)
        view.addSubview(imageView)
    }
    
    func showHTTPError(error: NetworkError) {
        if hasLoadedContent {
            setErrorMessage(error.description)
            return
        }
        if errorViewController == nil {
            let storyboard = UIStoryboard(name: "Neeman", bundle: NSBundle(forClass: WebViewController.self))
            guard let errorVC = storyboard.instantiateViewControllerWithIdentifier("ErrorViewController") as? ErrorViewController else {
                return
            }
            errorViewController = errorVC
        } else {
            errorViewController?.view.removeFromSuperview()
        }
        
        if let errorViewController = errorViewController {
            
            webView.scrollView.addSubview(errorViewController.view!)
            
            if let mainBundleImage = UIImage(named: "Error-HTTP",
                inBundle: NSBundle.mainBundle(),
                compatibleWithTraitCollection: nil) {
                    errorViewController.imageView.image = mainBundleImage
            } else if let neemanBundleImage = UIImage(named: "Error-HTTP",
                inBundle: NSBundle(forClass: WebViewController.self),
                compatibleWithTraitCollection: nil) {
                    errorViewController.imageView.image = neemanBundleImage
            }
            
            errorViewController.label.text = error.description
            
            self.addChildViewController(errorViewController)
        }
        
    }

}
