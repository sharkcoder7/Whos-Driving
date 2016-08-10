import Foundation

/**
 *  Allows the user to sign in to the app by creating an account.
 */
struct SignUpSignInStrategy {
    // MARK: Properties
    
    let contactInfoStrategy: ContactInfoStrategy = UserContactInfoStrategy()
    
    // MARK: Private Properties
    
    /// The users email address
    private let email: String
    
    /// The users first name.
    private let firstName: String
    
    /// The users last name.
    private let lastName: String
    
    /// The users desired password.
    private let password: String
    
    /// A confirmation of the users desired password.
    private let passwordConfirmation: String
    
    /// The users phone number.
    private let phoneNumber: String?
    
    // MARK: Init Methods
    
    init(email: String, firstName: String, lastName: String, password: String, passwordConfirmation: String, phoneNumber: String?) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.password = password
        self.passwordConfirmation = passwordConfirmation
        self.phoneNumber = phoneNumber
    }
}

// MARK: SignInStrategy Methods

extension SignUpSignInStrategy: SignInStrategy {
    func signIn(withCompletion completion: (accessToken: String?, accountSetupComplete: Bool, error: NSError?) -> ()) {
        Profiles.sharedInstance.createUser(email, firstName: firstName, lastName: lastName, password: password, passwordConfirmation: passwordConfirmation, phoneNumber: phoneNumber) {
            accessToken, createdPerson, error in
            completion(accessToken: accessToken, accountSetupComplete: false, error: error)
        }
    }
}
