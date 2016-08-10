import UIKit

/// Data source for carpool Events. Use the dataArray property as the datasource for a table view or
/// collection view.
class EventsDataSource: NSObject {
    
    // MARK: Properties
    
    /// All of the events.
    var allEvents = [Event]()
    
    /// Organized version of allEvents sorted into an array of Event arrays. Each first level array
    /// represents a section in the table view organized by date of the Event. Each Event in that 
    /// section array represents a row.
    var dataArray = [[Event]]()

    // MARK: Init and deinit methods
    
    /**
    Initializes an instance of this class with the provided array of Event objects.
    
    - parameter events The Event objects to sort into arrays by their start dates.
    
    - returns: Configured instance of this class.
    */
    init(events: [Event]) {
        allEvents = events
        
        super.init()
        
        populateDataArray()
    }
    
    // MARK: Instance methods
    
    /**
    Returns the Event associated with the provided index path.
    
    - parameter indexPath Index path of the Event.
    
    - returns: The Event for the provided index path.
    */
    func eventForIndexPath(indexPath: NSIndexPath) -> Event {
        let sectionArray = dataArray[indexPath.section]
        return sectionArray[indexPath.row]
    }
    
    // MARK: Private methods
    
    /**
    Sorts the allEvents array into an array of Event arrays and saves it to the dataArray property.
    */
    private func populateDataArray() {
        let dayDateFormatter = NSDateFormatter()
        dayDateFormatter.dateFormat = "yyyy-MM-dd"
        
        var groupedDictionary = Dictionary<String, [Event]>()
        
        for event in allEvents {
            let eventDateKey = dayDateFormatter.stringFromDate(event.startTime)
            var dayArray = groupedDictionary[eventDateKey]
            
            if dayArray == nil {
                dayArray = [Event]()
            }
            
            dayArray!.append(event)
            groupedDictionary.updateValue(dayArray!, forKey: eventDateKey)
        }
        
        var groupedArray = [Array<Event>]()
        let sortedKeys = Array(groupedDictionary.keys).sort(<)
        
        for key in sortedKeys {
            let dayArray = groupedDictionary[key]
            
            if dayArray != nil {
                groupedArray.append(dayArray!)
            }
        }
        
        dataArray = groupedArray
    }
}
