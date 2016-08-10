import UIKit

/// The view model for the DetailHeaderView
struct DetailHeaderViewModel {
    
    // MARK: Constants 
    
    /// Height from the tableview to the bottom of the view, including the submit button
    private let BottomSpace: CGFloat = 71.0
    
    /// Default height. Doesn't take into account height of the header label
    private let DefaultHeaderHeight: CGFloat = 18.0
    
    /// The height of table view rows.
    private let TableViewRowHeight: CGFloat = 44.0

    // MARK: Private properties 
    
    /// The EventDriverStatus used to determine what UI to show in the detail header view.
    private let driverStatus: EventDriverStatus
    
    /// Array of DriverStatus responses to show as options to the user. This controls what is shown
    /// in the table view when the show response view is expanded.
    private let responses: [DriverStatus]
    
    /// True if the view for responding to an event notification should be shown.
    private let showResponseView: Bool
    
    // MARK: Init and deinit methods
    
    /**
    Creates a new configured instance of this class.
    
    - parameter status The EventDriverStatus for this class.
    - parameter shouldShowResponseView True if the view for responding to an event notification
                should be shown.
    
    - returns: A configured instance of this class.
    */
    init(driverStatus status: EventDriverStatus, responses: [DriverStatus], shouldShowResponseView: Bool) {
        driverStatus = status
        showResponseView = shouldShowResponseView
        self.responses = responses        
    }
    
    // MARK: Instance methods
    
    /**
     The attributed text to show for the DriverStatus. This is displayed in the table view cells.
     
     - parameter status The DriverStatus that text is needed for.
     
     - returns: Text to be shown in a table view cell for the DriverStatus.
     */
    func attributedTextForResponse(status: DriverStatus) -> NSAttributedString {
        let textColor = AppConfiguration.darkGray()
        let fontSize: CGFloat = 14.0
        let regularTextAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueLight, size: fontSize)!]
        let boldTextAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueBold, size: fontSize)!]
        
        let text = textForStatus(status)
        let attributedText = NSMutableAttributedString(string: text, attributes: regularTextAttributes)
        
        // always bold TO, FROM, and CANNOT
        let to = "TO"
        let toRange = (text as NSString).rangeOfString(to)
        attributedText.addAttributes(boldTextAttributes, range: toRange)
        
        let from = "FROM"
        let fromRange = (text as NSString).rangeOfString(from)
        attributedText.addAttributes(boldTextAttributes, range: fromRange)
        
        let cannot = "CANNOT"
        let cannotRange = (text as NSString).rangeOfString(cannot)
        attributedText.addAttributes(boldTextAttributes, range: cannotRange)
        
        return attributedText
    }
    
    /**
     The background color for the view.
     
     - returns: The background color.
     */
    func backgroundColor() -> UIColor {
        switch driverStatus {
        case .NoDrivers:
            return AppConfiguration.red()
            
        case .BothDrivers:
            return AppConfiguration.white()
            
        case .NoDriverFrom, .NoDriverTo:
            return AppConfiguration.yellow()
        }
    }
    
    /**
     The height of the header view, based on the width provided. The width should be the width the
     header label will be so the view can determine how much space is needed for the header label text.
     
     - parameter width The width of the header label.
     
     - returns: The total height for the view.
     */
    func headerHeightForLabelWidth(width: CGFloat) -> CGFloat {
        if driverStatus == EventDriverStatus.BothDrivers {
            return 0.0
        }
        
        let attributedText = headerLabelAttributedText()
        let rect = attributedText.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        let headerLabelHeight = rect.size.height
        
        var headerHeight = DefaultHeaderHeight + headerLabelHeight
        
        // If "responses" is 0, the server hasn't returned responses yet
        if responses.count == 0 {
            return headerHeight
        }
        
        if showResponseView && responses.count > 0 {
            let responseViewHeight = tableViewHeight() + BottomSpace
            headerHeight += responseViewHeight
        }
        
        return headerHeight
    }
    
    /**
     The attributed text to display in the headerLabel.
     
     - returns: Attributed text to display in the headerLabel.
     */
    func headerLabelAttributedText() -> NSAttributedString {
        let textColor = AppConfiguration.white()
        let fontSize: CGFloat = 14.0
        let regularTextAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueRegular, size: fontSize)!]
        let mediumTextAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueBold, size: fontSize)!]
        
        let text = headerLabelText()
        let emphasizedText = emphasizedHeaderLabelText()
        let emphasizedRange = (text as NSString).rangeOfString(emphasizedText)
        
        let mutableHeaderText = NSMutableAttributedString(string: text, attributes: regularTextAttributes)
        mutableHeaderText.addAttributes(mediumTextAttributes, range: emphasizedRange)
        
        return mutableHeaderText
    }
    
    /**
     The height of the table view, based on how many rows there are for the driverStatus.
     
     - returns: The height of the table view.
     */
    func tableViewHeight() -> CGFloat {
        let rows = CGFloat(responses.count)
        
        return rows * TableViewRowHeight
    }
    
    // MARK: Private methods
    
    /**
    The text to emphasize in the headerLabel attributed text.
    
    - returns: The text to be emphasized.
    */
    private func emphasizedHeaderLabelText() -> String {
        if showResponseView {
            return "Respond:"
        } else {
            return ""
        }
    }
    
    /**
     The plain string version of the text for the header label. Use emphasizedHeaderLabelText to determine
     what text should be emphasized from these strings.
     
     - returns: The plain string version of the text for the header label.
     */
    private func headerLabelText() -> String {
        if showResponseView {
            switch driverStatus {
            case .NoDrivers:
                return "This carpool needs 2 drivers! Respond:"
                
            case .BothDrivers:
                return ""
                
            case .NoDriverFrom, .NoDriverTo:
                return "This carpool needs 1 more driver! Respond:"
            }
        } else {
            switch driverStatus {
            case .NoDrivers:
                return "This carpool needs 2 drivers!"
                
            case .BothDrivers:
                return ""
                
            case .NoDriverFrom, .NoDriverTo:
                return "This carpool needs 1 more driver!"
            }
        }
    }
    
    /**
     The plain text version of the text for a DriverStatus.
     
     - parameter response The DriverStatus to return text for.
     
     - returns: The text for the response.
     */
    private func textForStatus(status: DriverStatus) -> String {
        switch status {
        case .CanDriveToAndFrom:
            return "I can drive TO and FROM the activity"
        case .CanDriveFrom, .CanDriveFromNotTo:
            return "I can drive FROM the activity"
        case .CanDriveTo, .CanDriveToNotFrom:
            return "I can drive TO the activity"
        case .CannotDriveFrom, .CannotDriveTo, .CannotDriveToAndFrom:
            return "I CANNOT drive"
        }
    }
}
