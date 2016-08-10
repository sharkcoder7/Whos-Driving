import UIKit

/// View model for the EmptyStateView
struct EmptyStateViewModel {
    
    // MARK: Private properties
    
    /// This property powers this view model. Used to determine what attributes to return for all
    /// methods.
    private let style: EmptyStateStyle
    
    // MARK: Init and deinit methods
    
    /**
    Creates a new instance of this class with the provided style.
    
    - parameter style The style to determine what attributes to return for all methods.
    
    - returns: A new instance of this class with the provided style.
    */
    init(style: EmptyStateStyle) {
        self.style = style        
    }

    // MARK: Instance methods
    
    /**
    The image for the empty state view.
    
    - returns: The image for the empty state view.
    */
    func image() -> UIImage? {
        let image: UIImage?
        
        switch style {
        case .CarpoolsAlmostDone, .CarpoolsDone:
            image = UIImage(named: "ready-check")
        case .Drivers, .MyKids, .OtherKids:
            image = UIImage(named: "header-face")
        case .DriversInviteSent:
            image = UIImage(named: "header-check")?.imageWithRenderingMode(.AlwaysTemplate)
        }
        
        return image
    }
    
    /**
    The tint for the image view.
    
    - returns: The color to use to tint the image view.
    */
    func imageViewTint() -> UIColor {
        switch style {
        case .DriversInviteSent:
            return AppConfiguration.mediumGray()
        default:
            return UIColor.clearColor()
        }
    }
    
    /**
    The attributed text to display in the lower description label.
    
    - returns: The attributed text for the lower description label.
    */
    func lowerDescriptionAttributedText() -> NSAttributedString {
        let attributedText: NSMutableAttributedString
        
        let textColor = AppConfiguration.black()
        let fontSize: CGFloat = 14.0
        let regularTextAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueRegular, size: fontSize)!]
        let boldTextAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueBold, size: fontSize)!]

        switch style {
        case .CarpoolsAlmostDone:
            let text = "While you’re waiting, invite more drivers to carpool with you on the Drivers tab below!"
            attributedText = NSMutableAttributedString(string: text, attributes: regularTextAttributes)
        case .Drivers, .DriversInviteSent:
            let invite = "Invite"
            let text = "While you’re waiting, invite more drivers to carpool with you by clicking the \(invite) button in the upper right-hand corner."
            attributedText = NSMutableAttributedString(string: text, attributes: regularTextAttributes)
            let inviteRange = (text as NSString).rangeOfString(invite)
            attributedText.addAttributes(boldTextAttributes, range: inviteRange)
        default:
            let text = ""
            attributedText = NSMutableAttributedString(string: text, attributes: regularTextAttributes)
        }
        
        return attributedText
    }
    
    /**
    The text to display in the title label.
    
    - returns: The text for the title label.
    */
    func titleText() -> String {
        let text: String
        
        switch style {
        case .CarpoolsAlmostDone:
            text = "You're done!"
        case .CarpoolsDone:
            text = "You're ready to roll!"
        case .Drivers:
            text = "It's lonely in here!"
        case .DriversInviteSent:
            text = "Invite sent!"
        case .MyKids:
            text = "Add your kids!"
        case .OtherKids:
            text = "No other riders yet!"
        }
                
        return text
    }
    
    /**
    The color to use for the title label.
    
    - returns: The color for the title label.
    */
    func titleTextColor() -> UIColor {
        let color: UIColor
        
        switch style {
        case .CarpoolsAlmostDone, .CarpoolsDone:
            color = AppConfiguration.green()
        case .Drivers, .MyKids, .OtherKids:
            color = AppConfiguration.yellow()
        case .DriversInviteSent:
            color = AppConfiguration.black()
        }
        
        return color
    }
    
    /**
    The text to display in the upper description label.
    
    - returns: The text for the upper description label.
    */
    func upperDescriptionText() -> String {
        let text: String
        
        switch style {
        case .CarpoolsAlmostDone:
            text = "But, you need to be connected with at least one driver to setup a carpool. If you already invited someone, they may not have accepted your invitation yet."
        case .CarpoolsDone:
            text = "Click the + button in the upper right-hand corner to create your first carpool."
        case .Drivers:
            text = "You need to be connected with at least one driver to setup a carpool. If you already invited someone, they may not have accepted your invitation yet."
        case .DriversInviteSent:
            text = "It might take a while for the person you invited to create an account. You need to be connected with at least one driver to setup a carpool."
        case .MyKids:
            text = "Click the + button in the upper right-hand corner to add your kids."
        case .OtherKids:
            text = "None of your trusted drivers have added kids yet. You can still create carpools and edit who's riding later."
        }
        
        return text
    }
}