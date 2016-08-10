import Foundation

/**
 *  Create an instance of EmailSignInStrategy to allow the user to sign-in with their email/password.
 */
struct EmailSignInStrategy {
    // MARK: Properties
    
    let contactInfoStrategy: ContactInfoStrategy = UserContactInfoStrategy()
    
    // MARK: Private Properties
    
    /// The users email address. Required for the user to be able to sign-in.
    private let email: String?
    
    /// The users password. Required for the user to be able to sign-in.
    private let password: String?
    
    // MARK: Init Methods
    
    init(email: String?, password: String?) {
        self.email = email
        self.password = password
    }
}

// MARK: SignInStrategy Methods

extension EmailSignInStrategy: SignInStrategy {
    func signIn(withCompletion completion: (accessToken: String?, accountSetupComplete: Bool, error: NSError?) -> ()) {
        guard let email = email, password = password else {
            let error = NSError(domain: "com.whosdriving.whosdriving", code: 422, userInfo: nil)
            completion(accessToken: nil, accountSetupComplete: false, error: error)
            return
        }
        
        let parameters = [
            "email": email,
            "password": password
        ]
        
        getAccessToken(withParameters: parameters, completion: completion)
    }
}
