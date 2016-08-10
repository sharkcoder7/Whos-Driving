import FBSDKCoreKit
import FBSDKLoginKit
import UIKit

/// Controller used to handle logging in/out with Facebook and managing authentication.
class SessionCredentialsHandler: NSObject {
    
    // MARK: Class Methods
    
    /**
     Confirms the users account using the specified token.
     
     - parameter token:      the token confirming the users account.
     - parameter completion: the closure to be called when the network request completes. This
     closure takes one parameter: a string containing the error message if the network request fails.
     */
    class func confirmUser(withToken token: String, completion: (email: String?, message: String?) -> ()) {
        let endpoint = ServiceEndpoint.Sessions + ServiceEndpoint.ConfirmUser
        let parameters = [
            ServiceResponse.AccountConfirmationToken: token
        ]
        
        WebServiceController.sharedInstance.post(endpoint, parameters: parameters) {
            responseObject, error in

            guard let dataDictionary = responseObject?.objectForKey(ServiceResponse.DataKey) as? [String: AnyObject] else {
                completion(email: nil, message: nil)
                return
            }
            
            let email = dataDictionary[ServiceResponse.EmailKey] as? String
            let message = dataDictionary[ServiceResponse.MessageKey] as? String
            
            completion(email: email, message: message)
        }
    }
    
    /**
    Returns true if the user is currently logged in.
    
    - returns: True if the user is logged in.
    */
    class func loggedIn() -> Bool {
        var loggedIn = false
        
        if WebServiceController.sharedInstance.hasAuthenticationToken == true {
                loggedIn = true
        }
        
        return loggedIn
    }
    
    /**
     Log the user out of Facebook.
     */
    class func logoutWithFacebook() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        WebServiceController.sharedInstance.removeAuthenticationToken()
    }
    
    /**
     Performs a network request to initiate the password reset process.
     
     - parameter token:           the token used to identify the user
     - parameter password:        the users new password
     - parameter confirmPassword: confirm the users new password
     - parameter completion:      the closure to be called when the network request completes. This
     closure takes one parameter: a string containing the error message if the network request fails.
     */
    class func resetPassword(withToken token: String, password: String, confirmPassword: String, completion: (errorMessage: String?) -> ()) {
        let endpoint = ServiceEndpoint.Sessions + ServiceEndpoint.ResetPassword
        let parameters = [
            ServiceResponse.ResetPasswordTokenKey: token,
            ServiceResponse.PasswordKey: password,
            ServiceResponse.PasswordConfirmationKey: confirmPassword
        ]
        
        WebServiceController.sharedInstance.post(endpoint, parameters: parameters) {
            responseObject, error in
            guard let _ = error else {
                completion(errorMessage: nil)
                return
            }
            
            if let dataDictionary = responseObject?.objectForKey(ServiceResponse.DataKey) as? [String: String] {
                let message = dataDictionary[ServiceResponse.MessageKey]
                completion(errorMessage: message)
                return
            }
            
            completion(errorMessage: "Password reset failed. Please try again later.")
        }
    }
    
    /**
     Signs the user in to the server using the specified strategy.
     
     - parameter strategy:   the strategy to use for signing in.
     - parameter completion: the closure to be called when the network request completes. This
     closure takes three arguments: a boolean indicating if the user was successfully signed in;
     a boolean indicating if the users account setup has been completed; and the error that was
     generated as a result of the network request.
     */
    class func signIn(withStrategy strategy: SignInStrategy, completion: (loggedIn: Bool, accountSetupComplete: Bool, error: NSError?) -> ()) {
        strategy.signIn {
            accessToken, accountSetupComplete, error in
            
            guard error == nil else {
                completion(loggedIn: false, accountSetupComplete: accountSetupComplete, error: error)
                return
            }
            
            guard let accessToken = accessToken else {
                completion(loggedIn: false, accountSetupComplete: accountSetupComplete, error: error)
                return
            }
            
            WebServiceController.sharedInstance.addAuthenticationToken(accessToken)
            completion(loggedIn: true, accountSetupComplete: accountSetupComplete, error: nil)
        }
    }
    
    /**
     Verifies the validity of a password reset token.
     
     - parameter token:      the token to validate
     - parameter completion: the closure that is executed when the network request completes. This
     closure thake three parameters: a boolean indicating if the reset password token is valid;
     a string representing the email address that the token is associated with; and human readable
     message that describes the token (I.e. "Reset password token is valid").
     */
    class func verify(resetPasswordToken token: String, withCompletion completion: (isValid: Bool, email: String?, message: String?) -> ()) {
        let endpoint = ServiceEndpoint.Sessions + ServiceEndpoint.ValidateResetPasswordToken
        let parameters = [
            ServiceResponse.ResetPasswordTokenKey: token
        ]
        
        WebServiceController.sharedInstance.post(endpoint, parameters: parameters) {
            responseObject, error in
            
            guard let dataDictionary = responseObject?.objectForKey(ServiceResponse.DataKey) as? [String: AnyObject] else {
                completion(isValid: false, email: nil, message: "Reset password token is invalid.")
                return
            }
            
            let email = dataDictionary[ServiceResponse.EmailKey] as? String
            let isValid = dataDictionary[ServiceResponse.ValidTokenKey] as? Bool ?? false
            let message = dataDictionary[ServiceResponse.MessageKey] as? String
            
            completion(isValid: isValid, email: email, message: message)
        }
    }
}
