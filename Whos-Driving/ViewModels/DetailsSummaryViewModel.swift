import UIKit

/**
 *  View model for the DetailsSummaryView.
 */
struct DetailsSummaryViewModel {
    
    // MARK: Private Properties
    
    /// Date formatter for showing the month and day of a date.
    private let dayDateFormatter = NSDateFormatter()
    
    /// Date formatter for showing the year, month and day of a date.
    private let dayDateYearFormatter = NSDateFormatter()
    
    /// The Event being shown in the DetailsSummaryView.
    private let event: Event
    
    /// Date formatter for showing a time string.
    private let timeDateFormatter = NSDateFormatter()
    
    // MARK: Init Methods
    
    /**
    Creates a configured instance of this class with the provided event.
    
    - parameter anEvent The Event being displayed in the DetailsSummaryView.
    
    - returns: Configured instance of this class.
    */
    init(event anEvent: Event) {
        event = anEvent
                
        dayDateFormatter.dateFormat = "MMMM dd"
        dayDateYearFormatter.dateFormat = "MMMM dd, YYYY"
        timeDateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    }
    
    // MARK: Instance Methods
    
    /**
    Returns the text to display for the date and time of the event, using the provided font size.
    
    - parameter fontSize Font size to use.
    
    - returns: Text to display for the date and time of the event.
    */
    func attributedDateTimeStringOfSize(fontSize: CGFloat) -> NSAttributedString {
        let startDay = dayDateYearFormatter.stringFromDate(event.startTime)
        let endDay = dayDateYearFormatter.stringFromDate(event.endTime)
        let endDayShort = dayDateFormatter.stringFromDate(event.endTime)
        let startTime = timeDateFormatter.stringFromDate(event.startTime).lowercaseString
        let endTime = timeDateFormatter.stringFromDate(event.endTime).lowercaseString
        let at = "at"
        
        let fontSize = fontSize
        let textColor = AppConfiguration.black()
        
        let thinAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueThin, size: fontSize)!]
        let lightAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueLight, size: fontSize)!]
        let regAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueRegular, size: fontSize)!]

        let dateTimeAttributedString = NSMutableAttributedString()
        
        let startDayAttributed = NSAttributedString(string: "\(startDay) ", attributes: regAttributes)
        dateTimeAttributedString.appendAttributedString(startDayAttributed)
        
        let atAttributed = NSAttributedString(string: "\(at) ", attributes: thinAttributes)
        dateTimeAttributedString.appendAttributedString(atAttributed)
        
        let startTimeAttributed = NSAttributedString(string: "\(startTime) - ", attributes: lightAttributes)
        dateTimeAttributedString.appendAttributedString(startTimeAttributed)
        
        if startDay != endDay {
            let endDayAttributed = NSMutableAttributedString(string: "\(endDayShort) ", attributes: regAttributes)
            endDayAttributed.appendAttributedString(atAttributed)
            dateTimeAttributedString.appendAttributedString(endDayAttributed)
        }
        
        let endTimeAttributed = NSAttributedString(string: endTime, attributes: lightAttributes)
        dateTimeAttributedString.appendAttributedString(endTimeAttributed)
        
        return dateTimeAttributedString
    }
    
    /**
     Returns the text to display for the location of the event.
     
     - returns: Text for the location of the event.
     */
    func attributedLocationString() -> NSAttributedString {
        let at = "At"
        let location = locationString()
        let atLocationString = "\(at) \(location)"
        
        let textColor = AppConfiguration.black()
        let fontSize: CGFloat = 13.0
        
        let locationAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueLight, size: fontSize)!]
        let atLocationAttributedString = NSMutableAttributedString(string: atLocationString, attributes: locationAttributes)
        
        let atAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueRegular, size: fontSize)!]
        let atRange = (atLocationString as NSString).rangeOfString(at)
        atLocationAttributedString.addAttributes(atAttributes, range: atRange)
        
        return atLocationAttributedString
    }
    
    /**
     Plain string version of the event location.
     
     - returns: String version of the event location.
     */
    func locationString() -> String {
        var locationString: String
        
        if let location = event.location {
            locationString = location
        } else {
            locationString = ""
        }
        
        return locationString
    }
    
    /**
     The name of the event to show.
     
     - returns: The name of the event.
     */
    func titleString() -> String {
        return event.name
    }
}