import Quick
import Nimble

@testable import whos_driving_staging

class EmailFieldValidatorSpec: QuickSpec {
    override func spec() {
        context("Field is empty") {
            let emailField = UITextField()
            let unitUnderTest = EmailFieldValidator(textField: emailField, fieldIsRequired: true)
            
            it("should return true for isEmpty()") {
                expect(unitUnderTest.isEmpty()).to(beTruthy())
            }
            
            it("should return false for isValid()") {
                expect(unitUnderTest.isValid()).to(beFalsy())
            }
        }
        
        context("Field is not empty and contains an invalid email address") {
            let emailField = UITextField()
            emailField.text = "test@test"
            let unitUnderTest = EmailFieldValidator(textField: emailField, fieldIsRequired: true)
            
            it("should return false for isEmpty()") {
                expect(unitUnderTest.isEmpty()).to(beFalsy())
            }
            
            it("should return false for isValid()") {
                expect(unitUnderTest.isValid()).to(beFalsy())
            }
        }
        
        context("Field is not empty and contains a valid email address") {
            let emailField = UITextField()
            emailField.text = "test@test.com"
            let unitUnderTest = EmailFieldValidator(textField: emailField, fieldIsRequired: true)
            
            it("should return false for isEmpty()") {
                expect(unitUnderTest.isEmpty()).to(beFalsy())
            }
            
            it("should return true for isValid()") {
                expect(unitUnderTest.isValid()).to(beTruthy())
            }
        }
    }
}
