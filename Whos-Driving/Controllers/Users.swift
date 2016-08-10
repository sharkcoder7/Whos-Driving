import UIKit

/// Controller used to get the details of a non-specific user (either a rider or driver).
class Users: NSObject {
    // MARK: Class Methods
    
    /**
     Gets the account confirmation token from an account confirmation URL. The expected format of
     the URL is: <base url>/users/confirmation?confirmation_token=<invite token>.
     
     - parameter url: The URL to extract the reset password token from.
     
     - returns: The confirm account token, or nil if not found.
     */
    class func getAccountConfirmationTokenFromURL(url: NSURL) -> String? {
        guard let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        guard let queryItems = components.queryItems else {
            return nil
        }
        
        for queryItem in queryItems {
            if queryItem.name == ServiceResponse.AccountConfirmationToken {
                return queryItem.value
            }
        }
        
        return nil
    }
    
    /**
     Gets the reset password token from a reset password URL. The expected format of the URL is:
     <base url>/users/password/edit?reset_password_token=<invite token>.
     
     - parameter url The URL to extract the reset password token from.
     
     - returns: The reset password token, or nil if not found.
     */
    class func getResetPasswordTokenFromURL(url: NSURL) -> String? {
        guard let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        guard let queryItems = components.queryItems else {
            return nil
        }
        
        for queryItem in queryItems {
            if queryItem.name == ServiceEndpoint.ResetPasswordToken {
                return queryItem.value
            }
        }
        
        return nil
    }
    
    // MARK: Instance Methods
    
    /**
     Get the details of a user. Can be either a rider or driver.
     
     - parameter id The id of the user.
     - parameter completion Completion block called when the call to the server completes.
     */
    func getUser(id: String, completion:(user: Person?, error: NSError?) -> Void) {
        let webServiceController = WebServiceController.sharedInstance
        
        let endpoint = ServiceEndpoint.Users + id
        
        webServiceController.get(endpoint, parameters: nil) { (responseObject, error) -> Void in
            if error != nil {
                dLog("Error: \(error)")
                completion(user: nil, error: error)
            } else {
                if let personDictionary = responseObject?.objectForKey(ServiceResponse.DataKey) as? NSDictionary {
                    let person = Person(dictionary: personDictionary)
                    completion(user: person, error: nil)
                }
            }
        }
    }
}
