import Quick
import Nimble
import UIKit

@testable import whos_driving_staging

class NameFieldValidatorSpec: QuickSpec {
    override func spec() {
        context("Name field is empty") {
            let nameField = UITextField()
            let unitUnderTest = NameFieldValidator(textField: nameField, fieldIsRequired: true)
            
            it("should return true for isEmpty()") {
                expect(unitUnderTest.isEmpty()).to(beTruthy())
            }
            
            it("should return false for isValid()") {
                expect(unitUnderTest.isValid()).to(beFalsy())
            }
        }
        
        context("Name field is not empty") {
            let nameField = UITextField()
            nameField.text = "Test"
            let unitUnderTest = NameFieldValidator(textField: nameField, fieldIsRequired: true)
            
            it("should return false for isEmpty()") {
                expect(unitUnderTest.isEmpty()).to(beFalsy())
            }
            
            it("should return true for isValid()") {
                expect(unitUnderTest.isValid()).to(beTruthy())
            }
        }
    }
}
