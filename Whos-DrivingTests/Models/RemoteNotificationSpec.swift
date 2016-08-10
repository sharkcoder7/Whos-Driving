import Quick
import Nimble

@testable import whos_driving_staging

class RemoteNotificationSpec: QuickSpec {
    
    // MARK: Class methods
    
    static func remoteNotificationFromTestJSON() -> RemoteNotification? {
        if let path = NSBundle.mainBundle().pathForResource("remote_notification", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                do {
                    if let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? [NSObject : AnyObject] {
                        let notification = RemoteNotification(userInfo: json)
                        return notification
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
        it("JSON data should map properly to RemoteNotification object") { () -> () in
            let notification = RemoteNotificationSpec.remoteNotificationFromTestJSON()
            
            expect(notification).toNot(beNil())
            expect(notification?.alert).to(equal("Test alert"))
            expect(notification?.authorId).to(equal("1234567890"))
            expect(notification?.authorName).to(equal("John D"))
            expect(notification?.eventId).to(equal("a1b2c3d4"))
            expect(notification?.type).to(equal(RemoteNotificationType.Delete))
        }
    }
}