import UIKit

extension WebViewController {
    
    /**
      This can be overridden to display error messages received from the web view. 
     The default implementation sets the `navigationItem.prompt`
     
     - parameter message: The error message that should be presented. 
     */
    @objc open func setErrorMessage(_ message: String?) {
        navigationItem.prompt = message
    }
    
    /**
     Adds an image view which shows how to set the URLString.
     */
    func showURLError() {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "Help-URL", in: Bundle(for: WebViewController.self), compatibleWith: nil)
        view.addSubview(imageView)
    }
    
    /**
     Adds and image view which shows what to do when you are getting app transport security error.
     */
    func showSSLError() {
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "Help-Security",
            in: Bundle(for: WebViewController.self),
            compatibleWith: nil)
        view.addSubview(imageView)
    }
    
    func showHTTPError(_ error: NetworkError) {
        if hasLoadedContent {
            setErrorMessage(error.description)
            return
        }
        if errorViewController == nil {
            let storyboard = UIStoryboard(name: "Neeman", bundle: Bundle(for: WebViewController.self))
            guard let errorVC = storyboard.instantiateViewController(withIdentifier: "ErrorViewController") as? ErrorViewController else {
                return
            }
            errorViewController = errorVC
        } else {
            errorViewController?.view.removeFromSuperview()
        }
        
        if let errorViewController = errorViewController {
            
            webView.scrollView.addSubview(errorViewController.view!)
            
            if let mainBundleImage = UIImage(named: "Error-HTTP",
                in: Bundle.main,
                compatibleWith: nil) {
                    errorViewController.imageView.image = mainBundleImage
            } else if let neemanBundleImage = UIImage(named: "Error-HTTP",
                in: Bundle(for: WebViewController.self),
                compatibleWith: nil) {
                    errorViewController.imageView.image = neemanBundleImage
            }
            
            errorViewController.label.text = error.description
            
            self.addChildViewController(errorViewController)
        }
        
    }

}
