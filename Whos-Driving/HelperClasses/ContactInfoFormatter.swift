import UIKit

/// This class has convenience methods for formatting and validing contact info such as phone numbers,
/// email addresses and zip codes.
class ContactInfoFormatter: NSObject {
    
    // MARK: Properties
    
    let maximumPhoneNumberLength = 10
    let maximumZipCharacters = 5

    // MARK: Private Properties
    
    private let areaCodeLength = 3
    private let centralOfficeCodeLength = 3
    private let customerCodeLength = 4
    
    // MARK: Instance Methods
    
    /**
    Validates the email address against a regular expression. Is not fool proof but will cover most
    cases. Returns true if the email string is valid.
    
    - parameter string The email address to validate.
    
    - returns: True if the email address is valid, other false.
    */
    func validateEmail(string: String?) -> Bool {
        guard let string = string else {
            return false
        }
        
        let regexString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let regexTest = NSPredicate(format: "SELF MATCHES %@", regexString)
        
        return regexTest.evaluateWithObject(string)
    }
    
    /**
     Converts a string of numbers to a string formatted as a phone number. For example 1234567890
     is converted to 123-456-7890.
     
     - parameter string The raw phone number string without formatting.
     
     - returns: A formatted representation of the phone number string.
     */
    func phoneStringFromString(string: String?) -> String {
        guard let string = string else {
            return ""
        }
        
        let characterSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        let trimmedString = string.stringByTrimmingCharactersInSet(characterSet) as NSString
        
        if trimmedString.length == 0 {
            return ""
        }
        else if trimmedString.length <= areaCodeLength {
            return trimmedString as String
        }
        else if trimmedString.length <= areaCodeLength + centralOfficeCodeLength {
            let areaCode = trimmedString.substringToIndex(areaCodeLength)
            let centralOfficeCode = trimmedString.substringFromIndex(areaCodeLength)
            
            return "\(areaCode)-\(centralOfficeCode)"
        }
        else {
            let areaCode = trimmedString.substringToIndex(areaCodeLength)
            let centralOfficeRange = NSMakeRange(areaCodeLength, centralOfficeCodeLength)
            let centralOfficeCode = trimmedString.substringWithRange(centralOfficeRange)
            let customerCode = trimmedString.substringFromIndex(areaCodeLength + centralOfficeCodeLength)
            
            return "\(areaCode)-\(centralOfficeCode)-\(customerCode)"
        }
    }
    
    /**
     Converts a formatted phone string back to a raw phone number. For example, 123-456-7890 is
     converted to 1234567890.
     
     - parameter string The formatted phone number string.
     
     - returns: A raw phone number string without dashes or other phone number formatting.
     */
    func stringFromPhoneString(string: String) -> String {
        let characterSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        let stringComponents = string.componentsSeparatedByCharactersInSet(characterSet) as NSArray
        
        return stringComponents.componentsJoinedByString("")
    }
   
    /**
     Checks if the phone number is the proper length. You can pass in a formatted or unformatted
     phone number string to this method.
     
     - parameter string The phone number string.
     
     - returns: True if the phone number is the proper length.
     */
    func validatePhoneString(string: String?) -> Bool {
        guard let string = string else {
            return true
        }
        
        let unformattedString = stringFromPhoneString(string)
        
        let phoneNumberLength = unformattedString.characters.count
        return phoneNumberLength == maximumPhoneNumberLength || phoneNumberLength == 0
    }
    
    /**
     Checks if the zip code is the proper length.
     
     - parameter zip The zip code.
     
     - returns: Yes if the zip code is the proper length.
     */
    func validateZip(zip: String?) -> Bool {
        guard let zip = zip else {
            return false
        }
        
        if zip.characters.count == 0 ||
            zip.characters.count == maximumZipCharacters {
                return true
        }
        
        return false
    }
}
