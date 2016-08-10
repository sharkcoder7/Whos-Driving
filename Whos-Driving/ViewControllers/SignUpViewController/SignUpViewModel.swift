import Foundation

/**
 *  Contains methods for validating the sign up form and determining what errors need to be shown to
 *  the user.
 */
struct SignUpViewModel {
    
    // MARK: Properties
    
    /// Validates the 'Confirm Password' field. It is expected that this property is set by the
    /// owner.
    var confirmPasswordValidator: PasswordFieldValidator!
    
    /// Validates the 'Email' field. It is expected that this property is set by the owner.
    var emailValidator: EmailFieldValidator!
    
    /// Validates the 'First Name' field. It is expected that this property is set by the owner.
    var firstNameValidator: NameFieldValidator!
    
    /// Validates the 'Last Name' field. It is expected that this property is set by the owner.
    var lastNameValidator: NameFieldValidator!
    
    /// Validates the 'Password' field. It is expected that this property is set by the owner.
    var passwordValidator: PasswordFieldValidator!
    
    /// Validates the 'Phone Number' field. It is expected that this property is set by the owner.
    var phoneNumberValidator: PhoneNumberFieldValidator!
    
    // MARK: Instance Methods
    
    /**
     Validates each of the fields on the form.
     
     - returns: a string indicating any error present on the current form.
     */
    func currentFormError() -> String? {
        guard firstNameValidator.isValid() else {
            return "Please enter your first name"
        }
        
        guard lastNameValidator.isValid() else {
            return "Please enter your last name."
        }
        
        guard phoneNumberValidator.isValid() else {
            return "Please enter a valid phone number."
        }
        
        guard emailValidator.isValid() else {
            return "Please enter a valid email address."
        }
        
        guard passwordValidator.isValid() else {
            return "Please enter a password."
        }
        
        guard confirmPasswordValidator.isValid() else {
            return "Please confirm your password."
        }
        
        guard passwordValidator.textField.text == confirmPasswordValidator.textField.text else {
            return "Your passwords do not match. Please retype your passwords."
        }
        
        return nil
    }
    
    /**
     Returns a boolean indicating if the user should be alerted that the 'Email' field is required.
     */
    func showEmailRequiredLabel() -> Bool {
        return emailValidator.isEmpty()
    }
    
    /**
     Returns a boolean indicating if the user should be alerted that the 'First Name' field is
     required.
     */
    func showFirstNameRequiredLabel() -> Bool {
        return firstNameValidator.isEmpty()
    }
    
    /**
     Returns a boolean indicating if the user should be alerted that the 'Last Name' field is
     required.
     */
    func showLastNameRequiredLabel() -> Bool {
        return lastNameValidator.isEmpty()
    }
    
    /**
     Returns a boolean indicating if the user should be alerted that the 'Confirm Password' field is
     required.
     */
    func showPasswordConfirmationRequiredLabel() -> Bool {
        return confirmPasswordValidator.isEmpty()
    }
    
    
    /**
     Returns a boolean indicating if the user should be alerted that the 'Password' field is 
     required.
     */
    func showPasswordRequiredLabel() -> Bool {
        return passwordValidator.isEmpty()
    }
}
