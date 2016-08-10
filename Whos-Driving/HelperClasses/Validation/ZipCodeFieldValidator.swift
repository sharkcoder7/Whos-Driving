import Foundation
import UIKit

/**
 *  Verifies the contents of a UITextField contain a valid zip code.
 */
class ZipCodeFieldValidator: NSObject {
    // MARK: Properties
    
    var fieldIsRequired: Bool
    
    var textField: UITextField
    
    // MARK: Init Methods
    
    required init(textField: UITextField, fieldIsRequired: Bool) {
        self.fieldIsRequired = fieldIsRequired
        self.textField = textField
    }
}

// MARK: FieldValidator Methods

extension ZipCodeFieldValidator: FieldValidator {
    
}

// MARK: UITextFieldDelegate Methods

extension ZipCodeFieldValidator: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.characters.count == ContactInfoFormatter().maximumZipCharacters &&
            string.characters.count > 0 {
            // Return false if the field is at its max and the inserting character is not a delete
            return false
        }
        
        return true
    }
}
