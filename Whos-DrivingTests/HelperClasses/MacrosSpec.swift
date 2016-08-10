import Quick
import Nimble

@testable import whos_driving_staging

class MacrosSpec: QuickSpec {
    
    // MARK: Tests
    
    override func spec() {
        describe("objOrNull") { () -> () in
            it("should return a string", closure: { () -> () in
                let object = "string object"
                let obj = objOrNull(object)
                
                expect(obj).toNot(beNil())
            })
            
            it("should not return NSNull when passed an object", closure: { () -> () in
                let object = ["Test"]
                let obj = objOrNull(object)
                
                expect(obj is NSNull).to(beFalse())
            })
            
            it("should return null", closure: { () -> () in
                let nullObj = objOrNull(nil)
                
                expect(nullObj is NSNull).to(beTrue())
            })
            
            it("should return null for empty string", closure: { () -> () in
                let nullObj = objOrNull("   ")
                
                expect(nullObj is NSNull).to(beTrue())
            })
        }
    }
}