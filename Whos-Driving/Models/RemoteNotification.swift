import UIKit

/**
 Represents what type of remote notification this is. Possible values are specified by the server.
 */
enum RemoteNotificationType: String {
    case New = "new"
    case Edit = "edit"
    case Delete = "delete"
}

/**
 *  Represents the properties of a remote notification received from the server. This class uses the
 *  userInfo dictionary to initialize it's properties.
 */
struct RemoteNotification {

    // MARK: Constants
    
    private let AlertKey = "alert"
    private let ApsKey = "aps"
    private let AuthorIdKey = "author_id"
    private let AuthorNameKey = "author_name"
    private let EventIdKey = "event_id"
    private let TypeKey = "notification_type"
    
    // MARK: Properties
    
    /// The message shown to the user.
    var alert: String
    
    /// The ID of the user who created the notification.
    var authorId: String
    
    /// The name of the user who created the notification.
    var authorName = "Someone"
    
    /// The ID of the effected event.
    var eventId: String
    
    /// The type of notification. See RemoteNotificationType.
    var type: RemoteNotificationType
    
    //MARK: Init and deinit methods
    
    /**
     Initializes an instance of this class with the provided variables in the userInfo dictionary.
     If the required parameters are not found in the userInfo dictionary, this initializer will return
     nil.
     
     - parameter userInfo The dictionary containing the parameters of the RemoteNotification.
     
     - returns: Configured instance of this class, or nil if the required parameters aren't included
                in the userInfo dictionary.
     */
    init?(userInfo: [NSObject : AnyObject]) {
        if let notificationDict = userInfo[ApsKey] as? NSDictionary {
            guard let alert = notificationDict[AlertKey] as? String  else {
                dLog("No alert. Returning nil")
                return nil
            }
            
            guard let authorId = notificationDict[AuthorIdKey] as? String else {
                dLog("No author id. Returning nil")
                return nil
            }
            
            guard let eventId = notificationDict[EventIdKey] as? String else {
                dLog("No event id. Returning nil")
                return nil
            }
            
            guard let typeString = notificationDict[TypeKey] as? String else {
                dLog("No type. Returning nil")
                return nil
            }
            
            guard let type = RemoteNotificationType(rawValue: typeString) else {
                dLog("Type didn't match any of the RemoteNotificationTypes. Returning nil.")
                return nil
            }
            
            self.alert = alert
            self.authorId = authorId
            self.eventId = eventId
            self.type = type
            
            if let authorName = notificationDict[AuthorNameKey] as? String {
                self.authorName = authorName
            }
        } else {
            dLog("No user info dictionary. Returning nil")
            return nil
        }
    }
}
