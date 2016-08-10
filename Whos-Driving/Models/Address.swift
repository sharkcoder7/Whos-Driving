import UIKit

/**
 *  Represents a real world address.
 */
struct Address {
   
    // MARK: Properties
    
    /// The city of the address.
    var city: String?
    
    /// The first line of the address.
    var line1: String?
    
    /// The second line of the address.
    var line2: String?
    
    /// The state of the address.
    var state: String?
    
    /// The zip code of the address.
    var zip: String?

    // MARK: Init and deinit methods
    
    /**
    Returns a configured instance of this class.
    
    - parameter line1 The first line of the address.
    - parameter line2 The second line of the address.
    - parameter city The city of the address.
    - parameter state The state of the address.
    - parameter zip The zip code of the address.
    
    - returns: Configured instance of this class.
    */
    init(line1: String?, line2: String?, city: String?, state: String?, zip: String?) {
        self.line1 = line1
        self.line2 = line2
        self.city = city
        self.state = state
        self.zip = zip        
    }
    
    // MARK: Instance methods
    
    /*
    Returns a formatted address string. First line is line1, second line is line2, and third line is
    city, state zip. This method also trims whitespace and new line characters from all the address 
    strings.
    
    @return Address string formatted for display.
    */
    func addressString() -> String {
        let characterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        var addressString = ""
        
        if let unwrappedLine1 = line1?.stringByTrimmingCharactersInSet(characterSet) {
            if unwrappedLine1.characters.count > 0 {
                addressString = unwrappedLine1
            }
        }
        
        if let unwrappedLine2 = line2?.stringByTrimmingCharactersInSet(characterSet) {
            if unwrappedLine2.characters.count > 0 {
                if addressString.characters.count > 0 {
                    addressString += "\n"
                }
                addressString += unwrappedLine2
            }
        }
        
        var line3String = ""
        if let unwrappedCity = city?.stringByTrimmingCharactersInSet(characterSet) {
            if unwrappedCity.characters.count > 0 {
                line3String += unwrappedCity
            }
        }
        if let unwrappedState = state?.stringByTrimmingCharactersInSet(characterSet) {
            if unwrappedState.characters.count > 0 {
                if line3String.characters.count > 0 {
                    // If the city was added, put a comma and a space between city and state
                    line3String += ", "
                }
                line3String += unwrappedState
            }
        }
        if let unwrappedZip = zip?.stringByTrimmingCharactersInSet(characterSet) {
            if unwrappedZip.characters.count > 0 {
                if line3String.characters.count > 0 {
                    // If there's any text in line2String, add a space before the zip
                    line3String += " "
                }
                line3String += unwrappedZip
            }
        }
        
        if line3String.characters.count > 0 {
            if addressString.characters.count > 0 {
                addressString += "\n"
            }
            addressString += line3String
        }
        
        return addressString
    }
}
