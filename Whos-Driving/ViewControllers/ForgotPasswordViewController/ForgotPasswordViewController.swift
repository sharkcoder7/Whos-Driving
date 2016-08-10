import Foundation
import UIKit

protocol ForgotPasswordViewControllerDelegate {
    /**
     This method is called on the delegate when the user cancels the operation of submitting a
     "Forgot Password" request to the server.
     
     - parameter forgotPasswordViewController: the view controller.
     */
    func forgotPasswordViewControllerDidCancel(forgotPasswordViewController: ForgotPasswordViewController)
    
    /**
     This method is called on the delegate when the user has successfully completed a "Forgot
     Password" request to the server.
     
     - parameter forgotPasswordViewController: the view controller.
     */
    func forgotPasswordViewControllerDidComplete(forgotPasswordViewController: ForgotPasswordViewController)
}

/// Provides an interface to allow the user to reset their password.
///
final class ForgotPasswordViewController: UIViewController {
    // MARK: Properties
    
    var delegate: ForgotPasswordViewControllerDelegate?
    
    // MARK: IBOutlets
    
    /// The user presses this button once the network request to reset their password completes
    /// successfully.
    @IBOutlet private var backToLogInButton: UIButton!
    
    /// Cancels the "reset password" flow.
    @IBOutlet private var cancelButton: UIButton!
    
    /// Text field for the users email address.
    @IBOutlet private var emailTextField: TextField!
    
    /// A container view for prompting the user to enter their email address in order to reset thier
    /// password.
    @IBOutlet private var enterEmailContainerView: UIView!
    
    /// A container view for indicating to the user that instructions to reset their password have
    /// been sent to their email.
    @IBOutlet private var resetSuccessfulContainerView: UIView!
    
    /// Contains the contents of the view controller to allow scrolling on smaller screens.
    @IBOutlet private var scrollView: UIScrollView!
    
    /// Initiates a request to have instructions sent to the users email for how to reset their
    /// password.
    @IBOutlet private var sendButton: UIButton!
    
    // MARK: Class Methods
    
    /**
     Creates a new instance of the view controller from its' nib. This is the preferred method of
     creating an instance of this class.
     
     - returns: a new view controller.
     */
    static func viewController() -> ForgotPasswordViewController {
        let viewController = ForgotPasswordViewController(nibName: "ForgotPasswordViewController", bundle: nil)
        return viewController
    }
    
    // MARK: IBActions
    
    /**
     Called once the user has completed the password reset flow.
     */
    @IBAction private func backToLogInButtonPressed(sender: AnyObject) {
        delegate?.forgotPasswordViewControllerDidComplete(self)
    }
    
    /**
     Called if the user cancels out of the password reset flow.
     */
    @IBAction private func cancelButtonPressed(sender: AnyObject) {
        delegate?.forgotPasswordViewControllerDidCancel(self)
    }
    
    /**
     Called when the user has entered their email to receive instructions for resetting their
     password.
     */
    @IBAction private func sendButtonPressed(sender: AnyObject) {
        endEditing()
        submitPasswordResetRequest()
    }
    
    // MARK: Private Methods
    
    /**
     Displays an alert to the user in the case of an error. The displayed alert has the title 
     "Error", the message that is specified, and a single 'cancel' button with the title "OK".
     
     - parameter message: the error message that should be displayed.
     */
    private func displayAlert(message message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     Called when the emailTextField control sends a .DidEndOnExit event.
     */
    dynamic private func emailTextFieldDidEndOnExit() {
        sendButtonPressed(sendButton)
    }
    
    /**
     Triggered by the UIKeyboardWillHideNotification.
     
     - parameter notification The notification that was triggered.
     */
    func keyboardWillHide(notification: NSNotification) {
        guard let keyboardRect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue else {
            return
        }
        
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue ?? 0.3
        
        // Calculate how much to adjust the content inset
        let bottomContentInset = keyboardRect.height
        let contentInset = UIEdgeInsetsMake(scrollView.contentInset.top,
                                            scrollView.contentInset.left,
                                            scrollView.contentInset.bottom - bottomContentInset,
                                            scrollView.contentInset.right)
        
        UIView.animateWithDuration(duration) {
            self.scrollView.contentInset = contentInset
        }
    }
    
    /**
     Triggered by the UIKeyboardWillShowNotification.
     
     - parameter notification The notification that was triggered.
     */
    func keyboardWillShow(notification: NSNotification) {
        guard let keyboardRect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue else {
            return
        }
        
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue ?? 0.3
        
        // Calculate how much to adjust the content inset
        let bottomContentInset = keyboardRect.height
        let contentInset = UIEdgeInsetsMake(scrollView.contentInset.top,
                                            scrollView.contentInset.left,
                                            bottomContentInset,
                                            scrollView.contentInset.right)
        
        UIView.animateWithDuration(duration) {
            self.scrollView.contentInset = contentInset
        }
    }
    
    /**
     Submits a network request an email with password reset instructions.
     */
    private func submitPasswordResetRequest() {
        let endpoint = ServiceEndpoint.Sessions + ServiceEndpoint.SendResetPasswordInstructions
        let parameters = [ServiceResponse.EmailKey: emailTextField.text!]
        
        WebServiceController.sharedInstance.post(endpoint, parameters: parameters) {
            responseObject, error in
            guard let error = error else {
                self.show(self.enterEmailContainerView, show: false, animated: true)
                return
            }
            
            let message = error.userInfo[NSLocalizedDescriptionKey] as! String
            self.displayAlert(message: message)
        }
    }
    
    /**
     Dismisses the keyboard.
     */
    dynamic private func endEditing() {
        view.endEditing(true)
    }
}

// MARK: UIViewController Methods

extension ForgotPasswordViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidEndOnExit), forControlEvents: .EditingDidEndOnExit)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        view.backgroundColor = AppConfiguration.blue()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
