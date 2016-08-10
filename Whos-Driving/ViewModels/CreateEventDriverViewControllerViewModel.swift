import UIKit

/**
 *  View model for the CreateEventDriverViewController
 */
struct CreateEventDriverViewControllerViewModel {
    
    // MARK: Private properties
    
    /// The EventFactory for the event being created.
    private let eventFactory: EventFactory
    
    /// True if the screen is for the "to" leg of the event.
    private let isDrivingTo: Bool
    
    // MARK: Init and deinit methods
    
    /**
    Creates a configured instance of this class.
    
    - parameter eventFactory The EventFactory for the event being created.
    - parameter isDrivingTo True if this view model is for the "to" leg of the event.
    
    - returns: Configured instance of this class.
    */
    init(eventFactory: EventFactory, isDrivingTo: Bool) {
        self.isDrivingTo = isDrivingTo
        self.eventFactory = eventFactory        
    }
    
    // MARK: Instance methods
    
    /**
    The text to display in the header detail.
    
    - returns: Text for the header detail.
    */
    func headerDetailText() -> String {
        let date = isDrivingTo ? eventFactory.startTime : eventFactory.endTime

        let dateFormatter = NSDateFormatter()
        dateFormatter.AMSymbol = "am"
        dateFormatter.PMSymbol = "pm"
        dateFormatter.dateFormat = "h:mma"
        let dateString = dateFormatter.stringFromDate(date!)
        let eventName = eventFactory.name
        let startsOrEnds = isDrivingTo ? "starts" : "ends"
        let detailText = "\(eventName!) \(startsOrEnds) at \(dateString)"
        
        return detailText
    }
   
    /**
     The text to display in the header title.
     
     - returns: Text for the header title.
     */
    func headerTitle() -> NSAttributedString {
        let drivingString = isDrivingTo ? "Driving To " : "Driving From "
        let drivingAttributes = [NSForegroundColorAttributeName : AppConfiguration.white(), NSFontAttributeName : UIFont(name: Font.HelveticaNeueMedium, size: 22.5)!]
        let attributedDrivingString = NSMutableAttributedString(string: drivingString, attributes: drivingAttributes)
        
        let activityAttributes = [NSForegroundColorAttributeName : AppConfiguration.white(), NSFontAttributeName : UIFont(name: Font.HelveticaNeueLight, size: 22.5)!]
        let attributedActivityString = NSAttributedString(string: "the activity", attributes: activityAttributes)
        attributedDrivingString.appendAttributedString(attributedActivityString)
        
        return attributedDrivingString
    }
    
    /**
     Text to display in the whosDrivingLabel.
     
     - returns: Text for the whosDrivingLabel.
     */
    func whosDrivingText() -> NSAttributedString {
        let direction = isDrivingTo ? "TO" : "FROM"
        let whosDrivingString = "Who's driving \(direction) the activity?"
        let textAttributes = [NSForegroundColorAttributeName : AppConfiguration.darkGray(), NSFontAttributeName : UIFont(name: Font.HelveticaNeueMedium, size: 14)!]
        let attributedString = NSMutableAttributedString(string: whosDrivingString, attributes: textAttributes)
        
        let range = (whosDrivingString as NSString).rangeOfString(direction)
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: Font.HelveticaNeueBold, size: 14)!, range: range)
        
        return attributedString
    }
}
