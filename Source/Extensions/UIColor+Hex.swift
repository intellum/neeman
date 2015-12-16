import UIKit

extension UIColor {
    
    convenience init(hex: String) {
        
        var cString: String = (hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString)
        
        if cString.hasPrefix("#") {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        var r: CUnsignedInt = 255, g: CUnsignedInt = 255, b: CUnsignedInt = 255
        if cString.characters.count == 6 {
            let rString = (cString as NSString).substringToIndex(2)
            let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
            let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
            
            NSScanner(string: rString).scanHexInt(&r)
            NSScanner(string: gString).scanHexInt(&g)
            NSScanner(string: bString).scanHexInt(&b)
        }

        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
        
    }
    
}
