import UIKit

/// Controller for communicating with the server about trusted drivers.
class Drivers: NSObject {
    
    // MARK: Instance Methods
    
    /**
    Deletes a trusted driver.
    
    - parameter id The id of the driver being deleted.
    - parameter completion Completion block called when the call to the server completes.
    */
    func deleteTrustedDriver(id: String, completion:(error: NSError?) -> Void) {
        let webServiceController = WebServiceController.sharedInstance
        
        let endpoint = ServiceEndpoint.TrustedDrivers + id
        
        webServiceController.delete(endpoint, parameters: nil) { (responseObject, error) -> Void in
            completion(error: error)
        }
    }

    /**
     Gets an array of all the current users trusted drivers. Optionally, include the current user in
     that array.
     
     - parameter include True to include the current user in the array, false to exclude.
     - parameter completion Completion block called when the call to the server completes.
     */
    func getTrustedDrivers(includeCurrentUser include: Bool, completion:(drivers: Array<Person>?, error: NSError?) -> Void) {
        let endpoint = ServiceEndpoint.TrustedDrivers
        
        let params = [ServiceResponse.IncludeCurrentUserKey : include.stringValue()]
        let webServiceController = WebServiceController.sharedInstance
        
        webServiceController.get(endpoint, parameters: params) { (responseObject, error) -> Void in
            if error != nil {
                completion(drivers: nil, error: error)
            } else {
                var driversArray: Array<Person> = []
                
                if let dataArray = responseObject?.objectForKey(ServiceResponse.DataKey) as? NSArray {
                    for personDictionary in dataArray {
                        if personDictionary is NSDictionary {
                            let person = Person(dictionary: personDictionary as! NSDictionary)
                            driversArray.append(person)
                        }
                    }
                }
                
                completion(drivers: driversArray, error: nil)
            }
        }
    }
}
