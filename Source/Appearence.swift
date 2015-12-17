import UIKit

public class Appearence {
    public static let sharedInstance = Appearence()
    
    public func setup() {
        if let backgroundImage = gradientImageWithBounds(CGSizeMake(800, 800)) {
            let stretchyImage = backgroundImage.stretchableImageWithLeftCapWidth(0, topCapHeight: 0)
            UINavigationBar.appearance().setBackgroundImage(stretchyImage, forBarMetrics: .Default)
            UINavigationBar.appearance().tintColor = UIColor.whiteColor()
            UINavigationBar.appearance().translucent = false
        }
        UITabBar.appearance().tintColor = Settings.sharedInstance.color1
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
    
        if let font = UIFont(name: "BrandonGrotesque-Black", size: 16) {
            UINavigationBar.appearance().titleTextAttributes = [
                NSFontAttributeName : font,
                NSKernAttributeName: 2,
                NSForegroundColorAttributeName : UIColor.whiteColor()
            ]
        }
    }
    
    func gradientImageWithBounds(size: CGSize) -> UIImage? {

        guard let gradient = gradient() else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.mainScreen().scale)
        let currentContext = UIGraphicsGetCurrentContext()
        CGContextSaveGState(currentContext)
        
        let startPoint = CGPointMake(0, size.height)
        let endPoint = CGPointMake(size.width, size.height)
        let options = CGGradientDrawingOptions(rawValue: 0)
        CGContextDrawLinearGradient(currentContext, gradient, startPoint, endPoint, options)
        let outImage = UIGraphicsGetImageFromCurrentImageContext()
        
        CGContextRestoreGState(currentContext)

        return outImage
    }
    
    func gradient() -> CGGradient? {
        guard let startColor = Settings.sharedInstance.color1 else {
            return nil
        }
        guard let endColor = Settings.sharedInstance.color2 else {
            return nil
        }

        let locations: [CGFloat] = [0.0, 1.0]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let startColorComponents = CGColorGetComponents(startColor.CGColor)
        let endColorComponents = CGColorGetComponents(endColor.CGColor)
        let colorComponents = [
            startColorComponents[0], startColorComponents[1], startColorComponents[2], startColorComponents[3],
            endColorComponents[0], endColorComponents[1], endColorComponents[2], endColorComponents[3]
        ]
        return CGGradientCreateWithColorComponents(colorSpace, colorComponents, locations, 2)
    }
}
