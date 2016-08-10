import FBSDKCoreKit
import FBSDKLoginKit
import Foundation

/**
 *  Used to sign in to Facebook.
 */
struct FacebookSignInStrategy {
    // MARK: SignInStrategy Properties
    
    let contactInfoStrategy: ContactInfoStrategy = FacebookContactInfoStrategy()
}

// MARK: SignInStrategy Methods

extension FacebookSignInStrategy: SignInStrategy {
    /**
     Sign in via Facebook.
     
     - parameter completion Completion block called when the call to the server completes. The
     loggedIn parameter will be true if log in was successful. The accountSetupComplete
     parameter will be false if there is additional information the user needs
     to enter to complete their profile.
     */
    func signIn(withCompletion completion: (accessToken: String?, accountSetupComplete: Bool, error: NSError?) -> ()) {
        let loginManager = FBSDKLoginManager()
        let requestedPermissions = ["public_profile", "email"]
        
        loginManager.logInWithReadPermissions(requestedPermissions, fromViewController: nil) {
            result, error in
            if error != nil {
                loginManager.logOut()
                completion(accessToken: nil, accountSetupComplete: false, error: error)
            } else if result.isCancelled {
                loginManager.logOut()
                completion(accessToken: nil, accountSetupComplete: false, error: nil)
            } else {
                let token: String = result.token.tokenString
                let parameters = ["oauth_access_token" : token]
                self.getAccessToken(withParameters: parameters, completion: completion)
            }
        }
    }
}
