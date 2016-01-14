import UIKit

extension WebViewController {
    
    /**
      This can be overridden to display error messages received from the web view. 
     The default implementation sets the `navigationItem.prompt`
     */
    public func setErrorMessage(message: String?) {
        navigationItem.prompt = message
    }
    
    /**
     Adds an image view which shows how to set the rootURLString.
     */
    func showURLError() {
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = .ScaleAspectFit
        imageView.image = UIImage(named: "Help-URL", inBundle: NSBundle(forClass: WebViewController.self), compatibleWithTraitCollection: nil)
        view.addSubview(imageView)
    }
    
    /**
     Adds and image view which shows what to do when you are getting app transport security error.
     */
    func showSSLError() {
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = .ScaleAspectFit
        imageView.image = UIImage(named: "Help-Security",
            inBundle: NSBundle(forClass: WebViewController.self),
            compatibleWithTraitCollection: nil)
        view.addSubview(imageView)
    }
}
