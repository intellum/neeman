import UIKit

extension WebViewController {
    
    public func setErrorMessage(message: String?) {
        self.navigationItem.prompt = message
    }
    
    func showURLError() {
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = .ScaleAspectFit
        imageView.image = UIImage(named: "Help-URL", inBundle: NSBundle(forClass: WebViewController.self), compatibleWithTraitCollection: nil)
        self.view.addSubview(imageView)
    }
    
    func showSSLError() {
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = .ScaleAspectFit
        imageView.image = UIImage(named: "Help-Security",
            inBundle: NSBundle(forClass: WebViewController.self),
            compatibleWithTraitCollection: nil)
        self.view.addSubview(imageView)
    }
}
