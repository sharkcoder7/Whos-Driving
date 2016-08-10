import UIKit

/**
 Describes what drivers are assigned to the event.
 */
enum EventDriverStatus {
    case NoDrivers
    case NoDriverTo
    case NoDriverFrom
    case BothDrivers
}

/**
 The status of the event based on the last time the user viewed the details of this event.
 */
enum EventUpdatedStatus: String {
    case Current = "" // No new updates since the last time the user viewed the details
    case New = "NEW" // The event is new to this driver and they haven't viewed the details
    case Updated = "UPDATED" // The event has been updated since the last time the user viewed the details
}

/// Represents a carpool event.
struct Event: Equatable {

    // MARK: Properties
    
    /// The date the event was created.
    var createdAt: NSDate?
    
    /// The person driving from the event.
    var driverFrom: Person?
    
    /// The EventDriverStatus of the event. Compares driverTo and driverFrom.
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
    
    /// Array of possible DriverStatuses to show to the user.
    var driverResponses = [DriverStatus]()
    
    /// The DriverResponse the current user has sent for driving to the event. Nil if the user
    /// hasn't sent a response yet, or their response was voided by a conflicting edit to the event.
    var driverResponseTo: DriverResponse?
    
    /// The DriverResponse the current user has sent for driving from the event. Nil if the user
    /// hasn't sent a response yet, or their response was voided by a conflicting edit to the event.
    var driverResponseFrom: DriverResponse?
    
    /// The person driving to the event.
    var driverTo: Person?
    
    /// The date the event ends at.
    var endTime: NSDate
    
    /// Chronological list of all the changes made to the event.
    var eventHistory = [EventHistoryItem]()
    
    /// Extra notes for the from leg of the event.
    var fromNotes: String?
    
    /// The server id of the event.
    let id: String
    
    /// The date this event was last viewed by the current user, or nil if it has never been seen.
    var lastReadAt: NSDate?
    
    /// The plain text location of the event.
    var location: String?
    
    /// The name of the event.
    let name: String
    
    /// The id of the person who created the event.
    var ownerId: String?
    
    /// Array of the riders riding from the event.
    var ridersFrom: [Person]?
    
    /// Array of the riders riding to the event.
    var ridersTo: [Person]?
    
    /// Array of drivers eligible to be selected to drive from the event.
    var selectableDriversFrom: [Person]?
    
    /// Array of drivers eligible to be selected to drive to the event.
    var selectableDriversTo: [Person]?
    
    /// Array of riders eligible to be selected to ride from the event.
    var selectableRidersFrom: [Person]?
    
    /// Array of riders eligible to be selected to ride to the event.
    var selectableRidersTo: [Person]?
    
    /// The date the event starts at.
    var startTime: NSDate
    
    /// Extra notes for the to leg of the event.
    var toNotes: String?
    
    /// The date the event was last updated at.
    var updatedAt: NSDate?
    
    /// Compares the lastReadAt and updatedAt dates to determine the EventUpdatedStatus of the event
    /// for the current user.
    var updatedStatus: EventUpdatedStatus {
        if let lastReadAt = lastReadAt {
            guard let updatedAt = updatedAt else {
                dLog("Updated at was nil. This shouldn't happen. Defaulting to current.")
                return .Current
            }
            
            if updatedAt.timeIntervalSinceDate(lastReadAt) > 0 {
                return .Updated
            } else {
                return .Current
            }
        } else {
            return .New
        }
    }
    
    // MARK: Init and deinit methods
    
    /**
    Returns a configured instance of this class using the properties in the JSON dictionary provided.
    
    - parameter dictionary JSON dictionary returned from the server representing an event.
    
    - returns: Configured instance of this class.
    */
    init(dictionary: NSDictionary) {
        let dateFormatter = AppConfiguration.webServiceDateFormatter()
        
        let endTimeString = dictionary[ServiceResponse.EndTimeKey] as! String
        endTime = dateFormatter.dateFromString(endTimeString)!

        let startTimeString = dictionary[ServiceResponse.StartTimeKey] as! String
        startTime = dateFormatter.dateFromString(startTimeString)!
        
        if let createdAtString = dictionary[ServiceResponse.CreatedAtKey] as? String {
            createdAt = dateFormatter.dateFromString(createdAtString)
        }
        
        if let updatedAtString = dictionary[ServiceResponse.UpdatedAtKey] as? String {
            updatedAt = dateFormatter.dateFromString(updatedAtString)
        }
        
        if let statsDictionary = dictionary[ServiceResponse.StatsKey] as? NSDictionary {
            if let lastReadAtString = statsDictionary[ServiceResponse.LastReadAtKey] as? String {
                lastReadAt = dateFormatter.dateFromString(lastReadAtString)
            }
        }

        id = dictionary[ServiceResponse.IdKey] as! String
        name = dictionary[ServiceResponse.NameKey] as! String
        ownerId = dictionary[ServiceResponse.OwnerIdKey] as? String
        location = dictionary[ServiceResponse.LocationKey] as? String
        
        if let travelToDictionary = dictionary[ServiceResponse.TravelToDetailsKey] as? NSDictionary {
            toNotes = travelToDictionary[ServiceResponse.NoteKey] as? String
            
            if let riderDictionaries = travelToDictionary[ServiceResponse.RidersKey] as? Array<NSDictionary> {
                var riders: Array<Person> = Array()
                for riderDictionary: NSDictionary in riderDictionaries {
                    let rider = Person(dictionary: riderDictionary)
                    riders.append(rider)
                }
                ridersTo = riders
            }
            
            let driverDictionary = travelToDictionary.objectForKey(ServiceResponse.DriverKey) as! NSDictionary
            
            if (driverDictionary.objectForKey(ServiceResponse.IdKey) != nil) {
                driverTo = Person(dictionary: driverDictionary)
            }
        }
        
        if let travelFromDictionary = dictionary[ServiceResponse.TravelFromDetailsKey] as? NSDictionary {
            fromNotes = travelFromDictionary[ServiceResponse.NoteKey] as? String
            
            if let riderDictionaries = travelFromDictionary[ServiceResponse.RidersKey] as? Array<NSDictionary> {
                var riders: Array<Person> = Array()
                for riderDictionary: NSDictionary in riderDictionaries {
                    let rider = Person(dictionary: riderDictionary)
                    riders.append(rider)
                }
                ridersFrom = riders
            }
            
            let driverDictionary = travelFromDictionary.objectForKey(ServiceResponse.DriverKey) as! NSDictionary
            
            if (driverDictionary.objectForKey(ServiceResponse.IdKey) != nil) {
                driverFrom = Person(dictionary: driverDictionary)
            }
        }
        
        if let eventHistoryDictionaries = dictionary[ServiceResponse.EventHistoryKey] as? [NSDictionary] {
            var eventHistory = [EventHistoryItem]()
            
            for eventHistoryDict in eventHistoryDictionaries {
                if let historyItem = EventHistoryItem(dictionary: eventHistoryDict) {
                    eventHistory.append(historyItem)
                }
            }
            
            self.eventHistory = eventHistory
        }
        
        if let driverActionsDict = dictionary[ServiceResponse.DriverActionsKey] as? NSDictionary {
            if let driverStatusResponseToString = driverActionsDict[ServiceResponse.DriverStatusResponseToKey] as? String {
                driverResponseTo = DriverResponse(rawValue: driverStatusResponseToString)
            }
            
            if let driverStatusResponseFromString = driverActionsDict[ServiceResponse.DriverStatusResponseFromKey] as? String {
                driverResponseFrom = DriverResponse(rawValue: driverStatusResponseFromString)
            }
            
            if let driverResponsesArray = driverActionsDict[ServiceResponse.CanDriveAvailabilityKey] as? [String] {
                var driverResponses = [DriverStatus]()
                
                for responseString in driverResponsesArray {
                    if let response = DriverStatus(rawValue: responseString) {
                        driverResponses.append(response)
                    }
                }
                
                self.driverResponses = driverResponses
            }
        }
        
        if let usersDict = dictionary[ServiceResponse.UsersKey] as? NSDictionary {
            if let drivers = usersDict[ServiceResponse.SelectableDriversFromKey] as? Array<NSDictionary> {
                var selectableDrivers = [Person]()
                for driverDict in drivers {
                    let driver = Person(dictionary: driverDict)
                    selectableDrivers.append(driver)
                }
                selectableDriversFrom = selectableDrivers
            }
            
            if let drivers = usersDict[ServiceResponse.SelectableDriversToKey] as? Array<NSDictionary> {
                var selectableDrivers = [Person]()
                for driverDict in drivers {
                    let driver = Person(dictionary: driverDict)
                    selectableDrivers.append(driver)
                }
                selectableDriversTo = selectableDrivers
            }
            
            if let riders = usersDict[ServiceResponse.SelectableRidersFromKey] as? Array<NSDictionary> {
                var selectableRiders = [Person]()
                for riderDict in riders {
                    let rider = Person(dictionary: riderDict)
                    selectableRiders.append(rider)
                }
                selectableRidersFrom = selectableRiders
            }
            
            if let riders = usersDict[ServiceResponse.SelectableRidersToKey] as? Array<NSDictionary> {
                var selectableRiders = [Person]()
                for riderDict in riders {
                    let rider = Person(dictionary: riderDict)
                    selectableRiders.append(rider)
                }
                selectableRidersTo = selectableRiders
            }
        }
    }
    
    // MARK: Instance methods
    
    /**
    Returns a dictionary representation of the Event, used for sending as params to the server to
    update the event. Only properties that can be updated on the server are included.
    
    @return dictionary representation of the Event
    */
    func dictionaryRepresentation() -> [String: AnyObject] {
        
        var toRiderIds = [String]()
        if ridersTo != nil {
            for rider in ridersTo! {
                toRiderIds.append(rider.id)
            }
        }
        
        var fromRiderIds = [String]()
        if ridersFrom != nil {
            for rider in ridersFrom! {
                fromRiderIds.append(rider.id)
            }
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
        
        let dateFormatter = AppConfiguration.webServiceDateFormatter()

        let dictionaryRep = [
            ServiceResponse.LocationKey : objOrNull(location),
            ServiceResponse.TravelFromDetailsKey : travelFromDetails,
            ServiceResponse.TravelToDetailsKey : travelToDetails,
            ServiceResponse.StartTimeKey : dateFormatter.stringFromDate(startTime),
            ServiceResponse.EndTimeKey : dateFormatter.stringFromDate(endTime)
        ]
        
        return dictionaryRep
    }
}

// MARK: Equatable

func ==(lhs: Event, rhs: Event) -> Bool {
    return lhs.id == rhs.id
}
