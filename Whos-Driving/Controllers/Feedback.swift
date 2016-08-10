import UIKit

/// Class used for sending user feedback to the server.
class Feedback: NSObject {
    
    /**
    Sends a user feedback message to the server.
    
    - parameter message The feedback message.
    - parameter completion Closure called when the request finishes. Error object represents
                           any errors encountered during the request.
    */
    func sendFeedback(message: String, completion: (error: NSError?) -> Void) {
        let parameters = [ServiceResponse.MessageKey : message]
        WebServiceController.sharedInstance.post(ServiceEndpoint.Feedback, parameters: parameters) { (responseObject, error) -> Void in
            completion(error: error)
        }
    }

}
