import Quick
import Nimble

@testable import whos_driving_staging

class ContactInfoFormatterSpec: QuickSpec {
    
    // MARK: Tests
    
    override func spec() {
        let contactInfoFormatter = ContactInfoFormatter()

        it("returns true for valid email") { () -> () in
            var testEmail = "test@testing.com"
            var valid = contactInfoFormatter.validateEmail(testEmail)
            
            expect(valid).to(beTrue())
            
            testEmail = "t@t.tt"
            valid = contactInfoFormatter.validateEmail(testEmail)
            
            expect(valid).to(beTrue())
        }
        
        it("returns false for invalid email") { () -> () in
            var testInvalidEmail = "test.testing.com"
            var valid = contactInfoFormatter.validateEmail(testInvalidEmail)
            
            expect(valid).to(beFalse())
            
            testInvalidEmail = "test.testing@com"
            valid = contactInfoFormatter.validateEmail(testInvalidEmail)
            
            expect(valid).to(beFalse())
            
            testInvalidEmail = "test@testing@c"
            valid = contactInfoFormatter.validateEmail(testInvalidEmail)
            
            expect(valid).to(beFalse())
        }
        
        it("formats strings to phone strings") { () -> () in
            var phoneString = "1234567890"
            var formattedPhoneString = contactInfoFormatter.phoneStringFromString(phoneString)
            var expectedResult = "123-456-7890"
            
            expect(formattedPhoneString).to(equal(expectedResult))
            
            phoneString = "12345678"
            formattedPhoneString = contactInfoFormatter.phoneStringFromString(phoneString)
            expectedResult = "123-456-78"
            
            expect(formattedPhoneString).to(equal(expectedResult))
            
            phoneString = "123"
            formattedPhoneString = contactInfoFormatter.phoneStringFromString(phoneString)
            expectedResult = "123"
            
            expect(formattedPhoneString).to(equal(expectedResult))
        }
        
        it("formats phone strings to strings") { () -> () in
            var formattedPhoneString = "123-456-7890"
            var phoneString = contactInfoFormatter.stringFromPhoneString(formattedPhoneString)
            var expectedResult = "1234567890"
            
            expect(phoneString).to(equal(expectedResult))
            
            formattedPhoneString = "123-456-78"
            phoneString = contactInfoFormatter.stringFromPhoneString(formattedPhoneString)
            expectedResult = "12345678"
            
            expect(phoneString).to(equal(expectedResult))
            
            formattedPhoneString = "12345678"
            phoneString = contactInfoFormatter.stringFromPhoneString(formattedPhoneString)
            expectedResult = "12345678"
            
            expect(phoneString).to(equal(expectedResult))
            
            formattedPhoneString = "(123) 456-7890"
            phoneString = contactInfoFormatter.stringFromPhoneString(formattedPhoneString)
            expectedResult = "1234567890"
            
            expect(phoneString).to(equal(expectedResult))
        }
        
        it("returns true for valid phone strings") { () -> () in
            var validPhoneNumber = "1234567890"
            var valid = contactInfoFormatter.validatePhoneString(validPhoneNumber)
            
            expect(valid).to(beTrue())
            
            validPhoneNumber = "123-456-7890"
            valid = contactInfoFormatter.validatePhoneString(validPhoneNumber)
            
            expect(valid).to(beTrue())
            
            validPhoneNumber = ""
            valid = contactInfoFormatter.validatePhoneString(validPhoneNumber)
            
            expect(valid).to(beTrue())
        }
        
        it("returns false for invalid phone strings") { () -> () in
            var invalidPhoneNumber = "123"
            var valid = contactInfoFormatter.validatePhoneString(invalidPhoneNumber)
            
            expect(valid).to(beFalse())
            
            invalidPhoneNumber = "123-456-78"
            valid = contactInfoFormatter.validatePhoneString(invalidPhoneNumber)
            
            expect(valid).to(beFalse())
        }
        
        it("validates zip codes") { () -> () in
            let validZip = "12345"
            var valid = contactInfoFormatter.validateZip(validZip)
            
            expect(valid).to(beTrue())
            
            let invalidZip = "123"
            valid = contactInfoFormatter.validateZip(invalidZip)
            
            expect(valid).to(beFalse())
        }
    }
}
