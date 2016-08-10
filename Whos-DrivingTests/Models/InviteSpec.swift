import Quick
import Nimble

@testable import whos_driving_staging

class InviteSpec: QuickSpec {
    
    // MARK: Class methods
    
    static func inviteFromTestJSON() -> Invite? {
        if let path = NSBundle.mainBundle().pathForResource("invite", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                do {
                    if let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                        let invite = Invite(dictionary: json)
                        return invite
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
        it("JSON data should map properly to Invite object") { () -> () in
            let invite = InviteSpec.inviteFromTestJSON()
            
            expect(invite).toNot(beNil())
            expect(invite?.invitedDriver.firstName).to(equal("Jane"))
            expect(invite?.inviteToken).to(equal("999d6e1ef5"))
            expect(invite?.invitingDriver.firstName).to(equal("Bobby"))
            expect(invite?.status).to(equal(InviteStatus.OK))
            expect(invite?.statusDetail).to(equal("Accepting the invitation will make Jane a trusted driver for you too."))
            expect(invite?.statusMessage).to(equal("Jane Doe would like to add you as a trusted driver."))
            expect(invite?.type).to(equal(InviteType.Trusted))
        }
    }
}