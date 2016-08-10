import Foundation
import UIKit

/**
 *  Types that conform to this protocol validate the contents of a UITextField.
 */
protocol FieldValidator {
    // MARK: Properties
    
    /// Indicates if the text field is required to contain text in order to be considered valid.
    var fieldIsRequired: Bool { get set }
    
    /// The UITextField to be validated.
    var textField: UITextField { get set }
    
    // MARK: Init Methods
    
    init(textField: UITextField, fieldIsRequired: Bool)
    
    // MARK: Instance Methods
    
    /**
     Returns a boolean indicating if the field contains text.
     */
    func isEmpty() -> Bool
    
    /**
     Returns a boolean indicating if the field contains text.
     */
    func isNotEmpty() -> Bool
    
    /**
     Returns a boolean indicating if the field contains valid text.
     */
    func isValid() -> Bool
}

extension FieldValidator {
    func isEmpty() -> Bool {
        guard var text = textField.text else {
            return true
        }
        
        text = text.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch)
        
        return text.isEmpty
    }
    
    func isNotEmpty() -> Bool {
        return !isEmpty()
    }
    
    func isValid() -> Bool {
        if fieldIsRequired && isEmpty() {
            return false
        }
        
        return isNotEmpty()
    }
}
