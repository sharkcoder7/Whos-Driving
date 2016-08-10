import Foundation

/**
 *  Types that adopt this protocol provide the user a way of obtaining contact information for the
 *  user.
 */
protocol ContactInfoStrategy {
    /**
     Gets contact information for the current user.
     
     - parameter completion: a closure that is called when the request completes. This closure takes
     four parameters: a string representing the URL of the users avatar image; the users email
     address; the users name; and the users phone number.
     */
    func getContactInfo(completion: (avatarURLString: String?, email: String?, name: String?, phoneNumber: String?) -> ())
}
