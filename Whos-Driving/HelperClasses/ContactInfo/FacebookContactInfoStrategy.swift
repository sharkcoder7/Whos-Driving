import FBSDKCoreKit
import Foundation

/**
 *  Used to obtain contact information for a user who has signed into the app using Facebook.
 */
struct FacebookContactInfoStrategy {
    
}

// MARK: ContactInfoStrategy

extension FacebookContactInfoStrategy: ContactInfoStrategy {
    func getContactInfo(completion: (avatarURLString: String?, email: String?, name: String?, phoneNumber: String?) -> ()) {
        let group = dispatch_group_create()
        
        var email = ""
        var name = ""
        var avatarURLString: String? = nil
        
        let parameters = ["fields" : "email,name",]
        
        // Load the users email and name
        dispatch_group_enter(group)
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler {
            requestConnection, responseObject, error in
            if let nameString = responseObject.objectForKey(Facebook.NameKey) as? String {
                name = nameString
            }
            
            if let emailString = responseObject.objectForKey(Facebook.EmailKey) as? String {
                email = emailString
            }
            
            dispatch_group_leave(group)
        }
        
        // Load the users facebook photo
        dispatch_group_enter(group)
        FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: nil).startWithCompletionHandler {
            requestConnection, responseObject, error in
            if let dataDictionary = responseObject[Facebook.DataKey] as? NSDictionary {
                if let pictureUrlString = dataDictionary[Facebook.URLKey] as? String {
                    avatarURLString = pictureUrlString
                }
            }
            dispatch_group_leave(group)
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            completion(avatarURLString: avatarURLString, email: email, name: name, phoneNumber: nil)
        }
    }
}
