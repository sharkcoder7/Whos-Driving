import UIKit

/**
 *  Represents an event in a carpool's history, such as a user editing a location, volunteering to
 *  drive, etc.
 */
struct EventHistoryItem {

    // MARK: Properties
    
    /// The id of the author of the item.
    let authorId: String?
    
    /// The image URL of the person for this item.
    let authorImageUrl: String?
    
    /// The name of the person for this item.
    let authorName: String
    
    /// The date this item happened.
    let date: NSDate?
    
    /// The message describing what change happened.
    let message: String
    
    // MARK: Init and deinit methods
    
    /**
    Initializes an EventHistoryItem from a JSON dictionary returned from the server. If the values
    in the dictionary are invalid, will return nil.
    
    - parameter dictionary JSON dictionary returned from the server.
    
    - returns: Initialized instance of this class, or nil if the dictionary is invalid.
    */
    init?(dictionary: NSDictionary) {
        guard let unwrappedAuthorName = dictionary[ServiceResponse.NameKey] as? String else {
            dLog("Unable to create EventHistoryItem without author name.")
            return nil
        }
        guard let unwrappedMessage = dictionary[ServiceResponse.DescriptionKey] as? String else {
            dLog("Unable to create EventHistoryItem without description.")
            return nil
        }
        
        authorName = unwrappedAuthorName
        message = unwrappedMessage
        authorImageUrl = dictionary[ServiceResponse.ImageURLKey] as? String
        authorId = dictionary[ServiceResponse.DriverIdKey] as? String
        
        let dateFormatter = AppConfiguration.webServiceDateFormatter()
        if let dateString = dictionary[ServiceResponse.TimeStampKey] as? String {
            date = dateFormatter.dateFromString(dateString)
        } else {
            date = nil
        }
    }
    
    // MARK: Static methods
    
    /**
    Compares the dates of the EventHistoryItems to the date provided and returns an array of 
    EventHistoryItems that have occured since the provided date. If the date is nil, the entire 
    array is returned.
    
    - parameter items Array of EventHistoryItems to compare against the provided date.
    - parameter date The date to use for comparison.
    
    - returns: Array of EventHistoryItems. This array will be empty if the date parameter is nil,
               or none of the items have occured since the provided date.
    */
    static func itemsSinceDate(items: [EventHistoryItem], date: NSDate?) -> [EventHistoryItem] {
        guard let sinceDate = date else {
            return items
        }
        
        var sinceItems = [EventHistoryItem]()
        
        for item in items {
            if item.date?.timeIntervalSinceDate(sinceDate) > 0 {
                sinceItems.append(item)
            }
        }
        
        return sinceItems
    }
}
