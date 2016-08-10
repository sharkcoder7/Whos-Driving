import Quick
import Nimble

@testable import whos_driving_staging

class PersonSpec: QuickSpec {
    
    // MARK: Class methods
    
    static func personFromTestJSON() -> Person? {
        if let path = NSBundle.mainBundle().pathForResource("person", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                do {
                    if let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                        let person = Person(dictionary: json)
                        return person
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
        it("JSON data should map properly to Person object") { () -> () in
            let person = PersonSpec.personFromTestJSON()
            
            expect(person).toNot(beNil())
            expect(person?.address.line1).to(equal("555 Rock Ridge Road"))
            expect(person?.address.line2).to(beNil())
            expect(person?.address.city).to(equal("Dallas"))
            expect(person?.address.state).to(equal("TX"))
            expect(person?.address.zip).to(equal("75201"))
            expect(person?.displayName).to(equal("Jane D"))
            expect(person?.email).to(equal("user_547@example.com"))
            expect(person?.firstName).to(equal("Jane"))
            expect(person?.fullName).to(equal("Jane Doe"))
            expect(person?.householdRiders.count).to(equal(2))
            expect(person?.id).to(equal("62ea7f97-99e7-4d97-a268-764de6e7292c"))
            expect(person?.imageURL).to(equal("/uploads/test/user/image/62ea7f97-99e7-4d97-a268-764de6e7292c/thumb_50ef744e-d19b-4639-9669-8fda80d9a7a3.jpg"))
            expect(person?.lastName).to(equal("Doe"))
            expect(person?.licensedDriver).to(beTrue())
            expect(person?.partner?.firstName).to(equal("Bobby"))
            expect(person?.phoneNumber).to(equal("5555554444"))
            expect(person?.relationship).to(equal(Relationship.CurrentUser))
        }
    }
}