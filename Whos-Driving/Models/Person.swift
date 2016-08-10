import UIKit

/**
 Represents a user's relationship to the current user.
 */
enum Relationship: String {
    
    /// No relationship to the current user.
    case None = "untrusted"
    
    /// Current user.
    case CurrentUser = "current_user"
    
    /// This user is a trusted driver.
    case Trusted = "trusted"
    
    /// This user is a household driver.
    case Household = "household"
}

/// Represents a person in the app, either a driver or rider.
class Person: NSObject {
    
    // MARK: Properties
    
    /// The person's home address.
    var address: Address 
    
    /// The formatted version of the user's name to display in the app. e.g. "John D".
    var displayName: String {
        get {
            let firstLetter = (lastName as NSString).substringToIndex(1)
            return "\(firstName) \(firstLetter)"
        }
    }

    /// If this user is being displayed in a list of drivers related to an event, it will sometimes
    /// include the DriverResponse they've sent for that event.
    var driverResponseFrom: DriverResponse?

    /// If this user is being displayed in a list of drivers related to an event, it will sometimes
    /// include the DriverResponse they've sent for that event.
    var driverResponseTo: DriverResponse?

    /// The person's email adderss.
    var email: String?
    
    /// The person's first name.
    var firstName: String
    
    /// The persons first and last name.
    var fullName: String {
        get {
            return firstName + " " + lastName
        }
    }
    
    /// Array of the rider's household drivers.
    ///
    /// This property is ONLY valid for riders.
    var householdDrivers: [Person]

    /// The server id of this person's household.
    var householdId: String?
    
    /// Array of this driver's household riders.
    ///
    /// This property is ONLY valid for drivers.
    var householdRiders: [Person]
    
    /// The server id of this person.
    let id: String
    
    /// URL of the person's avatar.
    var imageURL: String?
    
    /// The person's last name.
    var lastName: String
    
    /// True is this person is a valid driver.
    var licensedDriver: Bool
    
    /// The person's partner.
    ///
    /// This property is ONLY valid for drivers.
    var partner: Person?
    
    /// The person's phone number.
    var phoneNumber: String? {
        didSet {
            if let number = phoneNumber {
                let contactFormatter = ContactInfoFormatter()
                phoneNumber = contactFormatter.stringFromPhoneString(number)
            }
        }
    }
    
    /// The person's relationship to the current user.
    var relationship: Relationship = Relationship.None
    
    // MARK: Init and deinit methods
    
    /**
    Returns a configured instance of this class using the JSON dictionary provided by the server.
    
    - parameter dictionary JSON dictionary from the server.
    
    - returns: Configured instance of this class.
    */
    required init(dictionary: NSDictionary) {
        email = dictionary[ServiceResponse.EmailKey] as? String
        firstName = dictionary[ServiceResponse.FirstNameKey] as! String
        householdId = dictionary[ServiceResponse.HouseHoldIdKey] as? String
        id = dictionary[ServiceResponse.IdKey] as! String

        imageURL = dictionary[ServiceResponse.ImageURLKey] as? String
        lastName = dictionary[ServiceResponse.LastNameKey] as! String
        phoneNumber = dictionary[ServiceResponse.MobileNumberKey] as? String
        
        let addressLine1 = dictionary[ServiceResponse.AddressLine1Key] as? String
        let addressLine2 = dictionary[ServiceResponse.AddressLine2Key] as? String
        let city = dictionary[ServiceResponse.CityKey] as? String
        let state = dictionary[ServiceResponse.StateKey] as? String
        let zip = dictionary[ServiceResponse.ZipKey] as? String
        address = Address(line1: addressLine1, line2: addressLine2, city: city, state: state, zip: zip)
        
        var householdRiders = [Person]()
        if let riders = dictionary[ServiceResponse.HouseHoldRidersKey] as? [NSDictionary] {
            for rider: NSDictionary in riders {
                let person = Person(dictionary: rider)
                householdRiders.append(person)
            }
        }
        self.householdRiders = householdRiders
        
        var householdDrivers = [Person]()
        if let drivers = dictionary[ServiceResponse.HouseHoldDriversKey] as? [NSDictionary] {
            for driver: NSDictionary in drivers {
                let person = Person(dictionary: driver)
                householdDrivers.append(person)
            }
        }
        self.householdDrivers = householdDrivers
        
        if let driver = dictionary[ServiceResponse.PartnerKey] as? NSDictionary {
            let person = Person(dictionary: driver)
            self.partner = person
        }
        
        if let relationshipString = dictionary[ServiceResponse.RelationshipType] as? String {
            relationship = Relationship(rawValue: relationshipString)!
        }
        
        licensedDriver = dictionary[ServiceResponse.LicensedDriverKey] as! Bool

        if let driverResponseStringFrom = dictionary[ServiceResponse.DriverStatusResponseFromKey] as? String {
            driverResponseFrom = DriverResponse(rawValue: driverResponseStringFrom)
        }
        
        if let driverResponseStringTo = dictionary[ServiceResponse.DriverStatusResponseToKey] as? String {
            driverResponseTo = DriverResponse(rawValue: driverResponseStringTo)
        }

        super.init()
    }
    
    // MARK: Instance Methods
    
    func dictionaryRepresentation() -> [String: AnyObject] {
        return [
            ServiceResponse.AddressLine1Key : objOrNull(address.line1),
            ServiceResponse.AddressLine2Key : objOrNull(address.line2),
            ServiceResponse.CityKey : objOrNull(address.city),
            ServiceResponse.EmailKey : objOrNull(email),
            ServiceResponse.MobileNumberKey : objOrNull(phoneNumber),
            ServiceResponse.StateKey : objOrNull(address.state),
            ServiceResponse.ZipKey : objOrNull(address.zip),
            ServiceResponse.FirstNameKey : firstName,
            ServiceResponse.LastNameKey : lastName,
            ServiceResponse.ImageURLKey : objOrNull(imageURL)
        ]
    }
    
    func riderDictionaryRepresentation() -> [String: AnyObject] {
        return [
            ServiceResponse.MobileNumberKey : objOrNull(phoneNumber),
            ServiceResponse.FirstNameKey : firstName,
            ServiceResponse.LastNameKey : lastName,
            ServiceResponse.ImageURLKey : objOrNull(imageURL)
        ]
    }
}

// MARK: NSObject overrides

extension Person {
    
    // MARK: Properties
    
    override var hash: Int {
        return id.hash
    }
    
    // MARK: Instance methods
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let person = object as? Person {
            return person.id == self.id
        } else {
            return super.isEqual(object)
        }
    }
}