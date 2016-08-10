import Quick
import Nimble

@testable import whos_driving_staging

class PhoneNumberFieldValidatorSpec: QuickSpec {
    override func spec() {
        context("Phone number field is empty") {
            let phoneNumberField = UITextField()
            let unitUnderTest = PhoneNumberFieldValidator(textField: phoneNumberField, fieldIsRequired: true)
            
            it("should return true for isEmpty()") {
                let actual = unitUnderTest.isEmpty()
                expect(actual).to(beTruthy())
            }
        }
        
        context("Phone number field is not empty and phone number is invalid") {
            let phoneNumberField = UITextField()
            phoneNumberField.text = "123-456-7"
            let unitUnderTest = PhoneNumberFieldValidator(textField: phoneNumberField, fieldIsRequired: true)
            
            it("should return false for isEmpty()") {
                expect(unitUnderTest.isEmpty()).to(beFalsy())
            }
            
            it("should return false for isValid()") {
                expect(unitUnderTest.isValid()).to(beFalsy())
            }
        }
        
        context("Phone number field is not empty and phone number is valid") {
            let phoneNumberField = UITextField()
            phoneNumberField.text = "123-456-7890"
            let unitUnderTest = PhoneNumberFieldValidator(textField: phoneNumberField, fieldIsRequired: true)
            
            it("should return false for isEmpty()") {
                expect(unitUnderTest.isEmpty()).to(beFalsy())
            }
            
            it("should return true for isValid()") {
                expect(unitUnderTest.isValid()).to(beTruthy())
            }
        }
    }
}
