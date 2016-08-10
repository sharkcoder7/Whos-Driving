import UIKit

/**
 *  View model for a cell used in a menu table view.
 */
struct MenuCellViewModel {

    // MARK: Instance methods
    
    /**
    The UITableViewCellAccessoryType for the cell.
    
    - returns: The accessory type for the cell.
    */
    func accessoryType() -> UITableViewCellAccessoryType {
        return UITableViewCellAccessoryType.DisclosureIndicator
    }
    
    /**
     The background color for the cell.
     
     - returns: Background color.
     */
    func backgroundColor() -> UIColor {
        return UIColor.clearColor()
    }
    
    /**
     The font for the cell.
     
     - returns: The font for the cell.
     */
    func font() -> UIFont? {
        return UIFont(name: Font.HelveticaNeueMedium, size: 12)
    }
    
    /**
     The text color for the cell.
     
     - returns: Text color.
     */
    func textColor() -> UIColor {
        return AppConfiguration.darkGray()
    }
}
