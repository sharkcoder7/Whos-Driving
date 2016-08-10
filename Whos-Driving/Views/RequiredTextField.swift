import Foundation
import UIKit

/// Instances of this class contain an indicator that indicate the field is required.
final class RequiredTextField: TextField {
    // MARK: Private Properties
    
    /// A label that indicates to the user that the field is required.
    private let requiredLabel = UILabel()
    
    // MARK: Init Methods
    
    /**
     This method is called when any other init method is called. Sets up the defaults properties and
     views.
     */
    override func commonInit() {
        super.commonInit()
        
        requiredLabel.text = "Required"
        requiredLabel.textColor = AppConfiguration.red()
        requiredLabel.translatesAutoresizingMaskIntoConstraints = false
        requiredLabel.font = UIFont(name: Font.HelveticaNeueMedium, size: 14.0)
        
        setRequiredLabelHidden(true, animated: false)
        
        addSubview(requiredLabel)
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[requiredLabel]-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["requiredLabel": requiredLabel]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[requiredLabel]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["requiredLabel": requiredLabel]))
    }
    
    // MARK: Instance Methods
    
    /**
     Calling this method adjusts whether or not the 'required' indicator is displayed.
     
     - parameter hidden:   a boolean that indicates if the indicator should be shown/hidden.
     - parameter animated: a boolean that indicates if the transition from shown/hidden should be
     animated.
     */
    func setRequiredLabelHidden(hidden: Bool, animated: Bool) {
        let animations: () -> () = {
            self.requiredLabel.alpha = hidden ? 0.0 : 1.0
        }
        
        let duration = animated ? 0.3 : 0.0
        
        UIView.animateWithDuration(duration, animations: animations)
    }
}
