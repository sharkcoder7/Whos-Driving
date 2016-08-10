import Quick
import Nimble

@testable import whos_driving_staging

class SignUpViewModelSpec: QuickSpec {
    override func spec() {
        var unitUnderTest = SignUpViewModel()
        
        let firstNameTextField = UITextField()
        let lastNameTextField = UITextField()
        let phoneNumberTextField = UITextField()
        let emailTextField = UITextField()
        let passwordTextField = UITextField()
        let confirmPasswordTextField = UITextField()
        
        beforeEach {
            firstNameTextField.text = nil
            lastNameTextField.text = nil
            phoneNumberTextField.text = nil
            emailTextField.text = nil
            passwordTextField.text = nil
            confirmPasswordTextField.text = nil
            
            unitUnderTest.firstNameValidator = NameFieldValidator(textField: firstNameTextField, fieldIsRequired: true)
            unitUnderTest.lastNameValidator = NameFieldValidator(textField: lastNameTextField, fieldIsRequired: true)
            unitUnderTest.phoneNumberValidator = PhoneNumberFieldValidator(textField: phoneNumberTextField, fieldIsRequired: false)
            unitUnderTest.emailValidator = EmailFieldValidator(textField: emailTextField, fieldIsRequired: true)
            unitUnderTest.passwordValidator = PasswordFieldValidator(textField: passwordTextField, fieldIsRequired: true)
            unitUnderTest.confirmPasswordValidator = PasswordFieldValidator(textField: confirmPasswordTextField, fieldIsRequired: true)
        }
        
        context("All fields are empty") {
            it("should show the email is required label") {
                emailTextField.text = nil
                expect(unitUnderTest.showEmailRequiredLabel()).to(beTruthy())
            }
            
            it("should show the first name is required label") {
                firstNameTextField.text = nil
                expect(unitUnderTest.showFirstNameRequiredLabel()).to(beTruthy())
            }
            
            it("should show the last name is required label") {
                lastNameTextField.text = nil
                expect(unitUnderTest.showLastNameRequiredLabel()).to(beTruthy())
            }
            
            it("should show the password is required label") {
                passwordTextField.text = nil
                expect(unitUnderTest.showPasswordRequiredLabel()).to(beTruthy())
            }
            
            it("should show the password confirmation is required label") {
                confirmPasswordTextField.text = nil
                expect(unitUnderTest.showPasswordConfirmationRequiredLabel()).to(beTruthy())
            }
        }
        
        context("First name is provided") {
            it("should show the email is required label") {
                expect(unitUnderTest.showEmailRequiredLabel()).to(beTruthy())
            }
            
            it("should not show the first name is required label") {
                firstNameTextField.text = "Test"
                expect(unitUnderTest.showFirstNameRequiredLabel()).to(beFalsy())
            }
            
            it("should show the last name is required label") {
                expect(unitUnderTest.showLastNameRequiredLabel()).to(beTruthy())
            }
            
            it("should show the password is required label") {
                expect(unitUnderTest.showPasswordRequiredLabel()).to(beTruthy())
            }
            
            it("should show the password confirmation is required label") {
                expect(unitUnderTest.showPasswordConfirmationRequiredLabel()).to(beTruthy())
            }
        }
        
        context("First name and last name is provided") {
            it("should show the email is required label") {
                expect(unitUnderTest.showEmailRequiredLabel()).to(beTruthy())
            }
            
            it("should not show the first name is required label") {
                firstNameTextField.text = "Tester"
                expect(unitUnderTest.showFirstNameRequiredLabel()).to(beFalsy())
            }
            
            it("should not show the last name is required label") {
                lastNameTextField.text = "McTestyface"
                expect(unitUnderTest.showLastNameRequiredLabel()).to(beFalsy())
            }
            
            it("should show the password is required label") {
                expect(unitUnderTest.showPasswordRequiredLabel()).to(beTruthy())
            }
            
            it("should show the password confirmation is required label") {
                expect(unitUnderTest.showPasswordConfirmationRequiredLabel()).to(beTruthy())
            }
        }
        
        context("First name, last name, and email is provided") {
            context("email is invalid") {
                it("should not show the email is required label") {
                    emailTextField.text = "tester@test"
                    expect(unitUnderTest.showEmailRequiredLabel()).to(beFalsy())
                }
                
                it("should not show the first name is required label") {
                    firstNameTextField.text = "Tester"
                    expect(unitUnderTest.showFirstNameRequiredLabel()).to(beFalsy())
                }
                
                it("should not show the last name is required label") {
                    lastNameTextField.text = "McTestyface"
                    expect(unitUnderTest.showLastNameRequiredLabel()).to(beFalsy())
                }
                
                it("should show the password is required label") {
                    expect(unitUnderTest.showPasswordRequiredLabel()).to(beTruthy())
                }
                
                it("should show the password confirmation is required label") {
                    expect(unitUnderTest.showPasswordConfirmationRequiredLabel()).to(beTruthy())
                }
            }
            
            context("email is valid") {
                it("should not show the email is required label") {
                    emailTextField.text = "tester@mctestyface.com"
                    expect(unitUnderTest.showEmailRequiredLabel()).to(beFalsy())
                }
                
                it("should not show the first name is required label") {
                    firstNameTextField.text = "Tester"
                    expect(unitUnderTest.showFirstNameRequiredLabel()).to(beFalsy())
                }
                
                it("should not show the last name is required label") {
                    lastNameTextField.text = "McTestyface"
                    expect(unitUnderTest.showLastNameRequiredLabel()).to(beFalsy())
                }
                
                it("should show the password is required label") {
                    expect(unitUnderTest.showPasswordRequiredLabel()).to(beTruthy())
                }
                
                it("should show the password confirmation is required label") {
                    expect(unitUnderTest.showPasswordConfirmationRequiredLabel()).to(beTruthy())
                }
            }
        }
        
        context("First name, last name, email, and password is provided") {
            it("should not show the email is required label") {
                emailTextField.text = "tester@mctestyface.com"
                expect(unitUnderTest.showEmailRequiredLabel()).to(beFalsy())
            }
            
            it("should not show the first name is required label") {
                firstNameTextField.text = "Tester"
                expect(unitUnderTest.showFirstNameRequiredLabel()).to(beFalsy())
            }
            
            it("should not show the last name is required label") {
                lastNameTextField.text = "McTestyface"
                expect(unitUnderTest.showLastNameRequiredLabel()).to(beFalsy())
            }
            
            it("should not show the password is required label") {
                passwordTextField.text = "ILikeToTest"
                expect(unitUnderTest.showPasswordRequiredLabel()).to(beFalsy())
            }
            
            it("should show the password confirmation is required label") {
                expect(unitUnderTest.showPasswordConfirmationRequiredLabel()).to(beTruthy())
            }
        }
        
        context("All field have been provided") {
            it("should not show the email is required label") {
                emailTextField.text = "tester@mctestyface.com"
                expect(unitUnderTest.showEmailRequiredLabel()).to(beFalsy())
            }
            
            it("should not show the first name is required label") {
                firstNameTextField.text = "Tester"
                expect(unitUnderTest.showFirstNameRequiredLabel()).to(beFalsy())
            }
            
            it("should not show the last name is required label") {
                lastNameTextField.text = "McTestyface"
                expect(unitUnderTest.showLastNameRequiredLabel()).to(beFalsy())
            }
            
            it("should not show the password is required label") {
                passwordTextField.text = "ILikeToTest"
                expect(unitUnderTest.showPasswordRequiredLabel()).to(beFalsy())
            }
            
            it("should not show the password confirmation is required label") {
                confirmPasswordTextField.text = "test"
                expect(unitUnderTest.showPasswordConfirmationRequiredLabel()).to(beFalsy())
            }
            
            context("First name is empty") {
                it("should return an error") {
                    firstNameTextField.text = ""
                    lastNameTextField.text = "McTestyface"
                    phoneNumberTextField.text = nil
                    emailTextField.text = "tester@mctestyface.com"
                    passwordTextField.text = "ILikeToTest"
                    confirmPasswordTextField.text = "test"
                    
                    expect(unitUnderTest.currentFormError()).toNot(beNil())
                }
            }
            
            context("Last name is empty") {
                it("should return an error") {
                    firstNameTextField.text = "Tester"
                    lastNameTextField.text = ""
                    phoneNumberTextField.text = nil
                    emailTextField.text = "tester@mctestyface.com"
                    passwordTextField.text = "ILikeToTest"
                    confirmPasswordTextField.text = "test"
                    
                    expect(unitUnderTest.currentFormError()).toNot(beNil())
                }
            }
            
            context("Email is invalid") {
                it("should return an error") {
                    firstNameTextField.text = "Tester"
                    lastNameTextField.text = "McTestyface"
                    phoneNumberTextField.text = nil
                    emailTextField.text = "tester@test"
                    passwordTextField.text = "ILikeToTest"
                    confirmPasswordTextField.text = "test"
                    
                    expect(unitUnderTest.currentFormError()).toNot(beNil())
                }
            }
            
            context("Password is empty") {
                it("should return an error") {
                    firstNameTextField.text = "Tester"
                    lastNameTextField.text = "McTestyface"
                    phoneNumberTextField.text = nil
                    emailTextField.text = "tester@mctestyface.com"
                    passwordTextField.text = ""
                    confirmPasswordTextField.text = "test"
                    
                    expect(unitUnderTest.currentFormError()).toNot(beNil())
                }
            }
            
            context("Password confirmation is empty") {
                it("should return an error") {
                    firstNameTextField.text = "Tester"
                    lastNameTextField.text = "McTestyface"
                    phoneNumberTextField.text = nil
                    emailTextField.text = "tester@mctestyface.com"
                    passwordTextField.text = "ILikeToTest"
                    confirmPasswordTextField.text = ""
                    
                    expect(unitUnderTest.currentFormError()).toNot(beNil())
                }
            }
            
            context("password does not match the confirmation password") {
                it("should return an error") {
                    firstNameTextField.text = "Tester"
                    lastNameTextField.text = "McTestyface"
                    phoneNumberTextField.text = nil
                    emailTextField.text = "tester@mctestyface.com"
                    passwordTextField.text = "ILikeToTest"
                    confirmPasswordTextField.text = "test"
                    
                    expect(unitUnderTest.currentFormError()).toNot(beNil())
                }
            }
            
            context("password matches the confirmation password") {
                it("should not return an error") {
                    firstNameTextField.text = "Tester"
                    lastNameTextField.text = "McTestyface"
                    phoneNumberTextField.text = nil
                    emailTextField.text = "tester@mctestyface.com"
                    passwordTextField.text = "ILikeToTest"
                    confirmPasswordTextField.text = "ILikeToTest"
                    
                    expect(unitUnderTest.currentFormError()).to(beNil())
                }
            }
        }
    }
}