import Foundation

/**
 *  Used to obtain contact information for a user that has signed in to the app using email/password
 *  credentials.
 */
struct UserContactInfoStrategy {
    
}

// MARK: ContactInfoStrategy

extension UserContactInfoStrategy: ContactInfoStrategy {
    func getContactInfo(completion: (avatarURLString: String?, email: String?, name: String?, phoneNumber: String?) -> ()) {
        Profiles.sharedInstance.getCurrentUserProfile {
            currentUser, accountSetupComplete, error in
            completion(avatarURLString: currentUser?.imageURL, email: currentUser?.email, name: currentUser?.fullName, phoneNumber: currentUser?.phoneNumber)
        }
    }
}
