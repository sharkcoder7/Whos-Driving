import Foundation
import UIKit

/**
 *  Validates the contents of a UITextField for a valid name.
 */
struct NameFieldValidator {
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

extension NameFieldValidator: FieldValidator {
    
}
