import UIKit

/// This class has convenience methods for the colors used in the app and commonly used NSDateFormatters.
class AppConfiguration: NSObject {
    
    // MARK: Class methods - colors
    
    /**
    Returns the black color used in the app.
    
    - parameter alpha The alpha value to use for the color. Defauls to 1.0.
    
    - returns: The black color.
    */
    static func black(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor.colorWith256Components(0, green: 0, blue: 0, alpha: alpha)
    }
    
    /**
     Returns the blue color used in the app.
     
     - parameter alpha The alpha value to use for the color. Defauls to 1.0.
     
     - returns: The blue color.
     */
    static func blue(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor.colorWith256Components(69, green: 146, blue: 194, alpha: alpha)
    }

    /**
     Returns the dark gray color used in the app.
     
     - parameter alpha The alpha value to use for the color. Defauls to 1.0.
     
     - returns: The dark gray color.
     */
    static func darkGray(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor.colorWith256Components(102, green: 102, blue: 102, alpha: alpha)
    }

    /**
     Returns the light gray color used for disabled elements in the app.
     
     - parameter alpha The alpha value to use for the color. Defauls to 1.0.
     
     - returns: The disabled light gray color.
     */
    static func disabledLightGray(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor.colorWith256Components(221, green: 221, blue: 221, alpha: alpha)
    }

    /**
     Returns the green color used in the app.
     
     - parameter alpha The alpha value to use for the color. Defauls to 1.0.
     
     - returns: The green color.
     */
    static func green(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor.colorWith256Components(80, green: 168, blue: 84, alpha: alpha)
    }

    /**
     Returns the light blue color used in the app.
     
     - parameter alpha The alpha value to use for the color. Defauls to 1.0.
     
     - returns: The light blue color.
     */
    static func lightBlue(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor.colorWith256Components(93, green: 161, blue: 202, alpha: alpha)
    }

    /**
     Returns the light gray color used in the app.
     
     - parameter alpha The alpha value to use for the color. Defauls to 1.0.
     
     - returns: The light gray color.
     */
    static func lightGray(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor.colorWith256Components(204, green: 204, blue: 204, alpha: alpha)
    }

    /**
     Returns the medium gray color used in the app.
     
     - parameter alpha The alpha value to use for the color. Defauls to 1.0.
     
     - returns: The medium gray color.
     */
    static func mediumGray(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor.colorWith256Components(170, green: 170, blue: 170, alpha: alpha)
    }
    
    /**
     Returns the off white color used in the app.
     
     - parameter alpha The alpha value to use for the color. Defauls to 1.0.
     
     - returns: The off white color.
     */
    static func offWhite(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor.colorWith256Components(250, green: 250, blue: 250, alpha: alpha)
    }
    
    /**
     Returns the red color used in the app.
     
     - parameter alpha The alpha value to use for the color. Defauls to 1.0.
     
     - returns: The red color.
     */
    static func red(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor.colorWith256Components(207, green: 52, blue: 61, alpha: alpha)
    }
    
    /**
     Returns the light blue color used for updated elements in the app.
     
     - parameter alpha The alpha value to use for the color. Defauls to 1.0.
     
     - returns: The light blue color used for updated elements.
     */
    static func updatedLightBlue(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor.colorWith256Components(92, green: 186, blue: 243, alpha: alpha)
    }
    
    /**
     Returns the white color used in the app.
     
     - parameter alpha The alpha value to use for the color. Defauls to 1.0.
     
     - returns: The white color.
     */
    static func white(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor.colorWith256Components(255, green: 255, blue: 255, alpha: alpha)
    }
    
    /**
     Returns the yellow color used in the app.
     
     - parameter alpha The alpha value to use for the color. Defauls to 1.0.
     
     - returns: The yellow color.
     */
    static func yellow(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor.colorWith256Components(246, green: 216, blue: 48, alpha: alpha)
    }
    
    // MARK: Class methods - date formatting
    
    /**
    Returns the NSDateFormatter commonly used for dates being displayed.
    
    - returns: The NSDateFormatter for dates being displayed.
    */
    static func displayDateFormatter() -> NSDateFormatter {
        let displayDateFormatter = NSDateFormatter()
        displayDateFormatter.dateFormat = "EEE MMM dd h:mm a"
        
        return displayDateFormatter
    }
    
    /**
     Returns the NSDateFormatter configured how the server formats dates.
     
     - returns: The NSDateFormatter used to communicate with the server.
     */
    static func webServiceDateFormatter() -> NSDateFormatter {
        let webServiceDateFormatter = NSDateFormatter()
        webServiceDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        webServiceDateFormatter.timeZone = NSTimeZone(name: "UTC")
        
        return webServiceDateFormatter
    }
    
    // MARK: Class methods - UI
    
    /**
    The border width to use for <= 1 pixel borders. Based on the current device's screen scale.
    
    - returns: The border width to use for thin borders.
    */
    static func borderWidth() -> CGFloat {
        return 1.0 / UIScreen.mainScreen().scale
    }
}
