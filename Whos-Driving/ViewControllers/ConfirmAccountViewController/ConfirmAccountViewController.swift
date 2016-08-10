import Foundation
import UIKit

/// Performs a network request to confirm the users account and displays a message indicating the
/// result of the network request.
final class ConfirmAccountViewController: UIViewController {
    // MARK: IBOutlets
    
    /// The activity indicator.
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    /// Displays the confirmation text.
    @IBOutlet private var emailConfirmedLabel: UILabel!
    
    /// Displays the users email address.
    @IBOutlet private var emailLabel: UILabel!
    
    /// Displays a message to the user.
    @IBOutlet private var thanksLabel: UILabel!
    
    // MARK: Private Properties
    
    /// The token required by the server to reset the users password. It is considered programmer
    /// error if this variable does not have a value.
    private var confirmAccountToken: String!
    
    // MARK: Class Methods
    
    /**
     Creates and returns a new instance of the view controller.
     
     - parameter token: a token used to identify the user when confirming a new account.
     
     - returns: a new instance of the view controller.
     */
    static func viewController(withConfirmationToken token: String) -> ConfirmAccountViewController {
        let viewController = ConfirmAccountViewController(nibName: "ConfirmAccountViewController", bundle: nil)
        viewController.confirmAccountToken = token
        return viewController
    }
    
    // MARK: IBActions
    
    @IBAction private func continueToAppButtonPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: UIViewController Methods

extension ConfirmAccountViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppConfiguration.blue()
        
        SessionCredentialsHandler.confirmUser(withToken: confirmAccountToken) {
            email, message in
            self.emailLabel.text = email
            self.emailConfirmedLabel.text = message
            
            self.activityIndicator.alpha = 0.0
            self.emailConfirmedLabel.alpha = 1.0
            self.emailLabel.alpha = 1.0
            self.thanksLabel.alpha = 1.0
        }
    }
}
