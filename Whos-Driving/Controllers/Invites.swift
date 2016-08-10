import UIKit

/// This class gets the details from the server of an invite sent from one user to another.
class Invites: NSObject {
    
    // MARK: Constants
    
    /// Shared instance of this class
    static let sharedInstace = Invites()
    
    // MARK: Public properties
    
    /// Saved invite token that wasn't able to be handled at the time. Check if there is a valid
    /// invite token here after finishing setting up a user's account. If there is, should load and
    /// show the invite to the user. This var is set to nil if -getInviteForInviteToken() is called
    /// using a matching inviteToken.
    var pendingInviteToken: String?
    
    // MARK: Class methods
    
    /**
    Gets the invite token from an invite URL. The URL is formatted: <base url>/invites/<invite token>.
    
    - parameter url The URL to extract the invite token from.
    
    - returns: The invite token, or nil if not found.
    */
    class func getInviteTokenFromURL(url: NSURL) -> String? {
        return url.lastPathComponent
    }
    
    // MARK: Instance methods

    /**
    Attempts to accept an invite, using the invite token provided.
    
    - parameter inviteToken The invite token used to determine the details of the invite on the 
                            server.
    - parameter completion Completion block called when the server has finished processing. The error
                           object contains any errors encountered during the process. If no errors are
                           encountered, the invite object will contain further details, including if
                           the invite was successful, or if there was a conflict, such as the two 
                           users already being trusted drivers.
    */
    func acceptInviteForInviteToken(inviteToken: String, completion: (invite: Invite?, error: NSError?) -> Void) {
        let endpoint = "\(ServiceEndpoint.Invites)\(inviteToken)/accept"
        
        WebServiceController.sharedInstance.put(endpoint, parameters: nil) { (responseObject, error) -> Void in
            if error != nil {
                dLog("\(error)")
                completion(invite: nil, error: error)
            } else {
                if let inviteDict = responseObject as? NSDictionary {
                    let invite = Invite(dictionary: inviteDict)
                    completion(invite: invite, error: nil)
                }
            }
        }
    }
    
    /**
     Gets the details of an invite from an invite token.
     
     - parameter inviteToken The invite token used to determine the details of the invite on the 
                             server.
     - parameter completion Completion block called when the server has finished processing. The error
                            object contains any errors encountered during the process. If no errors are
                            encountered, the invite object will contain further details, including if
                            the invite is valid, or if there is a conflict, such as the two users 
                            already being trusted drivers.
     */
    func getInviteForInviteToken(inviteToken: String, completion: (invite: Invite?, error: NSError?) -> Void) {
        if inviteToken == pendingInviteToken {
            // nil out the pending invite token automatically if it was used to fetch an invite
            pendingInviteToken = nil
        }
        
        let endpoint = "\(ServiceEndpoint.Invites)\(inviteToken)"
        
        WebServiceController.sharedInstance.get(endpoint, parameters: nil) { (responseObject, error) -> Void in
            if error != nil {
                dLog("\(error)")
                completion(invite: nil, error: error)
            } else {
                if let inviteDict = responseObject as? NSDictionary {
                    let invite = Invite(dictionary: inviteDict)
                    completion(invite: invite, error: nil)
                }
            }
        }
    }
}
