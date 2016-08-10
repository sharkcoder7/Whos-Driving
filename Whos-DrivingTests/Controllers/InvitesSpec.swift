import Quick
import Nimble

@testable import whos_driving_staging

class InvitesSpec: QuickSpec {
    
    // MARK: Tests
    
    override func spec() {
        it("getInviteToken returns invite token from URL") { () -> () in
            let inviteURL = NSURL(string: "https://whos-driving-staging.herokuapp.com/invites/a1b2c3d4")
            let token = Invites.getInviteTokenFromURL(inviteURL!)
            let expectedResult = "a1b2c3d4"
         
            expect(token).to(equal(expectedResult))
        }
    }
}