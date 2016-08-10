import UIKit

/// View model for the CreateEventNotificationViewController
struct CreateEventNotificationViewControllerViewModel {
   
    // MARK: Private properties
    
    /// Event factory used to determine what to return for the various model methods.
    private let eventFactory: EventFactory
    
    // MARK: Init and deinit methods
    
    /**
    Creates a configured instance of this class.
    
    - parameter eventFactory The EventFactory for the event being created.
    
    - returns: Configured instance of this class.
    */
    init(eventFactory: EventFactory) {
        self.eventFactory = eventFactory
    }
    
    // MARK: Instance methods
    
    /**
    The text to return for the speech bubble in the notification view.
    
    - returns: The text for the speech bubble.
    */
    func speechBubbleText() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE M/d"
        let dateString = dateFormatter.stringFromDate(eventFactory.startTime!)
        
        var text: String
        
        if let currentUserName = Profiles.sharedInstance.currentUser?.displayName {
            text = "New carpool created by \(currentUserName): \(dateString) \(eventFactory.name!). "
        } else {
            dLog("Couldn't load current user name! This shouldn't happen.")
            
            text = "New carpool created: \(dateString) \(eventFactory.name!). "
        }
        
        let driverTo = eventFactory.driverTo
        let driverFrom = eventFactory.driverFrom
        
        switch eventFactory.driverStatus {
        case .NoDrivers:
            text += "Drivers needed! Can you drive TO and/or FROM?"
        case .NoDriverFrom:
            text += "\(driverTo!.displayName) is driving TO; Can you drive FROM?"
        case .NoDriverTo:
            text += "\(driverFrom!.displayName) is driving FROM; Can you drive TO?"
        case .BothDrivers:
            if driverTo!.id == driverFrom!.id {
                // same driver for TO and FROM
                text += "\(driverTo!.displayName) is driving TO and FROM."
            } else {
                text += "\(driverTo!.displayName) is driving TO; \(driverFrom!.displayName) is driving FROM."
            }
        }
        
        return text
    }
}
