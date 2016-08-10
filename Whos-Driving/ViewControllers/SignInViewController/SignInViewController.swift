import UIKit

/// Defines methods for responding to events in the SignInViewController.
protocol SignInViewControllerDelegate: class {
    
    /**
     Called when the user did successfully sign in.
     */
    func signInViewControllerDidSignIn()
}

/// View controller used to show sign in options to the user.
class SignInViewController: UIViewController {
    
    // MARK: Propertes
    
    /// The delegate is responsible for responding to sign in events.
    weak var delegate: SignInViewControllerDelegate?
    
    // MARK: IBOutlets
    
    /// Loading spinner shown when the log in is processing.
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    /// A container view for the text fields that accept the users email/password credentials.
    @IBOutlet private var credentialContainerView: UIView!
    
    /// A text field that accepts the users email address.
    @IBOutlet private var emailTextField: TextField!
    
    /// The button for signing in with an email address.
    @IBOutlet private var emailSignInButton: UIButton!
    
    /// The button for signing into Facebook.
    @IBOutlet private weak var facebookSignInButton: UIButton!
    
    /// A view on the left side of the screen used to separate login methods.
    @IBOutlet private var leftSeparatorView: UIView!
    
    /// Used to make the left separator view a height of 1 pixel.
    @IBOutlet private var leftSeparatorViewHeightConstraint: NSLayoutConstraint!
    
    /// Displays the Who's Driving logo.
    @IBOutlet private var logoImageView: UIImageView!
    
    /// A text label displaying the text "or".
    @IBOutlet private var orLabel: UILabel!
    
    /// A text field that accepts the users password.
    @IBOutlet private var passwordTextField: TextField!
    
    /// A view on the right side of the screen used to separate login methods.
    @IBOutlet private var rightSeparatorView: UIView!
    
    /// Used to make the right separator view a height of 1 pixel.
    @IBOutlet private var rightSeparatorViewHeightConstraint: NSLayoutConstraint!
    
    /// Contains all the content in the view controller in case smaller devices need to scroll the
    /// content.
    @IBOutlet private var scrollView: UIScrollView!
    
    /// The button that allows the user to sign up.
    @IBOutlet private var signUpButton: UIButton!
    
    // MARK: Private Properties
    
    private let navigationControllerDelegate = SignInNavigationControllerDelegate()
    
    /// Used to model the views displayed by the view controller.
    private var viewModel = SignInViewModel() {
        didSet {
            activityIndicator.alpha = viewModel.activityIndicatorAlpha
            credentialContainerView.alpha = viewModel.credentialContainerAlpha
            emailSignInButton.alpha = viewModel.signInButtonAlpha
            facebookSignInButton.alpha = viewModel.signInButtonAlpha
            leftSeparatorView.alpha = viewModel.separatorViewAlpha
            logoImageView.alpha = viewModel.logoViewAlpha
            orLabel.alpha = viewModel.separatorViewAlpha
            rightSeparatorView.alpha = viewModel.separatorViewAlpha
            signUpButton.alpha = viewModel.signInButtonAlpha
        }
    }
    
    // MARK: Class Methods
    
    /**
     Creates a new instance of the view controller from the storyboard and returns it.
     
     - returns: a new instance of the view controller.
     */
    class func viewController() -> SignInViewController {
        let signInViewController = SignInViewController(nibName: "SignInViewController", bundle: nil)
        return signInViewController
    }
    
    // MARK: IBAction Methods
    
    /**
     Attempts to sign the user in with the supplied email/password.
     
     - parameter sender: The button that was tapped.
     */
    @IBAction private func emailSignInTapped(sender: UIButton) {
        let email = emailTextField.text
        let password = passwordTextField.text
        let emailSignInStrategy = EmailSignInStrategy(email: email, password: password)
        performSignIn(withStrategy: emailSignInStrategy)
    }
    
    /**
    Called when the facebookSignInButton is tapped.
    
    - parameter sender The button that was tapped.
    */
    @IBAction private func facebookSignInTapped(sender: UIButton) {
        activityIndicator.startAnimating()
        facebookSignInButton.enabled = false
        performSignIn(withStrategy: FacebookSignInStrategy())
    }
    
    @IBAction private func forgotPasswordButtonPressed() {
        let viewController = ForgotPasswordViewController.viewController()
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    /**
     Called when the user presses the sign-up button.
     */
    @IBAction private func signUpButtonPressed() {
        let viewController = SignUpViewController.viewController()
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: Private Methods
    
    /**
     Called when the emailTextField control sends a .DidEndOnExit event.
     */
    dynamic private func emailTextFieldDidEndOnExit() {
        passwordTextField.becomeFirstResponder()
    }
    
    dynamic private func endEditing() {
        view.endEditing(true)
    }
    
    /**
     Handles the error that results from the user attempting to sign-in.
     
     - parameter error: the error that was generated from the network request.
     */
    private func handleSignInError(error: NSError?) {
        let displayAlertWithMessage: (String) -> () = {
            message in
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        guard let localizedErrorString = error?.userInfo[NSLocalizedFailureReasonErrorKey] as? String else {
            displayAlertWithMessage("Oops. Please check your network connection and try again.")
            return
        }
        
        displayAlertWithMessage(localizedErrorString)
    }
    
    /**
     Handles the successful sign-in of the user.
     
     - parameter strategy:             the strategy the user used to sign-in.
     - parameter accountSetupComplete: a boolean indicating if the user has completed setting up
     their account.
     */
    private func handleSuccessfulSignIn(forStrategy strategy: SignInStrategy, accountSetupComplete: Bool) {
        delegate?.signInViewControllerDidSignIn()
        navigationController?.delegate = navigationControllerDelegate
        
        // Successfully logged in
        if accountSetupComplete {
            let invites = Invites.sharedInstace
            
            // pending invite token, show the invite screen
            if let pendingToken = invites.pendingInviteToken {
                invites.getInviteForInviteToken(pendingToken) {
                    invite, error in
                    if let invite = invite {
                        let acceptInviteVC = AcceptInviteViewController(invite: invite)
                        self.navigationController?.pushViewController(acceptInviteVC, animated: true)
                    } else {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        } else {
            let setupViewController = SetupContactInfoViewController(nibName: "SetupContactInfoViewController", bundle: nil)
            setupViewController.contactInfoStrategy = strategy.contactInfoStrategy
            self.navigationController?.pushViewController(setupViewController, animated: true)
        }
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
     Called when the emailTextField control sends a .DidEndOnExit event.
     */
    dynamic private func passwordTextFieldDidEndOnExit() {
        passwordTextField.resignFirstResponder()
        emailSignInTapped(emailSignInButton)
    }
    
    /**
     Performs a network request with the specified sign-in strategy.
     
     - parameter strategy: the strategy the user is using to sign-in.
     */
    private func performSignIn(withStrategy strategy: SignInStrategy) {
        endEditing()
        activityIndicator.startAnimating()
        UIView.animateWithDuration(0.3) { self.viewModel.state = .SigningIn }
        
        SessionCredentialsHandler.signIn(withStrategy: strategy) {
            [weak self] loggedIn, accountSetupComplete, error in
            self?.activityIndicator.stopAnimating()
            self?.facebookSignInButton.enabled = true
            
            if loggedIn == true {
                UIView.animateWithDuration(0.3) { self?.viewModel.state = .SignInComplete }
                self?.handleSuccessfulSignIn(forStrategy: strategy, accountSetupComplete: accountSetupComplete)
            } else if error == nil {
                UIView.animateWithDuration(0.3) { self?.viewModel.state = .Default }
                // Request cancelled or logged out
                dLog("Cancelled")
            } else {
                UIView.animateWithDuration(0.3) { self?.viewModel.state = .Default }
                self?.handleSignInError(error)
            }
        }
    }
    
    /**
     Called when the view controller recieves a UITextFieldTextDidChangeNotification notification.
     
     - parameter notification: the notification.
     */
    dynamic private func textFieldTextDidChange(notification: NSNotification) {
        emailSignInButton?.enabled = viewModel.emailSignInEnabled
    }
}

// MARK: ForgotPasswordViewControllerDelegate Methods

extension SignInViewController: ForgotPasswordViewControllerDelegate {
    func forgotPasswordViewControllerDidCancel(forgotPasswordViewController: ForgotPasswordViewController) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func forgotPasswordViewControllerDidComplete(forgotPasswordViewController: ForgotPasswordViewController) {
        navigationController?.popViewControllerAnimated(true)
    }
}

// MARK: ResetPasswordViewControllerDelegate Methods

extension SignInViewController: ResetPasswordViewControllerDelegate {
    func resetPasswordViewControllerDidComplete(resetPasswordViewController: ResetPasswordViewController) {
        navigationController?.popViewControllerAnimated(true)
    }
}

// MARK: SignUpViewControllerDelegate Methods

extension SignInViewController: SignUpViewControllerDelegate {
    func signUpViewControllerDidCancel(signUpViewController: SignUpViewController) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func signUpViewController(signUpViewController: SignUpViewController, didSignInWithStrategy signInStrategy: SignInStrategy, accountSetupComplete: Bool) {
        handleSuccessfulSignIn(forStrategy: signInStrategy, accountSetupComplete: accountSetupComplete)
    }
}

// MARK: UIViewControllerMethods

extension SignInViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let borderColor = AppConfiguration.lightGray().CGColor
        let borderWidth = 1.0 / UIScreen.mainScreen().scale
        let cornerRadius: CGFloat = 2.0
        
        credentialContainerView.layer.borderColor = borderColor
        credentialContainerView.layer.borderWidth = borderWidth
        credentialContainerView.layer.masksToBounds = true
        credentialContainerView.layer.cornerRadius = cornerRadius
        
        emailSignInButton.backgroundColor = AppConfiguration.lightBlue()
        emailSignInButton.layer.cornerRadius = cornerRadius
        emailSignInButton.layer.masksToBounds = true
        
        let fontSize: CGFloat = 15.0
        
        let regularAttributes = [NSForegroundColorAttributeName : AppConfiguration.white(), NSFontAttributeName : UIFont(name: Font.HelveticaNeueLight, size: fontSize)!]
        let boldAttributes = [NSForegroundColorAttributeName : AppConfiguration.white(), NSFontAttributeName : UIFont(name: Font.HelveticaNeueBold, size: fontSize)!]
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ", attributes: regularAttributes)
        let signUp = NSAttributedString(string: "Sign Up", attributes: boldAttributes)
        
        attributedTitle.appendAttributedString(signUp)
        
        signUpButton.setAttributedTitle(attributedTitle, forState: .Normal)
        
        leftSeparatorViewHeightConstraint.constant = 1.0 / UIScreen.mainScreen().scale
        rightSeparatorViewHeightConstraint.constant = 1.0 / UIScreen.mainScreen().scale
        
        viewModel.emailValidator = EmailFieldValidator(textField: emailTextField, fieldIsRequired: true)
        viewModel.passwordValidator = PasswordFieldValidator(textField: passwordTextField, fieldIsRequired: true)
        
        view.backgroundColor = AppConfiguration.blue()
        SessionCredentialsHandler.logoutWithFacebook()
        navigationController?.view.backgroundColor = AppConfiguration.offWhite()
        navigationItem.hidesBackButton = true
        
        // Required due to AppDelegate appearance setting the default gray, wich overrides the nib.
        activityIndicator.color = AppConfiguration.white()
        
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidEndOnExit), forControlEvents: .EditingDidEndOnExit)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldDidEndOnExit), forControlEvents: .EditingDidEndOnExit)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        view.backgroundColor = AppConfiguration.blue()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textFieldTextDidChange(_ :)), name: UITextFieldTextDidChangeNotification, object: nil)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
