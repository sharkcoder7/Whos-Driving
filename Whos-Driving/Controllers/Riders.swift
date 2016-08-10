import UIKit

/// Controller for communicating with the server about riders.
class Riders: NSObject {
    
    // MARK: Instance Methods
    
    /**
    Create a new household rider for the current user.
    
    - parameter firstName The first name of the rider.
    - parameter lastName The last name of the rider.
    - parameter phoneNumber The phone number of the rider.
    - parameter image The image for the rider's avatar.
    - parameter s3ImageURL The URL of the image on S3.
    - parameter localImageURL The local path to the image.
    - parameter completion Completion block called when the call to the server completes.
    */
    func createHouseholdRider(firstName: String, lastName: String, phoneNumber: String?, image: UIImage?, s3ImageURL: String?, localImageURL: NSURL?, completion:(person: Person?, error: NSError?) -> Void) {
        if let unwrappedImage = image {
            // If there's an image to update, have to upload it to S3 first, then call createHouseholdRider again.
            ImageController.sharedInstance.uploadImage(unwrappedImage, userId: nil, completion: { (localURL, s3URL, error) -> Void in
                if error != nil {
                    completion(person: nil, error: error)
                } else {
                    Riders().createHouseholdRider(firstName, lastName: lastName, phoneNumber: phoneNumber, image: nil, s3ImageURL: s3URL, localImageURL: localURL, completion: { (person, error) -> Void in
                        completion(person: person, error: error)
                    })
                }
            })
        } else {
            let webServiceController = WebServiceController.sharedInstance
            let endpoint = ServiceEndpoint.HouseholdRiders
            let parameters = [
                ServiceResponse.FirstNameKey : firstName,
                ServiceResponse.LastNameKey : lastName,
                ServiceResponse.MobileNumberKey : objOrNull(phoneNumber),
                ServiceResponse.ImageURLKey : objOrNull(s3ImageURL)
            ]
            
            webServiceController.post(endpoint, parameters: parameters) { (responseObject, error) -> Void in
                var person: Person?
                
                if error == nil {
                    if let dataDictionary = responseObject?.objectForKey(ServiceResponse.DataKey) as? NSDictionary {
                        person = Person(dictionary: dataDictionary)
                        
                        // if a local image URL was provided, update the local image cache for the person that was just created.
                        if let unwrappedLocalURL = localImageURL {
                            ImageController.sharedInstance.updateLocalImageCache(person!.id, localUrl: unwrappedLocalURL)
                        }
                    }
                }
                
                completion(person: person, error: error)
            }
        }
    }
    
    /**
     Delete a household rider.
     
     - parameter id The id of the rider to delete.
     - parameter completion Completion block called when the call to the server completes.
     */
    func deleteHouseholdRider(id: String, completion:(error: NSError?) -> Void) {
        let webServiceController = WebServiceController.sharedInstance
        let endpoint = ServiceEndpoint.HouseholdRiders + id
        
        webServiceController.delete(endpoint, parameters: nil) { (responseObject, error) -> Void in
            completion(error: error)
        }
    }
    
    /**
     Gets an array of all the current user's household riders.
     
     - parameter completion Completion block called when the call to the server completes.
     */
    func getHouseholdRiders(completion:(riders: Array<Person>, error: NSError?) -> Void) {
        let webServiceController = WebServiceController.sharedInstance
        
        var ridersArray: Array<Person> = []
        
        webServiceController.get(ServiceEndpoint.HouseholdRiders, parameters: nil) { (responseObject, error) -> Void in
            if error != nil {
                completion(riders: ridersArray, error: error)
            } else {
                
                if let dataArray = responseObject?.objectForKey(ServiceResponse.DataKey) as? NSArray {
                    for personDictionary in dataArray {
                        if personDictionary is NSDictionary {
                            let person = Person(dictionary: personDictionary as! NSDictionary)
                            ridersArray.append(person)
                        }
                    }
                }
                
                completion(riders: ridersArray, error: error)
            }
        }
    }
    
    /**
     Gets an array of all the current user's trusted riders. There are additional paramters to control
     what riders are included in this list.
     
     - parameter exclude True to not include the current user's own household riders in the array.
     - parameter includeHouseholdDrivers True to include the details of each rider's household 
                                         drivers in the response. Some views might need these details
                                         while others do not.
     - parameter completion Completion block called when the call to the server completes.
     */
    func getTrustedRiders(excludeHouseholdRiders exclude: Bool, includeHouseholdDrivers: Bool, completion:(riders: Array<Person>, error: NSError?) -> Void) {
        let endpoint = ServiceEndpoint.TrustedRiders
        let webServiceController = WebServiceController.sharedInstance
        let parameters = [
            ServiceResponse.ExcludeHouseholdRiders : exclude.stringValue(),
            ServiceResponse.IncludeHouseholdDrivers : includeHouseholdDrivers.stringValue(),
        ]
        
        webServiceController.get(endpoint, parameters: parameters) { (responseObject, error) -> Void in
            var ridersArray: Array<Person> = []
            
            if let dataArray = responseObject?.objectForKey(ServiceResponse.DataKey) as? NSArray {
                for personDictionary in dataArray {
                    if personDictionary is NSDictionary {
                        let person = Person(dictionary: personDictionary as! NSDictionary)
                        ridersArray.append(person)
                    }
                }
            }
            
            completion(riders: ridersArray, error: error)
        }
    }
    
    /**
     Update a household rider.
     
     - parameter rider The updated version of the rider.
     - parameter image The new image to use for the rider's avatar.
     - parameter completion Completion block called when the call to the server completes.
     */
    func updateHouseholdRider(rider: Person, image: UIImage?, completion: (error: NSError?) -> Void) {
        if let unwrappedImage = image {
            // If there's an image to update, have to upload it to S3 first, then call updateHouseholdRider again with an updated rider.
            ImageController.sharedInstance.uploadImage(unwrappedImage, userId: rider.id, completion: { (localURL, s3URL, error) -> Void in
                if error != nil {
                    completion(error: error)
                } else {
                    rider.imageURL = s3URL
                    
                    Riders().updateHouseholdRider(rider, image: nil, completion: { (error) -> Void in
                        if let unwrappedLocalURL = localURL {
                            ImageController.sharedInstance.updateLocalImageCache(rider.id, localUrl: unwrappedLocalURL)
                        }
                        
                        completion(error: error)
                    })
                }
            })
        } else {
            let webServiceController = WebServiceController.sharedInstance
            let endPoint = ServiceEndpoint.HouseholdRiders + rider.id
            let params = rider.riderDictionaryRepresentation()
            
            webServiceController.put(endPoint, parameters: params) { (responseObject, error) -> Void in
                completion(error: error)
            }
        }
    }
}
