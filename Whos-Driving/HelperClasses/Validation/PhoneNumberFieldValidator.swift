import Foundation
import UIKit

/**
 *  Verifies the contents of a UITextField contain a valid phone number.
 */
class PhoneNumberFieldValidator: NSObject {
    // MARK: Properties
    
    var fieldIsRequired: Bool
    
    var textField: UITextField
    
    // MARK: Init Methods
    
    required init(textField: UITextField, fieldIsRequired: Bool = false) {
        self.fieldIsRequired = fieldIsRequired
        self.textField = textField
        
        super.init()
        
        textField.delegate = self
    }
}

// MARK: FieldValidator Methods

extension PhoneNumberFieldValidator: FieldValidator {
    func isValid() -> Bool {
        if fieldIsRequired && isEmpty() {
            return false
        }
        
        return ContactInfoFormatter().validatePhoneString(textField.text)
    }
}

// MARK: UITextFieldDelegate Methods

extension PhoneNumberFieldValidator: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard string.rangeOfCharacterFromSet(NSCharacterSet.newlineCharacterSet()) == nil else {
            return true
        }
        
        let contactInfoFormatter = ContactInfoFormatter()
        
        let characterSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        
        if string.rangeOfCharacterFromSet(characterSet) == nil {
            // Strip the string back to numbers only
            var textFieldText = textField.text!
            textFieldText = contactInfoFormatter.stringFromPhoneString(textFieldText)
            
            if string.characters.count == 0 {
                // Handle deletions
                let textFieldConvertedText = textFieldText as NSString
                let range = NSMakeRange(textFieldConvertedText.length - 1, 1)
                textFieldText = textFieldConvertedText.stringByReplacingCharactersInRange(range, withString: "")
            }
            else if textFieldText.characters.count < contactInfoFormatter.maximumPhoneNumberLength {
                // Append the additional string if it is within the max text length limit
                textFieldText = textFieldText.stringByAppendingString(string)
            }
            
            // Set the text on the text field
            textField.text = contactInfoFormatter.phoneStringFromString(textFieldText)
        }
        
        return false
    }
}
