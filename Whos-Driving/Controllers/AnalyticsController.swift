import Analytics
import UIKit

/**
 An AnalyticsContext is used to give context to where the user is in the flow of the app.
 */
enum AnalyticsContext: String {
    case CreateUser = "Create user" /// The user is setting up their account
    case CreateCarpool = "Create carpool" /// The user is creating a carpool
}

/// This class handles sending analytics events to SegmentIO.
class AnalyticsController: NSObject {
    
    // MARK: Analytics Keys
    
    static let ContextKey = "user_context"
    static let DriverFromKey = "driver_from"
    static let DriverStatusResponseKey = "driver_status_response"
    static let DriverToKey = "driver_to"
    static let InvitedSpouseKey = "invited_spouse"
    static let KidsCountKey = "kids_count"
    static let NotificationsCountKey = "notifications_count"
    static let RidersFromCountKey = "riders_from_count"
    static let RidersToCountKey = "riders_to_count"
    static let TrustedDriverInvitesCountKey = "trusted_driver_invites_count"

    // MARK: Instance methods
    
    /**
    Call this method to identify the current user by their ID. All subsequent calls to SegmentIO
    will use this ID to identify the user across calls. This only needs to be done once when the
    user first signs in.
    
    - parameter userId The current user's ID. This will be used to identify them across devices/sessions.
    */
    func identify(userId: String) {
        SEGAnalytics.sharedAnalytics().identify(userId)
    }
    
    /**
     Resets the user's ID set from an identify() call.
     */
    func reset() {
        SEGAnalytics.sharedAnalytics().reset()
    }
    
    /**
     Track a screen view by the user.
     
     - parameter screenTitle The name of the screen the user viewed.
     */
    func screen(screenTitle: String) {
        SEGAnalytics.sharedAnalytics().screen(screenTitle)
    }
    
    /**
     Setups up SEGAnalytics. This must be called once on app startup before any other calls are made
     otherwise an exception will be raised.
     */
    func setup() {
        let segConfig = SEGAnalyticsConfiguration(writeKey: kSEGMENT_KEY)
        
        #if DEBUG
            segConfig.flushAt = 1 // In debug mode, send events every time to make development easier
        #endif
        
        SEGAnalytics.setupWithConfiguration(segConfig)
    }
    
    /**
     Track an event.
     
     - parameter event Description of the event that occured, e.g. "Clicked save button".
     */
    func track(event: String) {
        SEGAnalytics.sharedAnalytics().track(event)
    }
    
    /**
     Track an event, with optional parameters to offer further context or details about the event.
     
     - parameter event Description of the event that occured, e.g. "Clicked save button".
     - parameter context One of the AnalyticsContext values. This will be assigned to the value for
                         the "user_context" key.
     - parameter properties Dictionary of additional details about the event, e.g. "driver_count" : 3.
     */
    func track(event: String, context: AnalyticsContext?, properties: [NSObject : AnyObject]?) {
        var propertyDict = [NSObject : AnyObject]()
        
        if let unwrappedProperties = properties {
            propertyDict.update(unwrappedProperties)
        }
        
        if let unwrappedContext = context {
            propertyDict[AnalyticsController.ContextKey] = unwrappedContext.rawValue
        }
        
        SEGAnalytics.sharedAnalytics().track(event, properties: propertyDict)
    }
}