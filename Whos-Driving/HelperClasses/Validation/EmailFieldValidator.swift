import Foundation
import UIKit

/**
 *  Performs validation on a text field that accepts an email address.
 */
struct EmailFieldValidator {
    // MARK: Properties
    
    var fieldIsRequired: Bool
    
    var textField: UITextField
    
    // MARK: Init Methods
    
    init(textField: UITextField, fieldIsRequired: Bool) {
        self.fieldIsRequired = fieldIsRequired
        self.textField = textField
    }
}

// MARK: FieldValidator Methods

extension EmailFieldValidator: FieldValidator {
    func isValid() -> Bool {
        if fieldIsRequired && isEmpty() {
            return false
        }
        
        return ContactInfoFormatter().validateEmail(textField.text)
    }
}
