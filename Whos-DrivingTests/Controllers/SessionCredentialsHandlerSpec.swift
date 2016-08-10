import Quick
import Nimble

@testable import whos_driving_staging

struct MockSignInStrategy: SignInStrategy {
    
    // MARK: Properties
    
    let accessToken: String?
    
    let accountSetupComplete: Bool
    
    let contactInfoStrategy: ContactInfoStrategy = UserContactInfoStrategy()
    
    let error: NSError?
    
    // MARK: Init Methods
    
    init(accessToken: String?, accountSetupComplete: Bool, error: NSError?) {
        self.accessToken = accessToken
        self.accountSetupComplete = accountSetupComplete
        self.error = error
    }
    
    func signIn(withCompletion completion: (accessToken: String?, accountSetupComplete: Bool, error: NSError?) -> ()) {
        completion(accessToken: accessToken, accountSetupComplete: accountSetupComplete, error: error)
    }
}

class SessionCredentialsHandlerSpec: QuickSpec {
    
    // MARK: Tests
    
    override func spec() {
        context("when login is unsuccessful") {
            it("should return the error generated as a result.") {
                var actualError: NSError?
                let expectedError = NSError(domain: "", code: 1, userInfo: nil)
                
                let strategy = MockSignInStrategy(accessToken: nil, accountSetupComplete: false, error: expectedError)
                
                SessionCredentialsHandler.signIn(withStrategy: strategy) {
                    loggedIn, accountSetupComplete, error in
                    actualError = error
                }
                
                expect(actualError).toEventually(equal(expectedError))
            }
        }
        
        context("when login is successful") {
            it("should call the completion closure with logged in equal to true") {
                var actualLoggedInValue = false
                
                let strategy = MockSignInStrategy(accessToken: "test", accountSetupComplete: true, error: nil)
                
                SessionCredentialsHandler.signIn(withStrategy: strategy) {
                    loggedIn, accountSetupComplete, error in
                    actualLoggedInValue = loggedIn
                }
                
                expect(actualLoggedInValue).toEventually(beTruthy())
            }
            
            context("and the user has not completed their account setup") {
                it("should call the completion closure with the correct value for accountSetupComplete") {
                    var actualAccountSetUpValue = true
                    
                    let strategy = MockSignInStrategy(accessToken: "test", accountSetupComplete: false, error: nil)
                    
                    SessionCredentialsHandler.signIn(withStrategy: strategy) {
                        loggedIn, accountSetupComplete, error in
                        actualAccountSetUpValue = accountSetupComplete
                    }
                    
                    expect(actualAccountSetUpValue).toEventually(beFalsy())
                }
            }
            
            context("and the user has completed their account setup") {
                it("should call the completion closure with the correct value for accountSetupComplete") {
                    var actualAccountSetUpValue = false
                    
                    let strategy = MockSignInStrategy(accessToken: "test", accountSetupComplete: true, error: nil)
                    
                    SessionCredentialsHandler.signIn(withStrategy: strategy) {
                        loggedIn, accountSetupComplete, error in
                        actualAccountSetUpValue = accountSetupComplete
                    }
                    
                    expect(actualAccountSetUpValue).toEventually(beTruthy())
                }
            }
        }
    }
}
