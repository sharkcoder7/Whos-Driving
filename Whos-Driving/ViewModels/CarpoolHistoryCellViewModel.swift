import UIKit

/// View model for the CarpoolHistoryCell
struct CarpoolHistoryCellViewModel {
    
    // MARK: Private properties
    
    /// The EventHistoryItem used to determine what to return in the various view model methods.
    private let historyItem: EventHistoryItem
    
    // MARK: Init and deinit methods
    
    /**
    Initializes an instance of this class with the provided EventHistoryItem.
    
    - parameter item The EventHistoryItem used to determine what the view model methods should
                     return.
    
    - returns: Configured instance of this class.
    */
    init(item: EventHistoryItem) {
        historyItem = item
    }
    
    // MARK: Instance methods
    
    /**
     Returns the text to display in the dateLabel.
    
    - returns: Text for the dateLabel.
    */
    func dateLabelText() -> String {
        guard let date = historyItem.date else {
            return ""
        }
        
        let timeDateFormatter = NSDateFormatter()
        timeDateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let timeString = timeDateFormatter.stringFromDate(date).lowercaseString

        let dayDateFormatter = NSDateFormatter()
        dayDateFormatter.dateFormat = "MMM dd"
        let dayString = dayDateFormatter.stringFromDate(date)
        
        return "\(timeString) on \(dayString)"
    }
    
    /**
     Returns the text to display in the first letter label.
     
     - returns: Text for the first letter label.
     */
    func firstLetterText() -> String {
        if historyItem.authorName.characters.count > 0 {
            return (historyItem.authorName as NSString).substringToIndex(1).uppercaseString
        } else {
            return ""
        }
    }
    
    /**
     Returns the attributed text to display in the message label.
     
     - returns: Attributed text for the message label.
     */
    func messageAttributedText() -> NSAttributedString {
        let fontSize: CGFloat = 14.0
        let textColor = AppConfiguration.black()
        
        let message = "\(historyItem.authorName) \(historyItem.message)"
        
        let regularAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueLight, size: fontSize)!]
        let messageAttributedString = NSMutableAttributedString(string: message, attributes: regularAttributes)
        
        let nameRange = (message as NSString).rangeOfString(historyItem.authorName)
        let dayAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueRegular, size: fontSize)!]
        messageAttributedString.addAttributes(dayAttributes, range: nameRange)
        
        return messageAttributedString
    }
}
