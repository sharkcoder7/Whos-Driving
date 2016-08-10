import UIKit

/**
 Represents the scope of events requested from the server.
 */
enum EventScope {
    /// Filter only for past events.
    case Past
    /// Filter for only present/upcoming events.
    case Upcoming
}

/// Controller for communicating with the carpool about carpool events.
class Events: NSObject {
    
    /**
     Create a carpool event.
     
     - parameter eventDictionary Dictionary containing the details of the event to be created.
     - parameter completion Completion block called when the call to the server completes. If the
                            event was successfully created it will be represented by the newEvent
                            parameter.
     */
    func createEvent(eventDictionary: Dictionary<String, AnyObject>, completion: (newEvent: Event?, error: NSError?) -> Void) {
        let webServiceController = WebServiceController.sharedInstance
        
        webServiceController.post(ServiceEndpoint.Events, parameters: eventDictionary) { (responseObject, error) -> Void in
            if error != nil {
                completion(newEvent: nil, error: error)
            } else {
                let jsonDict = responseObject as! NSDictionary
                if let eventDict = jsonDict[ServiceResponse.DataKey] as? NSDictionary {
                    let event = Event(dictionary: eventDict)
                    completion(newEvent: event, error: error)
                } else {
                    completion(newEvent: nil, error: error)
                }
            }
        }
    }
    
    /**
     Delete an event.
     
     - parameter id The id of the event to delete.
     - parameter completion Completion block called when the call to the server completes.
     */
    func deleteEventById(id: String, completion: (error: NSError?) -> Void) {
        let webServiceController = WebServiceController.sharedInstance
        
        let endpoint = ServiceEndpoint.Events + id
        webServiceController.delete(endpoint, parameters: nil) { (responseObject, error) -> Void in
            completion(error: error)
        }
    }
    
    /**
     Gets the details of an event.
     
     - parameter id The id of the event to retrieve the details of.
     - parameter noUserView Pass in true to indicate the user isn't viewing the page and the last
                            viewed at date won't be updated. Defaults to false.
     - parameter completion Completion block called when the call to the server completes.
     */
    func getEventById(id: String, noUserView: Bool = false, completion: (event: Event?, error: NSError?) -> Void) {
        let webServiceController = WebServiceController.sharedInstance
        let endpoint = ServiceEndpoint.Events + id
        let parameters = [ServiceResponse.NoUserViewKey : noUserView.stringValue()]
        
        webServiceController.get(endpoint, parameters: parameters) { (responseObject, error) -> Void in
            if error != nil {
                completion(event: nil, error: error)
            } else {
                var event: Event?
                let jsonDictionary = responseObject as? NSDictionary
                if let eventDict = jsonDictionary?[ServiceResponse.DataKey] as? NSDictionary {
                    event = Event(dictionary: eventDict)
                }
                
                completion(event: event, error: nil)
            }
        }
    }
    
    /**
     Gets an array of all the events for the current user. This list will be filtered by the provided
     EventScope.
     
     - parameter eventScope The scope of events to get from the server. See EventScope.
     - parameter completion Completion block called when the call to the server completes.
     */
    func getEvents(eventScope: EventScope, completion: (events: [Event], error: NSError?) -> Void) {
        var parameters: [String: String] = [:]

        switch eventScope {
        case .Past:
            parameters = [ServiceRequest.EventScope: ServiceRequest.EventScopePast]
            
        case .Upcoming:
            break
        }

        let webServiceController = WebServiceController.sharedInstance

        webServiceController.get(ServiceEndpoint.Events, parameters: parameters) { responseObject, error in
            if let error = error {
                completion(events: [], error: error)
                return
            }

            let jsonDictionary = responseObject as? NSDictionary
            let dataArray = jsonDictionary?[ServiceResponse.DataKey] as? NSArray
            var events = [Event]()

            if let data = dataArray {
                for eventDictionary in data {
                    let event = Event(dictionary: eventDictionary as! NSDictionary)
                    events.append(event)
                }
            }

            completion(events: events, error: nil)
        }
    }
    
    /**
     Update an event.
     
     - parameter event The event to update.
     - parameter completion Completion block called when the call to the server completes. The
                            changesetNotice parameters contains an array of string descriptions of
                            the changes that were made to the event. This changesetNotice array can
                            then be provided back to the server when calling Notifications().sendNotification.
     */
    func updateEvent(event: Event, completion: (event: Event?, changesetNotice: [String], error: NSError?) -> Void) {
        let webServiceController = WebServiceController.sharedInstance
        
        let params = event.dictionaryRepresentation()
        let endpoint = ServiceEndpoint.Events + event.id
        
        webServiceController.put(endpoint, parameters: params) { (responseObject, error) -> Void in
            if let error = error {
                completion(event: nil, changesetNotice: [], error: error)
            } else {
                let jsonDictionary = responseObject as? NSDictionary
                
                var event: Event?
                var changesetNotice = [String]()
                
                if let data = jsonDictionary?[ServiceResponse.DataKey] as? NSDictionary {
                    event = Event(dictionary: data)
                    changesetNotice = data[ServiceResponse.ChangesetNotice] as? [String] ?? []
                }
                
                completion(event: event, changesetNotice: changesetNotice, error: error)
            }
        }
    }
}
