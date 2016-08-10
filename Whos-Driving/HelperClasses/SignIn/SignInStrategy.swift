import Foundation

/**
 *  Types that adopt this protocol provide the user a way to authenticate with the server.
 */
protocol SignInStrategy {
    // MARK: Properties
    
    /// This property is used to retrieve the users contact information depending on the strategy
    /// they use to sign-in.
    var contactInfoStrategy: ContactInfoStrategy { get }
    
    // MARK: Methods
    
    /**
     Call this method to retrieve an access token from the server for the current user using a
     specific set of parameters. To sign the user in, see 
     `signIn(withCompletion completion: (accessToken: String?, accountSetupComplete: Bool, error: NSError?) -> ())`.
     
     - parameter parameters: the parameters required to allow the user to sign-in. For example, the
     parameters could be an email/password, or else an OAuth token.
     - parameter completion: the closure to be called when the network request completes. This
     closure takes three parameters: the access token returned from the server; a boolean indicating
     if the users account has been completely set up; and the error that occurred as a result of the
     network request.
     */
    func getAccessToken(withParameters parameters: [String: String], completion: (accessToken: String?, accountSetupComplete: Bool, error: NSError?) -> ())
    
    /**
     Used to sign the user in with the server. This should be the default method for signing a user
     in.
     
     - parameter completion: the closure to be called when the network request completes. This
     closure takes three parameters: the access token returned as a result of the sign-in request;
     a boolean indicating if the account setup process has been completed; and the error that was
     returned as a result of the network request.
     */
    func signIn(withCompletion completion: (accessToken: String?, accountSetupComplete: Bool, error: NSError?) -> ())
}

extension SignInStrategy {
    /**
     Default login for the Who's Driving server.
     
     - parameter parameters: The parameters to be passed to the endpoint to authenticate the user.
     - parameter completion: The closure called when the request completes. The accessToken
     parameter will contain the access token returned from the server if log in was successful. The
     accountSetupComplete parameter will be false if there is additional information the user needs
     to enter to complete their profile.
     */
    func getAccessToken(withParameters parameters: [String: String], completion: (accessToken: String?, accountSetupComplete: Bool, error: NSError?) -> ()) {
        let webServiceController = WebServiceController.sharedInstance
        
        webServiceController.post(ServiceEndpoint.Sessions, parameters: parameters) {
            responseObject, error in
            if error != nil {
                print(error)
                completion(accessToken: nil, accountSetupComplete: false, error: error)
                return
            }
            
            let dataDictionary = responseObject?.objectForKey(ServiceResponse.DataKey) as! NSDictionary
            let sessionToken: String = dataDictionary.objectForKey(ServiceResponse.TokenKey) as! String
            let accountSetupComplete = dataDictionary.objectForKey(ServiceResponse.AccountSetupComplete) as! Bool
            
            completion(accessToken: sessionToken, accountSetupComplete: accountSetupComplete, error: nil)
        }
    }
}
