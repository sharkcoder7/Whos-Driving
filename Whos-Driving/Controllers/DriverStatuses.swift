import UIKit

/**
 Represents a possible driver_status value to send/get from the server.
 */
enum DriverStatus: String {
    case CanDriveTo = "can_drive_to" // Volunteer to drive to the event.
    case CannotDriveTo = "cannot_drive_to" // Cannot drive to the event
    
    case CanDriveFrom = "can_drive_from" // Volunteer to drive from the event.
    case CannotDriveFrom = "cannot_drive_from" // Cannot drive from the event
    
    case CanDriveToNotFrom = "can_drive_to_not_from" // Volunteer to drive to the event, but cannot drive from.
    case CanDriveFromNotTo = "can_drive_from_not_to" // Volunteer to drive from the event, but cannot drive to.
    case CanDriveToAndFrom = "can_drive_to_and_from" // Volunteer to drive to and from the event.
    case CannotDriveToAndFrom = "cannot_drive_to_and_from" // Cannot drive to nor from the event.
}

/**
 Represents a possible drivers_status_response value returned from the server for driver availabilty.
 */
enum DriverResponse: String {
    case Can = "can" // Driver indicated they can drive
    case Cannot = "cannot" // Driver indicated they cannot drive
}

/**
 After submitting a driver_status to the server, the server returns a driver_status_response element 
 to indicate if there were any conflicting responses from other users.
 */
enum DriverStatusResponse: String {
    case Success = "success" // Event was successfully updated with the driver response
    case Partial = "partial" // Event was updated with the driver response, but one of the responses was already taken by someone else
    case Failure = "failure" // Event was not updated because someone else responded first
}

/**
 A combination of DriverStatus and DriverStatusResponse. This enum is for setting up UI to display
 to a user based on what driver_status they sent to the server, and how it was received.
 */
enum ResponseConfirmation {
    case ToSuccess // response that you can drive TO was successful
    case FromSuccess // response that you can drive FROM was successful
    case BothSuccess // response that you can drive BOTH was successful
    case CannotSuccess // response that you cannot drive was successful
    case CanFailed // response that you can drive failed because someone else responded first.
    case CanPartialSuccess // response that you can drive BOTH partially failed because someone took either TO or FROM first
}

/// Controller for communicating with the server concerning driver status.
class DriverStatuses: NSObject {
    
    // MARK: Instance methods
    
    /**
    Update a driver_status on the server. This is for volunteering to drive TO/FROM/BOTH or indicating
    a user cannot drive for an event.
    
    - parameter response   The response the user is sending about whether they can drive or not.
    - parameter eventId    The event being updated.
    - parameter completion Completion block called when the server returns a response. Error object
                           will contain any errors encountered. The event object will be the most
                           current version of the event on the server. It might not contain the updates
                           user was trying to send if there were conflicts with other people volunteering 
                           as well. The responseConfirmation object represents these potential conflicts.
    */
    func updateDriverStatus(status: DriverStatus, eventId: String, completion: (event: Event?, responseCorfirmation: ResponseConfirmation?, error: NSError?) -> Void) {
        let endpoint = "\(ServiceEndpoint.Events)\(eventId)/\(ServiceEndpoint.DriverStatus)"
        
        let parameters = [ServiceResponse.DrivingActionKey : status.rawValue]
        
        WebServiceController.sharedInstance.put(endpoint, parameters: parameters) { (responseObject, error) -> Void in
            if error != nil {
                completion(event: nil, responseCorfirmation: .CanFailed, error: error)
            } else {
                var event: Event?
                let jsonDictionary = responseObject as? NSDictionary
                if let eventDict = jsonDictionary?[ServiceResponse.DataKey] as? NSDictionary {
                    event = Event(dictionary: eventDict)
                    
                    var responseConfirmation: ResponseConfirmation?
                    if let driverStatusResponseString = eventDict[ServiceResponse.DriverStatusResponseKey] as? String {
                        if let driverStatusResponse = DriverStatusResponse(rawValue: driverStatusResponseString) {
                            responseConfirmation = DriverStatuses.driverStatusAndResponseToConfirmation(status, driverStatusResponse: driverStatusResponse)
                        }
                    }
                    
                    completion(event: event, responseCorfirmation: responseConfirmation, error: error)
                }
            }
        }
    }
    
    // MARK: Class methods
    
    /**
    Determines the ResponseConfirmation to return based on the combination of the DriverStatus
    the user sent to the server, and the DriverStatusResponse returned from the server.
    
    - parameter driverStatus The DriverStatus sent to the server.
    - parameter driverStatusResponse The DriverStatusResponse returned from the server.
    
    - returns: The appropritate ResponseConfirmation for the combination of the driverStatus and
               driverStatusResponse.
    */
    class func driverStatusAndResponseToConfirmation(driverStatus: DriverStatus, driverStatusResponse: DriverStatusResponse) -> ResponseConfirmation {
        switch (driverStatus, driverStatusResponse) {
        case (.CanDriveTo, .Success), (.CanDriveToNotFrom, .Success):
            return .ToSuccess
            
        case (.CanDriveFrom, .Success), (.CanDriveFromNotTo, .Success):
            return .FromSuccess
            
        case (.CanDriveToAndFrom, .Success):
            return .BothSuccess
            
        case (.CannotDriveTo, .Success), (.CannotDriveFrom, .Success), (.CannotDriveToAndFrom, .Success):
            return .CannotSuccess
            
        case (_, .Partial):
            return .CanPartialSuccess
            
        case (_, .Failure):
            return .CanFailed
        }
    }
}
