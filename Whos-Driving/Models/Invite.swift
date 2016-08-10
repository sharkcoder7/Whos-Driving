import UIKit

/**
 Represents the status of an invite.
 */
enum InviteStatus: String {
    /// Valid invite.
    case OK = "ok"
    /// There's a conflict in the invite, such as the two users already being trusted drivers.
    case Conflict = "conflict"
}

/**
 *  Represents an Invite object returned from the server. This object contains details on the invite
 *  including a status message to show to the user, and the status of the invite.
 */
struct Invite {
    
    // MARK: Public properties
    
    /// The driver being invited to connect.
    var invitedDriver: Person

    /// The token to retrieve the invite details, or accept the invite on the server.
    var inviteToken: String
    
    /// The driver sending the invite to connect.
    var invitingDriver: Person

    /// The status of the invite. See InviteStatus.
    var status: InviteStatus
    
    /// Further details related to the statusMessage. This is sometimes an empty string if there
    /// are no additional details.
    var statusDetail: String
    
    /// A message to display to the user describing the status of the invite.
    var statusMessage: String
    
    /// The type of invite (household or trusted).
    var type: InviteType
    
    // MARK: Init and deinit methods
    
    /**
    Creates a configured instance of the class using a JSON dictionary from the server. This method
    will return nil if the required parameters are not included.
    
    - parameter dictionary JSON dictionary used to configure this object.
    
    - returns: Configured instance of this class, or nil if the dictionary is invalid.
    */
    init?(dictionary: NSDictionary) {
        if let data = dictionary[ServiceResponse.DataKey] as? NSDictionary {
            guard let inviteToken = data[ServiceResponse.InviteTokenKey] as? String else {
                dLog("No invite token. Returning nil.")
                return nil
            }
            
            guard let typeString = data[ServiceResponse.InviteTypeKey] as? String else {
                dLog("No invite type. Returning nil.")
                return nil
            }
            
            guard let type = InviteType(rawValue: typeString) else {
                dLog("Invalid invite type. Returning nil.")
                return nil
            }
            
            
            guard let statusString = data[ServiceResponse.StatusKey] as? String else {
                dLog("No valid status. Returning nil.")
                return nil
            }
            
            guard let status = InviteStatus(rawValue: statusString) else {
                dLog("Invalid status. Returning nil.")
                return nil
            }
            
            guard let statusMessage = data[ServiceResponse.StatusMessageKey] as? String else {
                dLog("No valid status message. Returning nil.")
                return nil
            }
            
            guard let statusDetail = data[ServiceResponse.StatusDetailKey] as? String else {
                dLog("No valid status detail. Returning nil.")
                return nil
            }
            
            guard let invitingDriverDict = data[ServiceResponse.InvitingDriverKey] as? NSDictionary else {
                dLog("No valid inviting driver dictionary. Returning nil.")
                return nil
            }
            
            guard let invitedDriverDict = data[ServiceResponse.InvitedDriverKey] as? NSDictionary else {
                dLog("No valid invited driver dictionary. Returning nil.")
                return nil
            }
            
            self.inviteToken = inviteToken
            self.type = type
            self.status = status
            self.statusMessage = statusMessage
            self.statusDetail = statusDetail
            self.invitingDriver = Person(dictionary: invitingDriverDict)
            self.invitedDriver = Person(dictionary: invitedDriverDict)
        } else {
            dLog("No valid data dictionary. Returning nil.")
            return nil
        }
    }
}