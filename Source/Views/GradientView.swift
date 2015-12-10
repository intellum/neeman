import UIKit

class GradientView: UIView {
    let gradient: CAGradientLayer = CAGradientLayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        guard let color1 = Settings.sharedInstance.color1 else {
            return
        }
        guard let color2 = Settings.sharedInstance.color2 else {
            return
        }
        
        gradient.frame = bounds
        gradient.colors = [
            color1.CGColor,
            color2.CGColor
        ]
        
        gradient.startPoint = CGPointMake(0, 0)
        gradient.endPoint = CGPointMake(1, 0)
        layer.insertSublayer(gradient, atIndex: 0)
        
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
}
