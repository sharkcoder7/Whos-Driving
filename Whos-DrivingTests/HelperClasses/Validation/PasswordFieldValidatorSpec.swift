import Quick
import Nimble

@testable import whos_driving_staging

class PasswordFieldValidatorSpec: QuickSpec {
    override func spec() {
        context("Password field is empty") {
            let passwordField = UITextField()
            let unitUnderTest = PasswordFieldValidator(textField: passwordField, fieldIsRequired: true)
            
            it("should return true for isEmpty()") {
                expect(unitUnderTest.isEmpty()).to(beTruthy())
            }
            
            it("should return false for isValid()") {
                expect(unitUnderTest.isValid()).to(beFalsy())
            }
        }
        
        context("Password field is not empty") {
            let passwordField = UITextField()
            passwordField.text = "testing"
            let unitUnderTest = PasswordFieldValidator(textField: passwordField, fieldIsRequired: true)
            
            it("should return false for isEmpty()") {
                expect(unitUnderTest.isEmpty()).to(beFalsy())
            }
            
            it("should return true for isValid()") {
                expect(unitUnderTest.isValid()).to(beTruthy())
            }
        }
    }
}
