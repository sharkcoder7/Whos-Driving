import MessageUI
import UIKit

/**
 A type of invite that can be sent from one user to another.
 */
enum InviteType: String {
    /// The normal invite to another user.
    case Trusted = "trusted"
    
    /// Household/partner invite is usually sent to wives/husbands and links the two users kids
    /// togethers and gives additional privilages, such as being able to volunteer each other
    /// as event drivers.
    case Household = "household"
}

/// The InviteSender's delegate.
protocol InviteSenderDelegate: class {
    
    /**
     Called when the InviteSender finishes sending an invite.
     
     - parameter success True if the invite was successfully sent.
     */
    func invitesFinished(success: Bool)
}

/**
Controller for sending invites to new users via text message or email. 

NOTE: When using an instance of this class, retain a strong reference until the invite process is
finished. Otherwise the delegate callbacks will be called on a nil object and the app will crash.
*/
class InviteSender: NSObject {
    
    // MARK: Properties
    
    /// The delegate of this class.
    weak var delegate: InviteSenderDelegate?
    
    // MARK: Private properties
    
    /// The view controller presenting the invite UI. This UIViewController will have other 
    /// UIViewControllers such as MFMessageComposeViewControllers and UIAlertControllers presented
    /// from it.
    private var presentingViewController: UIViewController
    
    // MARK: Init and deinit methods
    
    /**
    Initializes a configured instance of this class.
    
    - parameter presentingViewController The UIViewController that will be presenting the invite UI.
    - parameter delegate The delegate of this class.
    
    - returns: Configured instance of this class.
    */
    required init(presentingViewController: UIViewController, delegate: InviteSenderDelegate) {
        self.presentingViewController = presentingViewController
        self.delegate = delegate
    }
    
    // MARK: Instance methods
   
    /**
    Present an action sheet to the user to select how to send the invite. Then presents the appropriate
    MFMessageComposeViewController or MFMailComposeViewController.
    
    - parameter inviteType The type of invite being sent.
    */
    func presentInvite(inviteType: InviteType) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        if MFMessageComposeViewController.canSendText() == true {
            let viaTextAction = UIAlertAction(title: "Invite via txt message", style: UIAlertActionStyle.Default) { [weak self] (action) -> Void in
                self?.getInviteMessage(inviteType.rawValue, completion: { (message, error) -> Void in
                    if let inviteMessage = message {
                        let textComposeViewController = MFMessageComposeViewController()
                        textComposeViewController.messageComposeDelegate = self
                        textComposeViewController.body = inviteMessage
                        
                        self?.presentingViewController.presentViewController(textComposeViewController, animated: true, completion: nil)
                    } else {
                        let alertController = defaultAlertController("Error loading invite message. Please try again.")
                        self?.presentingViewController.presentViewController(alertController, animated: true, completion: nil)
                    }
                })
            }
            
            actionSheetController.addAction(viaTextAction)
        }
        
        if MFMailComposeViewController.canSendMail() == true {
            let viaEmailAction = UIAlertAction(title: "Invite via email", style: UIAlertActionStyle.Default) { [weak self] (action) -> Void in
                self?.getInviteMessage(inviteType.rawValue, completion: { (message, error) -> Void in
                    if let inviteMessage = message {
                        let mailComposeViewController = MFMailComposeViewController()
                        mailComposeViewController.setSubject("Join me on the Who's Driving app!")
                        mailComposeViewController.mailComposeDelegate = self
                        mailComposeViewController.setMessageBody(inviteMessage, isHTML: false)
                        
                        self?.presentingViewController.presentViewController(mailComposeViewController, animated: true, completion: nil)
                    } else {
                        let alertController = defaultAlertController("Error loading invite message. Please try again.")
                        self?.presentingViewController.presentViewController(alertController, animated: true, completion: nil)
                    }
                })
            }
            
            actionSheetController.addAction(viaEmailAction)
        }
        
        if actionSheetController.actions.count == 0 {
            // Show an alert if the device cannot send email or text messages.
            let alertController = defaultAlertController("Your device is not configured to send email or SMS messages. Please configure an email or SMS account in the settings app to continue.")
            
            presentingViewController.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            actionSheetController.addAction(cancelAction)
            
            presentingViewController.presentViewController(actionSheetController, animated: true, completion: nil)
        }
    }
    
    // MARK: Private methods
    
    /**
    Gets the formatted invite message from the server.
    
    - parameter inviteType The type of invite being sent.
    - parameter completion Completion blocked called when the call to the server completes.
    */
    private func getInviteMessage(inviteType: String, completion:(message: String?, error: NSError?) -> Void) {
        let webServiceController = WebServiceController.sharedInstance
        let parameters = [ServiceResponse.InviteTypeKey : inviteType]
        
        webServiceController.post(ServiceEndpoint.CurrentUserInvites, parameters: parameters) { (responseObject, error) -> Void in
            var message: String?
            
            if let dataDictionary = responseObject?.objectForKey(ServiceResponse.DataKey) as? NSDictionary {
                message = dataDictionary[ServiceResponse.MessageKey] as? String
            }
            completion(message: message, error: error)
        }
    }
}

// MARK: MFMailComposeViewController Methods

extension InviteSender: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        if result == MFMailComposeResultFailed {
            let alertController = UIAlertController(title: "Error", message: "Something went wrong. Please try sending your email again.", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            presentingViewController.presentViewController(alertController, animated: true, completion: nil)
            
        } else if result == MFMailComposeResultSent {
            AnalyticsController().track("Invite sent via email")

            delegate?.invitesFinished(true)
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: MFMessageComposeViewController Methods

extension InviteSender: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        if result == MessageComposeResultFailed {
            let alertController = UIAlertController(title: "Error", message: "Something went wrong. Please try sending your message again.", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(cancelAction)

            presentingViewController.presentViewController(alertController, animated: true, completion: nil)
            
        } else if result == MessageComposeResultSent {
            AnalyticsController().track("Invite sent via text message")

            delegate?.invitesFinished(true)
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
