import Foundation
import UIKit

/**
 *  Contains methods that alert the delegate once the SignUpViewController has completed.
 */
protocol SignUpViewControllerDelegate {
    /**
     Called on the delegate when the user completes the sign up process.
     
     - parameter signUpViewController: the view controller.
     - parameter signInStrategy:       the strategy used to sign up.
     */
    func signUpViewController(signUpViewController: SignUpViewController, didSignInWithStrategy signInStrategy: SignInStrategy, accountSetupComplete: Bool)
    
    /**
     Called on the delegate when the user cancels the action of signing up.
     
     - parameter signUpViewController: the view controller.
     */
    func signUpViewControllerDidCancel(signUpViewController: SignUpViewController)
}

/// Displays a UI that allows the user to sign up. Create an instance of this view controller using
/// the `viewController()` class method.
final class SignUpViewController: UIViewController {
    // MARK: Properties
    
    var delegate: SignUpViewControllerDelegate?
    
    // MARK: IBOutlets
    
    /// The loading spinner.
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    /// Text field that allows the user to confirm their password.
    @IBOutlet private var confirmPasswordTextField: RequiredTextField!
    
    /// Button that allows the user to create an account with the information in the form.
    @IBOutlet private var createAccountButton: UIButton!
    
    /// Text field that accepts the users email address.
    @IBOutlet private var emailTextField: RequiredTextField!
    
    /// Text field that accepts the users first name.
    @IBOutlet private var firstNameTextField: RequiredTextField!
    
    /// A container view that contains the first name, last name, and phone number text fields.
    @IBOutlet private var formOneContainerView: UIView!
    
    /// A container view that contains the email, password, and confirm password text fields.
    @IBOutlet private var formTwoContainerView: UIView!
    
    /// Text field that accepts the users last name.
    @IBOutlet private var lastNameTextField: RequiredTextField!
    
    /// Used to make the left separator view a height of 1 pixel.
    @IBOutlet private var leftSeparatorViewHeightConstraint: NSLayoutConstraint!
    
    /// Displays a loading spinner to the user when network activity is taking place.
    @IBOutlet private var loadingView: UIView!
    
    /// Allows the user to log in via Facebook.
    @IBOutlet private var loginWithFacebookButton: UIButton!
    
    /// Text field that allows the user to enter a desired password.
    @IBOutlet private var passwordTextField: RequiredTextField!
    
    /// Text field that accepts the users phone number.
    @IBOutlet private var phoneNumberTextField: TextField!
    
    /// Used to make the right separator view a height of 1 pixel.
    @IBOutlet private var rightSeparatorViewHeightConstraint: NSLayoutConstraint!
    
    /// Contains all the form fields to allow scrolling on smaller devices.
    @IBOutlet private var scrollView: UIScrollView!
    
    /// Displays UI to the user to indicate a successful sign up.
    @IBOutlet private var signUpSuccessfulView: UIView!
    
    // MARK: Private Properties
    
    /// The current first responder.
    private var firstResponderView: UIView?
    
    /// Performs validation and is used to determine what errors need to be displayed to the user.
    private var viewModel = SignUpViewModel()
    
    // MARK: Class Methods
    
    /**
     Returns a new instance of the view controller, instantiated from the correct nib.
     */
    static func viewController() -> SignUpViewController {
        let viewController = SignUpViewController(nibName: "SignUpViewController", bundle: nil)
        return viewController
    }
    
    // MARK: IBActions
    
    @IBAction private func cancelButtonPressed() {
        delegate?.signUpViewControllerDidCancel(self)
    }
    
    /**
     Called when the user presses the `createAccountButton`.
     */
    @IBAction private func createAccountButtonPressed() {
        guard allRequiredTextFieldsAreNotEmpty() else {
            return
        }
        
        guard allTextFieldsAreVaild() else {
            return
        }

        endEditing()
        show(loadingView, show: true, animated: true)
        
        let email = emailTextField.text!
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let password = passwordTextField.text!
        let passwordConfirmation = confirmPasswordTextField.text!
        let phoneNumber = phoneNumberTextField.text
        
        let strategy = SignUpSignInStrategy(email: email, firstName: firstName, lastName: lastName, password: password, passwordConfirmation: passwordConfirmation, phoneNumber: phoneNumber)
        
        signUp(withStrategy: strategy)
    }
    
    /**
     Called when the user presses the `signInWithFacebookButton`.
     */
    @IBAction private func signUpWithFacebookButtonPressed() {
        let strategy = FacebookSignInStrategy()
        signUp(withStrategy: strategy)
    }
    
    // MARK: Private Methods
    
    /**
     Verifies that all the required text fields on the form are not empty. This method also updates
     the UI to indicate any required fields that do not have any text.
     
     - returns: a boolean indicating if all the forms contain text.
     */
    private func allRequiredTextFieldsAreNotEmpty() -> Bool {
        let confirmPasswordVerified = !viewModel.showPasswordConfirmationRequiredLabel()
        let emailVerified = !viewModel.showEmailRequiredLabel()
        let firstNameVerified = !viewModel.showFirstNameRequiredLabel()
        let lastNameVerified = !viewModel.showLastNameRequiredLabel()
        let passwordVerified = !viewModel.showPasswordRequiredLabel()
        
        let allRequiredFieldsVerified = confirmPasswordVerified && emailVerified &&
            firstNameVerified && lastNameVerified && passwordVerified
        
        confirmPasswordTextField.setRequiredLabelHidden(confirmPasswordVerified, animated: true)
        emailTextField.setRequiredLabelHidden(emailVerified, animated: true)
        firstNameTextField.setRequiredLabelHidden(firstNameVerified, animated: true)
        lastNameTextField.setRequiredLabelHidden(lastNameVerified, animated: true)
        passwordTextField.setRequiredLabelHidden(passwordVerified, animated: true)
        
        return allRequiredFieldsVerified
    }
    
    /**
     Validates all text fields in the form.
     
     - returns: a boolean indicating if all the text fields in the form are valid.
     */
    private func allTextFieldsAreVaild() -> Bool {
        guard let errorString = viewModel.currentFormError() else {
            return true
        }
        
        displayAlert(message: errorString)
        
        return false
    }
    
    /**
     Called when the confirmPasswordTextField control sends a .DidEndOnExit event.
     */
    dynamic private func confirmPasswordTextFieldDidEndOnExit() {
        createAccountButtonPressed()
        view.endEditing(true)
    }
    
    /**
     Displays a UIAlertController to the user. The alert shows a title of "Error". The message
     in the alert is the message passed in to this function. The alert contains a cancel button with
     the title "OK".
     
     - parameter message: the error message to display to the user.
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
        passwordTextField.becomeFirstResponder()
    }
    
    /**
     Dismisses the keyboard no matter which text field is currently editing.
     */
    dynamic private func endEditing() {
        view.endEditing(true)
    }
    
    /**
     Called when the firstNameTextField control sends a .DidEndOnExit event.
     */
    dynamic private func firstNameTextFieldDidEndOnExit() {
        lastNameTextField.becomeFirstResponder()
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
        
        guard let viewToShow = firstResponderView else {
            return
        }
        
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue ?? 0.3
        
        // Calculate how much to adjust the content inset
        let bottomContentInset = keyboardRect.height
        let contentInset = UIEdgeInsetsMake(scrollView.contentInset.top,
                                            scrollView.contentInset.left,
                                            bottomContentInset,
                                            scrollView.contentInset.right)
        
        // Calculate how much the scroll view needs to be adjusted so bottom of viewToShow is visible
        let convertedFieldFrame = scrollView.convertRect(viewToShow.frame, fromView: viewToShow.superview)
        let scrollViewHeight = scrollView.frame.size.height
        let scrollViewAdjustedHeight = scrollViewHeight - bottomContentInset
        let maxYPadding: CGFloat = 5.0
        let maxY = CGRectGetMaxY(convertedFieldFrame) + maxYPadding
        var contentOffset: CGPoint?
        if maxY > scrollViewAdjustedHeight {
            let offsetY = maxY - scrollViewAdjustedHeight
            contentOffset = CGPointMake(0.0, offsetY)
        }
        
        UIView.animateWithDuration(duration) {
            self.scrollView.contentInset = contentInset
            if let unwrappedOffset = contentOffset {
                self.scrollView.setContentOffset(unwrappedOffset, animated: false)
            }
        }
    }
    
    /**
     Called when the lastNameTextField control sends a .DidEndOnExit event.
     */
    dynamic private func lastNameTextFieldDidEndOnExit() {
        phoneNumberTextField.becomeFirstResponder()
    }
    
    /**
     Called when the passwordTextField control sends a .DidEndOnExit event.
     */
    dynamic private func passwordTextFieldDidEndOnExit() {
        confirmPasswordTextField.becomeFirstResponder()
    }
    
    /**
     Called when the phoneNumberTextField control sends a .DidEndOnExit event.
     */
    dynamic private func phoneNumberTextFieldDidEndOnExit() {
        emailTextField.becomeFirstResponder()
    }
    
    /**
     Displays UI to the user to indicate a successful sign-up and alerts the delegate that the user
     successfully signed up.
     
     - parameter strategy:             the strategy used to sign up.
     - parameter accountSetupComplete: a boolean indicating if the users account setup has been 
     completed.
     */
    private func signedUpSuccessfully(withStrategy strategy: SignInStrategy, accountSetupComplete: Bool) {
        let animations: () -> () = {
            self.signUpSuccessfulView.alpha = 1.0
        }
        
        let completion: (Bool) -> () = {
            complete in
            self.delegate?.signUpViewController(self, didSignInWithStrategy: strategy, accountSetupComplete: accountSetupComplete)
        }
        
        UIView.animateWithDuration(0.3, animations: animations, completion: completion)
    }
    
    /**
     Makes a network request to allow the user to sign up.
     
     - parameter strategy: the strategy the user is using to sign up.
     */
    private func signUp(withStrategy strategy: SignInStrategy) {
        SessionCredentialsHandler.signIn(withStrategy: strategy) {
            loggedIn, accountSetupComplete, error in
            
            guard let error = error else {
                if loggedIn {
                    self.show(self.activityIndicator, show: false, animated: false)
                    self.signedUpSuccessfully(withStrategy: strategy, accountSetupComplete: accountSetupComplete)
                } else {
                    self.show(self.loadingView, show: false, animated: true)
                }
                
                return
            }
            
            self.show(self.loadingView, show: false, animated: true)
            if let localizedErrorString = error.userInfo[NSLocalizedFailureReasonErrorKey] as? String {
                self.displayAlert(message: localizedErrorString)
            }
        }
    }
    
    /**
     Called when the view controller receives a `UITextFieldTextDidBeginEditingNotification`
     notification.
     
     - parameter notification: the notification.
     */
    dynamic private func textFieldDidBeginEditing(notification: NSNotification) {
        firstResponderView = notification.object as? UITextField
    }
    
    /**
     Called when the view controller receives a `UITextFieldTextDidEndEditingNotification`
     notification.
     
     - parameter notification: the notification.
     */
    dynamic private func textFieldDidEndEditing(notification: NSNotification) {
        firstResponderView = nil
    }
}

// MARK: UIViewController Methods

extension SignUpViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textFieldDidBeginEditing(_:)), name: UITextFieldTextDidBeginEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textFieldDidEndEditing(_:)), name: UITextFieldTextDidEndEditingNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cornerRadius: CGFloat = 2.0
        
        createAccountButton.layer.cornerRadius = cornerRadius
        createAccountButton.backgroundColor = AppConfiguration.lightBlue()
        
        formOneContainerView.layer.cornerRadius = cornerRadius
        formOneContainerView.layer.masksToBounds = true
        
        formTwoContainerView.layer.cornerRadius = cornerRadius
        formTwoContainerView.layer.masksToBounds = true
        
        leftSeparatorViewHeightConstraint.constant = 1.0 / UIScreen.mainScreen().scale
        rightSeparatorViewHeightConstraint.constant = 1.0 / UIScreen.mainScreen().scale
        
        viewModel.confirmPasswordValidator = PasswordFieldValidator(textField: confirmPasswordTextField, fieldIsRequired: true)
        viewModel.emailValidator = EmailFieldValidator(textField: emailTextField, fieldIsRequired: true)
        viewModel.firstNameValidator = NameFieldValidator(textField: firstNameTextField, fieldIsRequired: true)
        viewModel.lastNameValidator = NameFieldValidator(textField: lastNameTextField, fieldIsRequired: true)
        viewModel.passwordValidator = PasswordFieldValidator(textField: passwordTextField, fieldIsRequired: true)
        viewModel.phoneNumberValidator = PhoneNumberFieldValidator(textField: phoneNumberTextField, fieldIsRequired: false)
        
        confirmPasswordTextField.addTarget(self, action: #selector(confirmPasswordTextFieldDidEndOnExit), forControlEvents: .EditingDidEndOnExit)
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidEndOnExit), forControlEvents: .EditingDidEndOnExit)
        firstNameTextField.addTarget(self, action: #selector(firstNameTextFieldDidEndOnExit), forControlEvents: .EditingDidEndOnExit)
        lastNameTextField.addTarget(self, action: #selector(lastNameTextFieldDidEndOnExit), forControlEvents: .EditingDidEndOnExit)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldDidEndOnExit), forControlEvents: .EditingDidEndOnExit)
        phoneNumberTextField.addTarget(self, action: #selector(phoneNumberTextFieldDidEndOnExit), forControlEvents: .EditingDidEndOnExit)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        view.backgroundColor = AppConfiguration.blue()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
