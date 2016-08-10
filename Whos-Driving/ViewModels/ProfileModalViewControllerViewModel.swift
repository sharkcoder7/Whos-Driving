import UIKit

/**
 *  View model for the ProfileModalViewController
 */
struct ProfileModalViewControllerViewModel {
    
    // MARK: Properties
    
    /*
    The Person this view model is representing.
    */
    var person: Person
    
    // MARK: Init and deinit methods
    
    /**
    Initializes a new instance of this class with the provided Person object.
    
    - parameter aPerson The Person this view model is representing.
    
    - returns: A new instance of this class.
    */
    init(aPerson: Person) {
        person = aPerson
    }
   
    // MARK: Instance methods
    
    /**
    Returns the background color for the action button based on the Relationship of self.person.
    
    - returns: The background color for the action button.
    */
    func backgroundColorForActionButton() -> UIColor {
        switch person.relationship {
        case .None:
            return AppConfiguration.blue()
        default:
            return AppConfiguration.red()
        }
    }
    
    /**
    Returns the text for the action button based on the Relationship of self.person.
    
    - returns: The text for the action button.
    */
    func textForActionButton() -> String {
        switch person.relationship {
        case .None:
            return "Invite as trusted driver"
        case .CurrentUser:
            return ""
        case .Household:
            return "Remove spouse/partner"
        case .Trusted:
            return "Remove from my trusted driver list"
        }
    }
    
    /**
    Returns the text to display in the address label.
    
    - returns: The text for the address label.
    */
    func textForAddressLabel() -> String {
        return person.address.addressString()
    }
    
    /**
    Returns the text to display in the associated label based on the Relationship of self.person.
    
    - returns: The text for the associated label.
    */
    func textForAssociatedLabel() -> String {
        if person.licensedDriver {
            switch person.relationship {
            case .CurrentUser:
                return "You are associated with these kids:"
            default:
                return person.firstName + " is associated with these kids:"
            }
        } else {
            return person.firstName + " is associated with these trusted drivers:"
        }

    }
    
    /**
    Returns the text to display in the bottom detail label based on the Relationship of self.person.
    
    - returns: The text to display in the bottom detail label.
    */
    func textForBottomDetailLabel() -> String {
        if person.licensedDriver {
            switch person.relationship {
            case .None:
                return "Trusted Drivers are able to add your kids to a carpool."
            default:
                return ""
            }
        } else {
            return ""
        }

    }
    
    /**
    Returns the text to display in the first letter label.
    
    - returns: The text for the first letter label.
    */
    func textForFirstLetterLabel() -> String {
        return (person.firstName as NSString).substringToIndex(1).uppercaseString
    }
    
    /**
    Returns the text to display in the name label based on the Relationship of self.person.
    
    - returns: The text to display in the name label.
    */
    func textForNameLabel() -> NSAttributedString {
        var nameString = person.fullName
        let relationshipString: String
        
        if person.licensedDriver {
            switch person.relationship {
            case .None:
                relationshipString = ""
            case .CurrentUser:
                nameString = "Me"
                relationshipString = ""
            case .Household:
                relationshipString = "  –  SPOUSE/PARTNER"
            case .Trusted:
                relationshipString = "  –  TRUSTED DRIVER"
            }
        } else {
            relationshipString = ""
        }

        
        let nameAttributes = [NSForegroundColorAttributeName : AppConfiguration.black(), NSFontAttributeName : UIFont(name: Font.HelveticaNeueMedium, size: 12)!]
        let attributedNameString = NSMutableAttributedString(string: nameString, attributes: nameAttributes)
        
        let relationshipAttributes = [NSForegroundColorAttributeName : AppConfiguration.blue(), NSFontAttributeName : UIFont(name: Font.HelveticaNeueRegular, size: 10)!]
        let attributedRelationshipString = NSAttributedString(string: relationshipString, attributes: relationshipAttributes)
        attributedNameString.appendAttributedString(attributedRelationshipString)
        
        return attributedNameString
    }
    
    /**
    Returns the text to display in the relationship label.
    
    - returns: The text for the relationship label.
    */
    func textForRelationshipLabel() -> String {
        if person.licensedDriver {
            switch person.relationship {
            case .Household:
                return person.firstName + " is listed as your spouse/partner"
            case .Trusted:
                return person.firstName + " is one of your trusted drivers"
            default:
                return ""
            }
        } else {
            return ""
        }
    }
    
    /**
    Returns the text to display in the top detail label.
    
    - returns: The text for the top detail label.
    */
    func textForTopDetailLabel() -> String {
        if person.licensedDriver {
            switch person.relationship {
            case .Household:
                return "Spouses/partners are able to view and manage your kids."
            case .Trusted:
                return "Trusted Drivers are able to add your kids to a carpool."
            default:
                return ""
            }
        } else {
            return ""
        }
    }
}