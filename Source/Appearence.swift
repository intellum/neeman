import UIKit

public class Appearence {
    public static let sharedInstance = Appearence()
    
    public func setup()
    {
        let backgroundImage = gradientImageWithBounds(CGSizeMake(800, 800))
        UINavigationBar.appearance().setBackgroundImage(backgroundImage, forBarMetrics: .Default)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().translucent = false
        UITabBar.appearance().tintColor = Settings.sharedInstance.color1
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
    
        if let font = UIFont(name: "BrandonGrotesque-Black", size: 16) {
            UINavigationBar.appearance().titleTextAttributes = [
                NSFontAttributeName : font,
                NSKernAttributeName: 2,
                NSForegroundColorAttributeName : UIColor.whiteColor()
            ]
        }
//        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    }
    
    func gradientImageWithBounds(size:CGSize) -> UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.mainScreen().scale)

        let currentContext = UIGraphicsGetCurrentContext()
        
        // 2
        CGContextSaveGState(currentContext);
        
        // 3
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // 4
        guard let startColor = Settings.sharedInstance.color1 else {
            return nil
        }
        guard let endColor = Settings.sharedInstance.color2 else {
            return nil
        }
        
        let startColorComponents = CGColorGetComponents(startColor.CGColor)
        let endColorComponents = CGColorGetComponents(endColor.CGColor)
        
        // 5
        let colorComponents
        = [startColorComponents[0], startColorComponents[1], startColorComponents[2], startColorComponents[3], endColorComponents[0], endColorComponents[1], endColorComponents[2], endColorComponents[3]]
        
        // 6
        let locations:[CGFloat] = [0.0, 1.0]
        
        // 7
        let gradient = CGGradientCreateWithColorComponents(colorSpace,colorComponents,locations,2)
        
        let startPoint = CGPointMake(0, size.height)
        let endPoint = CGPointMake(size.width, size.height)
        
        // 8
        let options = CGGradientDrawingOptions(rawValue: 0)
        CGContextDrawLinearGradient(currentContext,gradient,startPoint,endPoint, options)
        
        let outImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 9
        CGContextRestoreGState(currentContext);

        return outImage
    }
}
