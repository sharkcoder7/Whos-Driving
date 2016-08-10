import UIKit

/// Controller for sending notifications to other users when an event is updated.
class EventNotifications: NSObject {
    
    /**
     Sends a notification for an event being updated.
     
     - parameter eventId The id of the event.
     - parameter recipientIds Array of the IDs of the users to be notified.
     - parameter changesetNotice Array of strings describing the changes made to the event. These
                                 should not need to be formatted manually. When calling 
                                 Events().updateEvent() pass along the provided changesetNotice.
     
     - parameter completion Completion blocked called when the call to the server completes.
     */
    func sendNotification(eventId: String, recipientIds: [String], changesetNotice: [String], completion:(error: NSError?) -> Void) {
        let endpoint = "\(ServiceEndpoint.Events)\(eventId)\(ServiceEndpoint.Notifications)"
        let webServiceController = WebServiceController.sharedInstance
        let params = [
            ServiceResponse.DriversKey : recipientIds,
            ServiceResponse.ChangesetNotice: changesetNotice
        ]
        
        webServiceController.post(endpoint, parameters: params) { (responseObject, error) -> Void in
            completion(error: error)
        }
    }
}