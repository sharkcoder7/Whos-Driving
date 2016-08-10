import Foundation
import UIKit

/**
 *  Validates the contents of a UITextField for a valid password.
 */
struct PasswordFieldValidator {
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

extension PasswordFieldValidator: FieldValidator {
    
}
