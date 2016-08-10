import UIKit

/// The view model for the ResponseConfirmationView.
struct ResponseConfirmationViewModel {

    // MARK: Private properties
    
    /// The ResponseConfirmation represented by this view.
    let response: ResponseConfirmation
    
    // MARK: Init and deinit methods
    
    /**
    Returns a newly configured instance of this class.
    
    - parameter response The ResponseConfirmation used to determine what to return for the various 
                         instance methods.
    
    - returns: Configured instance of this class.
    */
    init(response: ResponseConfirmation) {
        self.response = response
    }
    
    // MARK: Instance methods
    
    /**
    The attributed text to display.
    
    - returns: Attributed text to display as the main text.
    */
    func attributedText() -> NSAttributedString {
        let text = self.text()
        
        let textColor = AppConfiguration.white()
        let fontSize: CGFloat = 14.0
        let regularTextAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueLight, size: fontSize)!]
        
        let attributedText = NSMutableAttributedString(string: text, attributes: regularTextAttributes)
        
        if let emphasizedString = emphasizedText() {
            let boldTextAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueMedium, size: fontSize)!]
            let range  = (text as NSString).rangeOfString(emphasizedString)
            
            attributedText.addAttributes(boldTextAttributes, range: range)
        }
        
        return attributedText
    }
    
    /**
     The background color.
     
     - returns: The background color.
     */
    func backgroundColor() -> UIColor {
        switch response {
        case .BothSuccess, .FromSuccess, .ToSuccess:
            return AppConfiguration.blue()
            
        case .CannotSuccess:
            return AppConfiguration.mediumGray()
            
        case .CanPartialSuccess, .CanFailed:
            return AppConfiguration.yellow()
        }
    }
    
    /**
     Returns the image to display at the top of the view.
     
     - returns: The image to display.
     */
    func image() -> UIImage {
        switch response {
        case .CanPartialSuccess:
            return UIImage(named: "header-face-white")!
            
        default:
            return UIImage(named: "header-check")!
        }
    }
    
    /**
     The title to display.
     
     - returns: The title.
     */
    func title() -> String {
        switch response {
        case .BothSuccess, .FromSuccess, .ToSuccess:
            return "You're Driving!"
            
        case .CanFailed:
            return "Someone beat you to it!"
            
        case .CannotSuccess:
            return "Got it."
            
        case .CanPartialSuccess:
            return "You are driving one way."
        }
    }
    
    // MARK: Private methods
    
    /**
    The text to be emphasized from -text().
    
    - returns: The text to be emphasized.
    */
    private func emphasizedText() -> String? {
        switch response {
        case .BothSuccess:
            return "You are driving TO and FROM the activity,"
            
        case .FromSuccess:
            return "You are driving FROM the activity,"
            
        case .ToSuccess:
            return "You are driving TO the activity,"
            
        default:
            return nil
        }
    }
    
    /**
     The plain text version of -attributedText. Use -emphasizedText() to determine what text should
     be emphasized.
     
     - returns: The plain text version of the attributed text to be displayed.
     */
    private func text() -> String {
        switch response {
        case .BothSuccess:
            return "You are driving TO and FROM the activity,\nand your carpool has been notified."
            
        case .CanFailed:
            return "Between the time you received the notification\nand now, someone already volunteered to drive.\n\nYou will not be a driver on this carpool."
            
        case .CannotSuccess:
            return "We've made a note that you\ncannot drive for this carpool!"
            
        case .CanPartialSuccess:
            return "Between the time you received the notification\nand now, someone already volunteered to drive\nfor part of this carpool. Scroll down for details."
            
        case .FromSuccess:
            return "You are driving FROM the activity,\nand your carpool has been notified."
            
        case .ToSuccess:
            return "You are driving TO the activity,\nand your carpool has been notified."
        }
    }
}
