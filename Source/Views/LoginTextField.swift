import UIKit

class LoginTextField: UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        leftView = UIView(frame: CGRectMake(0, 0, 10, 40))
        leftViewMode = .Always
        layer.cornerRadius = 5
    }
}
