import UIKit

/**
 *  Generic view model used for displaying a driver.
 */
struct DriverViewModel {
    
    // MARK: Constants
    
    /// Text to display when a driver is needed.
    let DriverNeeded = "Driver Needed"
    
    /// Text to display instead of the current user's name.
    let Me = "Me"
    
    // MARK: Properties
    
    /**
    The driver to be represented by this view model. If nil, uses different values to show a
    driver is needed.
    */
    var driver: Person?
   
    // MARK: Init and deinit methods
    
    /**
    Initializes a new instance of this class with a driver, or no driver if nil.
    
    - parameter driver The driver represented by this view model.
    
    - returns: A new instance of this class.
    */
    init(driver: Person?) {        
        self.driver = driver
    }
    
    // MARK: Instance methods
    
    /**
    The font to use for the driver's name.
    
    - returns: The font to use.
    */
    func font() -> UIFont? {
        if driver == nil {
            return UIFont(name: Font.HelveticaNeueMedium, size: 12.0)
        }
        else {
            return UIFont(name: Font.HelveticaNeueRegular, size: 12.0)
        }
    }
    
    /**
    The image to use for the image view.
    
    - returns: The image to use.
    */
    func image() -> UIImage {
        if driver == nil {
            return UIImage(named:"status-question")!
        }
        else if driver?.relationship == .CurrentUser {
            return UIImage(named:"status-car")!
        }
        else {
            return UIImage(named:"status-check")!
        }
    }
    
    /**
    The background color for the image view.
    
    - returns: Background color for the image view.
    */
    func imageBackground() -> UIColor {
        if driver == nil {
            return AppConfiguration.red()
        }
        else if driver?.relationship == .CurrentUser {
            return AppConfiguration.blue()
        }
        else {
            return AppConfiguration.green()
        }
    }
    
    /**
    The text to display in the name label.
    
    - returns: Text to display.
    */
    func text() -> String {
        if driver == nil {
            return DriverNeeded
        }
        else if driver?.relationship == .CurrentUser {
            return "Me"
        }
        else {
            return driver!.displayName
        }
    }
    
    /**
    Color to use for the drivers name.
    
    - returns: Color to use.
    */
    func textColor() -> UIColor {
        if driver == nil {
            return AppConfiguration.red()
        }
        else {
            return AppConfiguration.mediumGray()
        }
    }
}
