import Quick
import Nimble

@testable import whos_driving_staging

class EventHistoryItemSpec: QuickSpec {
    
    // MARK: Class methods
    
    static func eventHistoryItemFromTestJSON() -> EventHistoryItem? {
        if let path = NSBundle.mainBundle().pathForResource("event_history_item", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                do {
                    if let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                        let item = EventHistoryItem(dictionary: json)
                        return item
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
        it("JSON data should map properly to EventHistoryItem object") { () -> () in
            let item = EventHistoryItemSpec.eventHistoryItemFromTestJSON()
            
            expect(item).toNot(beNil())
            expect(item?.authorId).to(equal("3f2e53a7-96d4-4c2c-94b6-9c38076d43c9"))
            expect(item?.authorName).to(equal("Jane D"))
            expect(item?.authorImageUrl).to(equal("/uploads/test/user/image/3f2e53a7-96d4-4c2c-94b6-9c38076d43c9/thumb_9a3c964a-fe87-42e0-a187-aa82d96b6b1e.jpg"))
            expect(item?.date).toNot(beNil())
            expect(item?.message).to(equal("Change 1"))
        }
    }
}