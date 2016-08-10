import Foundation
import UIKit

extension Bool {
    
    /**
    Returns the string representation of the bool.
    
    - returns: The string representation of the bool.
    */
    func stringValue() -> String {
        let boolString = self ? "true" : "false"
        
        return boolString
    }
}

extension Dictionary {
    
    /**
    Adds the contents of the provided Dictionary to the receiver.
    
    - parameter other A dictionary to add to the receiver.
    */
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            updateValue(value, forKey:key)
        }
    }
}

extension String {
    
    /**
     Trims leading and trailing whitespace characters.
     
     - returns: Trimmed version of the string.
     */
    func trimmedString() -> String {
        return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    /**
    Trims the string of leading and trailing whitespace characters. If no characters are left after 
    the trim, returns nil.
    
    - returns: Trimmed version of the string, or nil.
    */
    func trimmedStringOrNil() -> String? {
        let trimmedString = stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if trimmedString.characters.count > 0 {
            return trimmedString
        } else {
            return nil
        }
    }
}

extension UIColor {
    
    class func colorWith256Components(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
}

extension UIDevice {
    
    /// The identifier of the device. For example, "iPhone4,1" for an iPhone4s.
    var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
}

extension UIImage {
    
    /**
     Returns a UIImage filled with the provided color.
     
     - parameter color Color to fill the UIImage with.
     
     - returns: UIImage filled with the provided color.
     */
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension UIViewController {
    
    /// True if the receiver is the root view controller of its navigationController. If not, or
    /// there is no navigationController, is false.
    var isRootViewController: Bool {
        get {
            if navigationController?.viewControllers.first == self {
                return true
            } else {
                return false
            }
        }
    }
}