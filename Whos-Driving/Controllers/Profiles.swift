import UIKit

/// Controller for accessing the current user's profile
class Profiles: NSObject {
    
    // MARK: Constants
    
    /// Shared singleton of this class.
    static let sharedInstance = Profiles()
    
    // MARK: Public properties
    
    /// The currentUserId. This is saved and accessed from the Keychain.
    var currentUserId: String? {
        didSet {
            if let userId = currentUserId {
                if let userIdData = userId.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    Keychain.save(Keychain.currentUserIdKey, data: userIdData)
                }
                
                if currentUserId != oldValue {
                    AnalyticsController().identify(userId)
                }
            }
        }
    }
    
    /// This is the current user the last time it was updated. If it's nil, it means the current user
    /// was never fetched from the server.
    var currentUser: Person?
    
    // MARK: Init and deinit methods
    
    override init() {
        if let userIdData = Keychain.load(Keychain.currentUserIdKey) {
            if let userId = NSString(data: userIdData, encoding: NSUTF8StringEncoding) as String? {
                currentUserId = userId
                AnalyticsController().identify(userId)
                
                dLog("Loaded saved user ID")
            }
        }
        
        super.init()
    }
    
    // MARK: Instance methods
    
    func completeAccountSetup(withCompletion completion: (Bool) -> ()) {
        let webServiceController = WebServiceController.sharedInstance
        
        webServiceController.post(ServiceEndpoint.CompleteAccountSetup, parameters: nil) {
            responseObject, error in
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    /**
     Creates a new user.
     
     - parameter email:                The users email address.
     - parameter firstName:            The users first name.
     - parameter lastName:             The users last name.
     - parameter password:             The users password.
     - parameter passwordConfirmation: The users password confirmation.
     - parameter phoneNumber:          The users phone number.
     - parameter completion:           Closure called when the call to the server completes.
     */
    func createUser(email: String, firstName: String, lastName: String, password: String, passwordConfirmation: String, phoneNumber: String?, completion: (accessToken: String?, createdPerson: Person?, error: NSError?) -> ()) {
        let webServiceController = WebServiceController.sharedInstance
        
        var parameters = [
            ServiceResponse.EmailKey: email,
            ServiceResponse.FirstNameKey: firstName,
            ServiceResponse.LastNameKey: lastName,
            ServiceResponse.PasswordKey: password,
            ServiceResponse.PasswordConfirmationKey: passwordConfirmation
        ]
        
        if let phoneNumber = phoneNumber {
            parameters[ServiceResponse.MobileNumberKey] = phoneNumber
        }
        
        webServiceController.post(ServiceEndpoint.Profile, parameters: parameters) {
            [weak self] responseObject, error in
            if error != nil {
                completion(accessToken: nil, createdPerson: nil, error: error)
            } else {
                let responseDictionary = responseObject as! NSDictionary
                let personDict = responseDictionary[ServiceResponse.DataKey] as! NSDictionary
                let accessToken = personDict[ServiceResponse.AccessToken] as! String
                let person = Person(dictionary: personDict)
                self?.currentUserId = person.id
                self?.currentUser = person
                
                completion(accessToken: accessToken, createdPerson: person, error: error)
            }
        }
    }
    
    /**
    Update the current user.
    
    - parameter address1 The user's address line one.
    - parameter address2 The user's address line two.
    - parameter city The user's city.
    - parameter email The user's email address.
    - parameter mobileNumber The user's phone number.
    - parameter state The user's state.
    - parameter zip The user's zip code.
    - parameter s3ImageURL The image URL on S3 for the user.
    - parameter completion Completion blocked called when the call to the server completes.
    */
    func updateUser(address1: String, address2: String, city: String, email: String, mobileNumber: String, state: String, zip: String, s3ImageURL: String?, completion:(createdPerson: Person?, error: NSError?) -> Void) {
        let webServiceController = WebServiceController.sharedInstance
        
        let parameters = [
            ServiceResponse.AddressLine1Key : objOrNull(address1),
            ServiceResponse.AddressLine2Key : objOrNull(address2),
            ServiceResponse.CityKey : objOrNull(city),
            ServiceResponse.EmailKey : objOrNull(email),
            ServiceResponse.MobileNumberKey : objOrNull(mobileNumber),
            ServiceResponse.StateKey : objOrNull(state),
            ServiceResponse.ZipKey : objOrNull(zip),
            ServiceResponse.ImageURLKey : objOrNull(s3ImageURL)
        ]
        
        webServiceController.put(ServiceEndpoint.Profile, parameters: parameters) { [weak self] (responseObject, error) -> Void in
            if error != nil {
                completion(createdPerson: nil, error: error)
            } else {
                let responseDictionary = responseObject as! NSDictionary
                let personDict = responseDictionary[ServiceResponse.DataKey] as! NSDictionary
                let person = Person(dictionary: personDict)
                self?.currentUserId = person.id
                self?.currentUser = person
                
                completion(createdPerson: person, error: error)
            }
        }
    }
    
    /**
     Gets the current user's profile and returns an array with the current user first, and the
     current user's partner second. If the user doens't have a partner, the only element in the array
     is the current user.
     
     - parameter completion Completion block called when the communication with the server finished.
                            "userAndPartner" is an array with the current user and partner in it. If
                            an error was encountered the "error" object will not be nil.
     */
    func getCurrentUserAndPartner(completion: (userAndPartner: [Person]?, error: NSError?) -> Void) {
        getCurrentUserProfile { (currentUser, accountSetupComplete, error) -> Void in
            if error != nil {
                completion(userAndPartner: nil, error: error)
            } else {
                var currentUserAndPartner = [Person]()
                if let unwrappedCurrentUser = currentUser {
                    currentUserAndPartner.append(unwrappedCurrentUser)
                }
                if let unwrappedPartner = currentUser?.partner {
                    currentUserAndPartner.append(unwrappedPartner)
                }
                
                completion(userAndPartner: currentUserAndPartner, error: nil)
            }
        }
    }
    
     /**
     Gets the current user's profile details.
     
     - parameter completion Completion blocked called when the call to the server completes. The 
                            accountSetupComplete parameter will be true if the user has finished
                            setting up their account. If false the setup account screen should be
                            shown.
     */
    func getCurrentUserProfile(completion: (currentUser: Person?,  accountSetupComplete: Bool?, error: NSError?) -> Void) {
        let webServiceController = WebServiceController.sharedInstance
        
        webServiceController.get(ServiceEndpoint.Profile, parameters: nil) { [weak self] (responseObject, error) -> Void in
            if error != nil {
                completion(currentUser: nil, accountSetupComplete: nil, error: error)
            } else {
                let responseDictionary = responseObject as! NSDictionary
                let personDict = responseDictionary[ServiceResponse.DataKey] as! NSDictionary
                let person = Person(dictionary: personDict)
                self?.currentUserId = person.id
                self?.currentUser = person
                let setupComplete = personDict[ServiceResponse.AccountSetupComplete] as? Bool

                completion(currentUser: person, accountSetupComplete: setupComplete, error: nil)
            }
        }
    }
    
    /**
     Update the current user's profile.
     
     - parameter currentUser The updated version of the current user to send to the server.
     - parameter image The new image to use for the user's avatar.
     - parameter completion Completion blocked called when the call to the server completes.
     */
    func updateCurrentUsersProfile(currentUser: Person, image: UIImage?, completion:(error: NSError?) -> Void) {
        if let unwrappedImage = image {
            // If there's an image to update, have to upload it to S3 first, then call updateCurrentUsersProfile again with an updated person.
            ImageController.sharedInstance.uploadImage(unwrappedImage, userId: currentUser.id, completion: { [weak self] (localURL, s3URL, error) -> Void in
                if error != nil {
                    completion(error: error)
                } else {
                    currentUser.imageURL = s3URL
                    
                    self?.updateCurrentUsersProfile(currentUser, image: nil, completion: { (error) -> Void in
                        if let unwrappedLocalURL = localURL {
                            ImageController.sharedInstance.updateLocalImageCache(currentUser.id, localUrl: unwrappedLocalURL)
                        }
                        
                        completion(error: error)
                    })
                }
            })
        } else {
            let webServiceController = WebServiceController.sharedInstance
            
            let parameters = currentUser.dictionaryRepresentation()
            webServiceController.put(ServiceEndpoint.Profile, parameters: parameters) { [weak self] (responseObject, error) -> Void in
                if error != nil {
                    completion(error: error)
                } else {
                    let responseDictionary = responseObject as! NSDictionary
                    let personDict = responseDictionary[ServiceResponse.DataKey] as! NSDictionary
                    let person = Person(dictionary: personDict)
                    self?.currentUserId = person.id
                    self?.currentUser = person
                    
                    completion(error: error)
                }
            }
        }
    }
}
