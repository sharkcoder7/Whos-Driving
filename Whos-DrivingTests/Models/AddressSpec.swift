import Quick
import Nimble

@testable import whos_driving_staging

class AddressSpec: QuickSpec {
    
    // MARK: Tests
    
    override func spec() {
        it("returns expected address string", closure: { () -> () in
            let address = Address(line1: "123 fake street", line2: nil, city: "Minneapolis", state: "MN", zip: "12345")
            let addressString = address.addressString()
            let expectedResult = "123 fake street\nMinneapolis, MN 12345"
            
            expect(addressString).to(equal(expectedResult))
        })
        
        it("returns expected address string", closure: { () -> () in
            let address = Address(line1: "123 fake street", line2: nil, city: "Minneapolis", state: "MN", zip: nil)
            let addressString = address.addressString()
            let expectedResult = "123 fake street\nMinneapolis, MN"
            
            expect(addressString).to(equal(expectedResult))
        })
        
        it("returns expected address string", closure: { () -> () in
            let address = Address(line1: "123 fake street", line2: nil, city: nil, state: nil, zip: nil)
            let addressString = address.addressString()
            let expectedResult = "123 fake street"
            
            expect(addressString).to(equal(expectedResult))
        })
        
        it("returns expected address string", closure: { () -> () in
            let address = Address(line1: nil, line2: nil, city: "Minneapolis", state: "MN", zip: nil)
            let addressString = address.addressString()
            let expectedResult = "Minneapolis, MN"
            
            expect(addressString).to(equal(expectedResult))
        })
        
        it("returns expected address string", closure: { () -> () in
            let address = Address(line1: nil, line2: nil, city: nil, state: nil, zip: nil)
            let addressString = address.addressString()
            let expectedResult = ""
            
            expect(addressString).to(equal(expectedResult))
        })
        
        it("returns expected address string", closure: { () -> () in
            let address = Address(line1: "    ", line2: nil, city: nil, state: "MN", zip: nil)
            let addressString = address.addressString()
            let expectedResult = "MN"
            
            expect(addressString).to(equal(expectedResult))
        })
        
        it("returns expected address string", closure: { () -> () in
            let address = Address(line1: nil, line2: nil, city: nil, state: "MN", zip: "12345")
            let addressString = address.addressString()
            let expectedResult = "MN 12345"
            
            expect(addressString).to(equal(expectedResult))
        })
        
        it("returns expected address string", closure: { () -> () in
            let address = Address(line1: nil, line2: nil, city: "   Minneapolis ", state: "  MN", zip: "  12345  ")
            let addressString = address.addressString()
            let expectedResult = "Minneapolis, MN 12345"
            
            expect(addressString).to(equal(expectedResult))
        })
        
        it("returns expected address string", closure: { () -> () in
            let address = Address(line1: "123 fake street", line2: "apt# 666", city: "Minneapolis", state: "MN", zip: "12345")
            let addressString = address.addressString()
            let expectedResult = "123 fake street\napt# 666\nMinneapolis, MN 12345"
            
            expect(addressString).to(equal(expectedResult))
        })
        
        it("returns expected address string", closure: { () -> () in
            let address = Address(line1: "123 fake street", line2: "apt# 666", city: nil, state: "MN", zip: "12345")
            let addressString = address.addressString()
            let expectedResult = "123 fake street\napt# 666\nMN 12345"
            
            expect(addressString).to(equal(expectedResult))
        })
        
        it("returns expected address string", closure: { () -> () in
            let address = Address(line1: "123 fake street", line2: "apt# 666", city: nil, state: nil, zip: nil)
            let addressString = address.addressString()
            let expectedResult = "123 fake street\napt# 666"
            
            expect(addressString).to(equal(expectedResult))
        })
        
        it("returns expected address string", closure: { () -> () in
            let address = Address(line1: nil, line2: "apt# 666  ", city: "Minneapolis", state: "MN", zip: "12345")
            let addressString = address.addressString()
            let expectedResult = "apt# 666\nMinneapolis, MN 12345"
            
            expect(addressString).to(equal(expectedResult))
        })
    }
}