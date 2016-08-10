import Quick
import Nimble

@testable import whos_driving_staging

class EventSpec: QuickSpec {
    
    // MARK: Class methods
    
    static func eventFromTestJSON() -> Event? {
        if let path = NSBundle.mainBundle().pathForResource("event", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                do {
                    if let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                        let event = Event(dictionary: json)
                        return event
                    }
                } catch let error {
                    print("JSON error: \(error)")
                }
            }
        }
        
        return nil
    }
    
    // MARK: Tests
    
    override func spec() {
        it("JSON data should map properly to Event object") { () -> () in
            let event = EventSpec.eventFromTestJSON()
            
            expect(event).toNot(beNil())
            expect(event?.name).to(equal("Kiddy Code School"))
            expect(event?.location).to(equal("2913 Harriet Ave S, Minneapolis, MN 55407"))
            expect(event?.ownerId).to(equal("eaa0eb00-aa52-4bbc-a9a6-0ecbf6d2b62a"))
            expect(event?.driverTo?.firstName).to(equal("Jane"))
            expect(event?.toNotes).to(equal("Pick-up all riders at school."))
            expect(event?.ridersTo?.count).to(equal(2))
            expect(event?.driverFrom).to(beNil())
            expect(event?.ridersFrom?.count).to(equal(2))
            expect(event?.eventHistory.count).to(equal(5))
            expect(event?.driverResponses.count).to(equal(2))
            expect(event?.selectableDriversFrom?.count).to(equal(1))
            expect(event?.selectableDriversTo?.count).to(equal(1))
            expect(event?.selectableRidersFrom?.count).to(equal(2))
            expect(event?.selectableRidersTo?.count).to(equal(2))
            expect(event?.fromNotes).to(equal("Drop off all riders at home."))
            expect(event?.driverStatus).to(equal(EventDriverStatus.NoDriverFrom))
            expect(event?.updatedStatus).to(equal(EventUpdatedStatus.Current))
        }
    }
}