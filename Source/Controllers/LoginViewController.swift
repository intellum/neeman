import Foundation
import UIKit
import OnePasswordExtension
import SafariServices

class LoginViewController: UIViewController, OperationObserver, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var onePasswordButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var formWidthConstraint: NSLayoutConstraint!
   
    var operationQueue: OperationQueue?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        operationQueue = OperationQueue()
        
        let onePasswordAvailable = OnePasswordExtension.sharedExtension().isAppExtensionAvailable()
        onePasswordButton.hidden = !onePasswordAvailable
        
//        usernameTextField.text = "dinesh@piedpiper.com"
//        passwordTextField.text = "st3ph3n"
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification,
            object: nil)
        
        if let localLogo = UIImage(named: "Logo", inBundle: NSBundle.mainBundle(), compatibleWithTraitCollection: nil) {
            logoImageView.image = localLogo
        }
    }
    
    @IBAction func didTapLoginButton(sender: AnyObject) {
        let username = self.usernameTextField.text
        let password = self.passwordTextField.text
        let appName = Settings.sharedInstance.appName
        
        let loginOperation = LoginOperation(appName:appName, username: username!, password: password!)
        loginOperation.addObserver(self)
        operationQueue?.addOperation(loginOperation)
        activityIndicator.startAnimating()
        self.loginButton.hidden = true
    }
    
    @IBAction func didTapForgotPassword(sender: AnyObject) {

        let appName = Settings.sharedInstance.appName
        let urlString = Settings.sharedInstance.recoverPasswordURL + appName

        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(URL: NSURL(string: urlString)!)
            self.navigationController?.pushViewController(svc, animated: true)
        } else {
            let url = NSURL(string: urlString)!
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    // MARK: Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject] else {
            return
        }
        
        if let sizeValue = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue {
            let size = sizeValue.size
            let contentInset = UIEdgeInsetsMake(0, 0, size.height, 0)
            self.scrollView.contentInset = contentInset
            self.scrollView.scrollIndicatorInsets = contentInset

            let submitFrame = scrollView.convertRect(loginButton.frame, fromView: loginButton.superview)
            let height = scrollView.frame.height - size.height - submitFrame.size.height - 40
            let distanceNeededForSubmit = submitFrame.origin.y - height
            if distanceNeededForSubmit > 0 {

                UIView.animateWithDuration(0.4, delay: 0, options: .BeginFromCurrentState, animations: {
                    self.scrollView.contentOffset = CGPointMake(0, distanceNeededForSubmit)
                    self.view.layoutIfNeeded()
                    }, completion: nil)
            }

        }
        

    }

    func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    // MARK: TextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let _ = usernameTextField.text,
            _ = passwordTextField.text {
            didTapLoginButton(textField)
        }
        return true
    }

    // MARK: OperationObserver
    
    func operationDidStart(operation: Operation) {
        
    }
    
    func operation(operation: Operation, didProduceOperation newOperation: NSOperation) {
        
    }
    
    func operationDidFinish(operation: Operation, errors: [NSError]) {
        if let loginOperation = operation as? LoginOperation {
            print(loginOperation.authToken)
        }

        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if errors.isEmpty {
                self.dismissViewControllerAnimated(true, completion: nil)
                NSNotificationCenter.defaultCenter().postNotificationName(WebViewControllerDidLogin, object: self)
            } else {
                print(errors)
                self.loginButton.hidden = false
            }
            self.activityIndicator.stopAnimating()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let contentWidth = CGRectGetWidth(self.view.frame)
        let horiPadding = (contentWidth - formWidthConstraint.constant) / 2
        leftConstraint.constant = horiPadding
        rightConstraint.constant = horiPadding
    }
    
    // MARK: One Password
    
    @IBAction func didTapOnePassword(sender: AnyObject) {
        OnePasswordExtension.sharedExtension().findLoginForURLString(Settings.sharedInstance.baseURL, forViewController: self, sender: sender) {
            (loginDictionary: [NSObject : AnyObject]?, error: NSError?) -> Void in
            
                guard let username = loginDictionary?[AppExtensionUsernameKey] as? String else {
                    return
                }
                guard let password = loginDictionary?[AppExtensionPasswordKey] as? String else {
                    return
                }
                self.usernameTextField.text = username
                self.passwordTextField.text = password
                self.didTapLoginButton(sender)
        }
    }
    
    @IBAction func populateFieldsFromOnePassword(sender: UIButton) {
        OnePasswordExtension.sharedExtension().findLoginForURLString("https://izea.com", forViewController: self,
            sender: sender) { (credentials, error) -> Void in
                guard error == nil else {
                    print("Error: \(error)")
                    return
                }
                
                guard let credentials = credentials where credentials.count > 0 else {
                    print("No credentials selected")
                    return
                }
                
                self.usernameTextField.text = credentials[AppExtensionUsernameKey] as? String ?? ""
                self.passwordTextField.text = credentials[AppExtensionPasswordKey] as? String ?? ""
                
                self.didTapLoginButton(self)
        }
    }
}
