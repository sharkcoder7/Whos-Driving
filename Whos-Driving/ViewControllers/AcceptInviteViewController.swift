import UIKit

/// This view controller handles allowing a user to accept a trusted driver or household driver
/// invite from within the app.
class AcceptInviteViewController: UIViewController {
    
    // MARK: Public properties
    
    /// The initial invite being responded to.
    let invite: Invite
    
    /// After tapping accept, this is the invite response from the server.
    var inviteResponse: Invite?

    // MARK: IBOutlets
    
    /// The button a user can press to accept the invite.
    @IBOutlet weak var acceptButton: UIButton!
    
    /// Shows when a response is being sent to the server.
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /// Shows the details of the invite.
    @IBOutlet weak var detailLabel: UILabel!
    
    /// When pressed the view is dismissed.
    @IBOutlet weak var dismissButton: UIButton!
    
    /// When pressed the view is dismissed.
    @IBOutlet weak var ignoreButton: UIButton!
    
    /// The PersonButton showing the person who was invited.
    @IBOutlet weak var invitedPersonButton: PersonButton!
    
    /// Center X constraint of the invitedPersonButton, used for adjusting the position of the button
    /// for the success animation.
    @IBOutlet weak var invitedPersonButtonCenterXConstraint: NSLayoutConstraint!
    
    /// The PersonButton showing the person who sent the invite.
    @IBOutlet weak var invitingPersonButton: PersonButton!
    
    /// Center X constraint of the invitingPersonButton, used for adjusting the position of the button
    /// for the success animation.
    @IBOutlet weak var invitingPersonButtonCenterXConstraint: NSLayoutConstraint!
    
    /// Shows a summary of who sent the invite, and what type of invite it is.
    @IBOutlet weak var summaryLabel: UILabel!
    
    // MARK: Init and deinit methods
    
    /**
    Initializes a configured instance of this class setup to display information about the provided
    Invite object.
    
    - parameter invite The Invite to display to the user.
    
    - returns: A configured instance of this class.
    */
    required init(invite: Invite) {
        self.invite = invite
        
        super.init(nibName: "AcceptInviteViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    
    /**
    Called when the acceptButton is tapped.
    
    - parameter sender The button that was tapped.
    */
    @IBAction func acceptTapped(sender: AnyObject) {
        activityIndicator.startAnimating()
        acceptButton.userInteractionEnabled = false
        
        Invites.sharedInstace.acceptInviteForInviteToken(invite.inviteToken) { [weak self] (invite, error) -> Void in
            self?.activityIndicator.stopAnimating()
            self?.acceptButton.userInteractionEnabled = true
            
            if let error = error {
                let alert = defaultAlertController(error.localizedDescription)
                self?.presentViewController(alert, animated: true, completion: nil)
            } else {
                if let invite = invite {
                    self?.inviteResponse = invite
                    self?.animateToAccepted()
                }
            }
        }
    }
    
    /**
     Called when the dismissButton is tapped.
     
     - parameter sender The button that was tapped.
     */
    @IBAction func dismissTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     Called when the ignoreButton is tapped.
     
     - parameter sender The button that was tapped.
     */
    @IBAction func ignoreTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Private methods
    
    /**
    Animates the view based on the inviteResponse object. If the inviteResponse is valid, the two
    user images will animate away from each other, revealing the invitedPersonButton and updating
    the wording of the labels.
    */
    private func animateToAccepted() {
        summaryLabel.text = inviteResponse?.statusMessage
        detailLabel.hidden = true
        activityIndicator.stopAnimating()
        acceptButton.alpha = 0.0
        ignoreButton.alpha = 0.0
        dismissButton.alpha = 1.0
        
        if inviteResponse?.status == .OK {
            invitedPersonButton.hidden = false
            view.layoutIfNeeded()
            UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                let distanceFromCenter: CGFloat = 40.0
                self.invitingPersonButtonCenterXConstraint.constant = -distanceFromCenter
                self.invitedPersonButtonCenterXConstraint.constant = distanceFromCenter
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    // MARK: UIViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = nil
        navigationItem.hidesBackButton = true
        
        invitingPersonButton.populateViewForPerson(invite.invitingDriver)
        invitedPersonButton.populateViewForPerson(invite.invitedDriver)
        summaryLabel.text = invite.statusMessage
        detailLabel.text = invite.statusDetail
        acceptButton.backgroundColor = AppConfiguration.green()
        ignoreButton.backgroundColor = AppConfiguration.red()
        dismissButton.backgroundColor = AppConfiguration.darkGray()
        activityIndicator.color = UIColor.whiteColor()
        view.backgroundColor = AppConfiguration.blue()
        
        if invite.status == .OK {
            acceptButton.alpha = 1.0
            ignoreButton.alpha = 1.0
            dismissButton.alpha = 0.0
        } else {
            acceptButton.alpha = 0.0
            ignoreButton.alpha = 0.0
            dismissButton.alpha = 1.0
        }
    }
}
