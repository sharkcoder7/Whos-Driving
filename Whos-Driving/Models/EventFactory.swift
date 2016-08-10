import UIKit

/// This class is used for creating an Event object on the server.
class EventFactory : NSObject {
    
    /// The person driving from the event.
    var driverFrom: Person?
    
    /// The EventDriverStatus of the EventFactory. Compares driverTo and driverFrom.
    var driverStatus: EventDriverStatus {
        if driverTo == nil && driverFrom == nil {
            return .NoDrivers
        }
        else if driverTo == nil {
            return .NoDriverTo
        }
        else if driverFrom == nil {
            return .NoDriverFrom
        }
        else {
            return .BothDrivers
        }
    }
    
    /// The person driving to the event.
    var driverTo: Person?
    
    /// The date the event ends at.
    var endTime: NSDate?
    
    /// Notes concerning the from leg of the event.
    var fromNotes: String?
    
    /// The location of the event.
    var location: String?
    
    /// The name of the event.
    var name: String?
    
    /// Array of drivers to be notified when this event is created.
    var notificationIds: Array<String>?
    
    /// The people riding from the event.
    var ridersFrom = Array<Person>()
    
    /// The people riding to the event.
    var ridersTo = Array<Person>()
    
    /// The date the event starts at.
    var startTime: NSDate?
    
    /// Notes concerning the to leg of the event.
    var toNotes: String?
    
    /**
     Creates a dictionary of event parameters to pass to the server to create a new event.
     
     - returns: Dictionary to the pass to the server to create a new event.
     */
    func eventDictionary() -> [String : AnyObject] {
        let dateFormatter = AppConfiguration.webServiceDateFormatter()
        
        var startTimeString: String?
        if startTime != nil {
            startTimeString = dateFormatter.stringFromDate(startTime!)
        }
        
        var endTimeString: String?
        if endTime != nil {
            endTimeString = dateFormatter.stringFromDate(endTime!)
        }
        
        var toRiderIds = [String]()
        for rider in ridersTo {
            toRiderIds.append(rider.id)
        }
        
        var fromRiderIds = [String]()
        for rider in ridersFrom {
            fromRiderIds.append(rider.id)
        }
        
        let travelToDetails: [String : AnyObject] = [
            ServiceResponse.DriverIdKey : objOrNull(driverTo?.id),
            ServiceResponse.NoteKey : objOrNull(toNotes),
            ServiceResponse.RidersKey : toRiderIds
        ]
        
        let travelFromDetails: [String : AnyObject] = [
            ServiceResponse.DriverIdKey : objOrNull(driverFrom?.id),
            ServiceResponse.NoteKey : objOrNull(fromNotes),
            ServiceResponse.RidersKey : fromRiderIds
        ]
        
        var notificationsValue: [String: [String]] = [:]
        
        if let notificationIds = notificationIds {
            notificationsValue = [ServiceResponse.DriversKey : notificationIds]
        }
        
        let dictionary: [String : AnyObject] = [
            ServiceResponse.NameKey : objOrNull(name),
            ServiceResponse.LocationKey : objOrNull(location),
            ServiceResponse.StartTimeKey : objOrNull(startTimeString),
            ServiceResponse.EndTimeKey : objOrNull(endTimeString),
            ServiceResponse.TravelToDetailsKey : travelToDetails,
            ServiceResponse.TravelFromDetailsKey : travelFromDetails,
            ServiceResponse.NotificationKey : notificationsValue
        ]
        
        return dictionary
    }
}