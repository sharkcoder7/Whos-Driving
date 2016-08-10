import Foundation
import UIKit

// MARK: ResetPasswordViewControllerDelegate

protocol ResetPasswordViewControllerDelegate {
    func resetPasswordViewControllerDidComplete(resetPasswordViewController: ResetPasswordViewController)
}

// MARK: ResetPasswordViewController

/// A view controller to allow the user to reset their password. Create an instance of this view
/// controller using the
/// viewController(withPasswordResetToken token: String) -> ResetPasswordViewController method.
///
final class ResetPasswordViewController: UIViewController {
    // MARK: Properties
    
    var delegate: ResetPasswordViewControllerDelegate?
    
    // MARK: IBOutlets
    
    /// Displayed when network requests are being performed.
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    
    /// Allows the user to leave the password reset flow.
    @IBOutlet private var cancelButton: UIButton!
    
    /// When pressed, initiates a network request to change the users password.
    @IBOutlet private var changePasswordButton: UIButton!
    
    /// Text field that allows the user to confirm their new password.
    @IBOutlet private var confirmPasswordTextField: TextField!
    
    /// Text field that accepts the users email address.
    @IBOutlet private var emailLabel: UILabel!
    
    /// Brings the user back to the log-in screen.
    @IBOutlet private var logInButton: UIButton!
    
    /// An image view displaying the logo.
    @IBOutlet private var logoImageView: UIImageView!
    
    /// Text field that allows the user to enter their new password.
    @IBOutlet private var newPasswordTextField: TextField!
    
    /// Displays a message to the user.
    @IBOutlet private var promptLabel: UILabel!
    
    /// A view that contains the user input fields. Used to dodge the keyboard on smaller devices.
    @IBOutlet private var userInputView: UIView!
    
    // MARK: Private Properties
    
    /// The token required by the server to reset the users password. It is considered programmer
    /// error if this variable does not have a value.
    private var resetPasswordToken: String!
    
    private var viewModel = ResetPasswordViewModel() {
        didSet {
            emailLabel.text = viewModel.emailAddressText
            promptLabel.text = viewModel.promptLabelText
            
            UIView.animateWithDuration(0.3) { 
                self.activityIndicatorView.alpha = self.viewModel.activityIndicatorViewAlpha
                self.cancelButton.alpha = self.viewModel.cancelButtonAlpha
                self.emailLabel.alpha = self.viewModel.emailLabelAlpha
                self.logInButton.alpha = self.viewModel.loginButtonAlpha
                self.promptLabel.alpha = self.viewModel.promptLabelAlpha
                self.userInputView.alpha = self.viewModel.userInputViewAlpha
            }
        }
    }
    
    // MARK: Class Methods
    
    /**
     Creates and returns a new instance of the view controller.
     
     - parameter token: a token used to identify the user when resetting the password.
     
     - returns: a new instance of the view controller.
     */
    static func viewController(withPasswordResetToken token: String) -> ResetPasswordViewController {
        let viewController = ResetPasswordViewController(nibName: "ResetPasswordViewController", bundle: nil)
        viewController.resetPasswordToken = token
        return viewController
    }
    
    // MARK: IBActions
    
    /**
     Called when the user touches up inside the cancelButton.
     */
    @IBAction private func cancelButtonPressed() {
        delegate?.resetPasswordViewControllerDidComplete(self)
    }
    
    /**
     Called when the user touches up inside the changePasswordButton.
     */
    @IBAction private func changePasswordButtonPressed() {
        endEditing()
        
        guard let password = newPasswordTextField.text else {
            displayAlert(message: "Please enter your new password.")
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text else {
            displayAlert(message: "Please confirm your password.")
            return
        }
        
        viewModel.state = .PerformingNetworkRequest
        
        SessionCredentialsHandler.resetPassword(withToken: resetPasswordToken, password: password, confirmPassword: confirmPassword) {
            errorMessage in
            guard let errorMessage = errorMessage else {
                self.viewModel.state = .ResetComplete
                return
            }
            
            self.viewModel.state = .AcceptingUserInput
            self.displayAlert(message: errorMessage)
        }
    }
    
    /**
     Called when the user presses the 'return' key while editing the confirmPasswordTextField.
     */
    @IBAction private func confirmPasswordTextFieldDidEndOnExit() {
        endEditing()
        changePasswordButtonPressed()
    }
    
    /**
     Called when the user touches up inside of the logInButton.
     */
    @IBAction private func logInButtonPressed() {
        delegate?.resetPasswordViewControllerDidComplete(self)
    }
    
    /**
     Called when the user presses the 'return' key while editing the newPasswordTextField.
     */
    @IBAction private func newPasswordTextFieldDidEndOnExit() {
        confirmPasswordTextField.becomeFirstResponder()
    }
    
    // MARK: Private Methods
    
    /**
     Displays an alert to the user. The alert has the title "Error". The message is the text passed
     in to this method. The alert will have a single cancel button with the title "OK".
     
     - parameter message:    the message to be displayed to the user.
     - parameter completion: the closure to be executed when the user presses the cancel button.
     This closure takes no parameters and returns nothing.
     */
    private func displayAlert(message message: String?, completion: (() -> ())? = nil) {
        guard let message = message else {
            return
        }
        
        let handler: (UIAlertAction) -> () = {
            alertAction in
            completion?()
        }
        
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: handler)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     Dismisses the keyboard.
     */
    dynamic private func endEditing() {
        view.endEditing(true)
    }
    
    /**
     Triggered by the UIKeyboardWillChangeFrameNotification.
     
     - parameter notification The notification that was triggered.
     */
    dynamic private func keyboardWillChangeFrame(notification: NSNotification) {
        let duration: NSTimeInterval = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue ?? 0.3
        
        guard let keyboardRect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue else {
            return
        }
        
        let overlap = keyboardRect.intersect(self.userInputView.frame)
        
        guard overlap.height.isFinite else {
            return
        }
        
        guard overlap.height > 0.0 else {
            return
        }
        
        let padding: CGFloat = 20.0
        let translate = -(overlap.height + padding)
        
        var userInputViewEndFrame = self.userInputView.frame
        userInputViewEndFrame.origin.y += translate
        
        let userInputViewWillOverlapFrame: (CGRect) -> (Bool) = {
            rect -> Bool in
            let intersectionRect = userInputViewEndFrame.intersect(rect)
            let intersects = intersectionRect.size != CGSizeZero
            return intersects
        }
        
        UIView.animateWithDuration(duration) {
            self.userInputView.transform = CGAffineTransformMakeTranslation(0.0, translate)
            self.cancelButton.alpha = userInputViewWillOverlapFrame(self.cancelButton.frame) ? 0.0 : 1.0
            self.emailLabel.alpha = userInputViewWillOverlapFrame(self.emailLabel.frame) ? 0.0 : 1.0
            self.logoImageView.alpha = userInputViewWillOverlapFrame(self.logoImageView.frame) ? 0.0 : 1.0
            self.promptLabel.alpha = userInputViewWillOverlapFrame(self.promptLabel.frame) ? 0.0 : 1.0
        }
    }
    
    /**
     Triggered by the UIKeyboardWillHideNotification.
     
     - parameter notification The notification that was triggered.
     */
    dynamic private func keyboardWillHide(notification: NSNotification) {
        let duration: NSTimeInterval = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue ?? 0.3
        
        UIView.animateWithDuration(duration) {
            self.userInputView.transform = CGAffineTransformIdentity
            self.cancelButton.alpha = 1.0
            self.logoImageView.alpha = 1.0
            self.emailLabel.alpha = 1.0
            self.promptLabel.alpha = 1.0
        }
    }
}

// MARK: UIViewController Methods

extension ResetPasswordViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cornerRadius: CGFloat = 2.0
        let masksToBounds = true
        
        changePasswordButton.layer.cornerRadius = cornerRadius
        changePasswordButton.layer.masksToBounds = masksToBounds
        
        logInButton.layer.cornerRadius = cornerRadius
        logInButton.layer.masksToBounds = masksToBounds
        
        newPasswordTextField.topLeftCorner = true
        newPasswordTextField.topRightCorner = true
        
        confirmPasswordTextField.bottomLeftCorner = true
        confirmPasswordTextField.bottomRightCorner = true
        
        viewModel.state = .PerformingNetworkRequest
        
        SessionCredentialsHandler.verify(resetPasswordToken: resetPasswordToken) {
            isValid, email, message in
            
            guard isValid else {
                self.displayAlert(message: message) {
                    self.navigationController?.popViewControllerAnimated(true)
                }
                
                return
            }
            
            self.viewModel.emailAddressText = email
            self.viewModel.state = .AcceptingUserInput
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        view.backgroundColor = AppConfiguration.blue()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
