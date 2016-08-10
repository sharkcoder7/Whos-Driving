import UIKit

/**
 *  View model for the DetailsToFromView.
 */
struct DetailsToFromViewModel {
    
    // MARK: Private Properties
    
    /// The event being shown.
    private let event: Event
    
    // MARK: Init Methods
    
    /**
    Creates a configured instance of this class with the provided event.
    
    - parameter anEvent The event being displayed.
    
    - returns: Configured instance of this class.
    */
    init(event anEvent: Event) {
        event = anEvent        
    }
    
    // MARK: Instance Methods
    
    /**
    Text for the note.
    
    - parameter isDrivingTo True if the DetailsToFromView is showing the "to" leg of the event.
    
    - returns: Text for the note.
    */
    func attributedNotesString(isDrivingTo: Bool) -> NSAttributedString? {
        var notesText = ""
        let unwrappedNotes = (isDrivingTo == true) ? event.toNotes : event.fromNotes
        if let notes = unwrappedNotes {
            notesText = notes
        }
        
        if notesText == "" {
            // No notes to display
            
            return nil
        }
        
        let note = "Note:"
        let combinedString = "\(note) \(notesText)"
        let textColor = AppConfiguration.black()
        let fontSize = 14.0 as CGFloat
        let notesTextAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueLightItalic, size: fontSize)!]
        
        let noteAttributedString = NSMutableAttributedString(string: combinedString, attributes: notesTextAttributes)
        
        let noteRange = (combinedString as NSString).rangeOfString(note)
        let noteAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueRegular, size: fontSize)!]
        
        noteAttributedString.addAttributes(noteAttributes, range: noteRange)
        
        return noteAttributedString
    }
    
    /**
     Text for the title label.
     
     - parameter isDrivingTo True if the DetailsToFromView is showing the "to" leg of the event.
     
     - returns: Text for the title.
     */
    func attributedTitleString(isDrivingTo: Bool) -> NSAttributedString {
        let drivingDirection = (isDrivingTo == true) ? "To" : "From"
        let theActivity = "the activity"
        let headingString = "Driving \(drivingDirection) \(theActivity)"
        let textColor = AppConfiguration.black()
        
        let baseAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueLight, size: 24.0)!]
        let titleAttributedString = NSMutableAttributedString(string: headingString, attributes: baseAttributes)
        
        let activityRange = (headingString as NSString).rangeOfString(theActivity)
        let activityAttributes = [NSForegroundColorAttributeName : textColor, NSFontAttributeName : UIFont(name: Font.HelveticaNeueThinItalic, size: 17.0)!]
        
        titleAttributedString.addAttributes(activityAttributes, range: activityRange)
        
        return titleAttributedString
    }
    
    /**
     The background color for the ColoredEdgeView.
     
     - parameter isDrivingTo True if the DetailsToFromView is showing the "to" leg of the event.
     
     - returns: Background color for the ColoredEdgeView.
     */
    func coloredEdgeViewColor(isDrivingTo: Bool) -> UIColor {
        if isDrivingTo {
            if event.driverTo == nil {
                return AppConfiguration.red()
            } else {
                return AppConfiguration.green()
            }
        } else {
            if event.driverFrom == nil {
                return AppConfiguration.red()
            } else {
                return AppConfiguration.green()
            }
        }
    }
}
