import UIKit

/**
 The style used to configure the PersonButton.
 */
enum PersonButtonStyle {

    /// Will show an X instead of the user's image, unless the person is the current user. the
    /// current user is never shown with an X.
    case CannotDrive
    /// Show the colored representation of a driver status instead of their avatar.
    case Colored
    /// Show the user's initials, or their avatar if they have one.
    case Initials
    /// Use light gray text and background. Used for representing the button is disabled or expired.
    case Gray
}

/**
 Special configurations of the PersonButton used to setup the view with predefined values.
 */
enum PersonButtonType {
    /// shows a + button with "add" text
    case Add
    /// shows a blank default avatar with "add photo" text
    case AddPhoto
    /// shows a check mark with "done" text
    case Done
    /// shows a + button with "invite" text
    case Invite
    /// shows a check mark with "invited" text
    case Invited
    /// shows a question mark with "not sure" text
    case NotSureYet
}

/// Classes that conform to this protocol will be informed when the trusted driver represented in
/// this PersonButton is deleted.
protocol TrustedDriverListener: class {
    func trustedDriverWasDeleted(driver: Person)
}

/// This class is a flexible UIControl that is used to represent a person throughout the app, or
/// one of various preconfigured button setups.
class PersonButton: UIControl {
    
    // MARK: Constants
    
    let AddText = "Add"
    let AddPhotoText = "Add Photo"
    let DoneText = "Done"
    let InviteText = "Invite"
    let InvitedText = "Invited"
    let NotSureYetText = "Not Sure"
    
    /// This is the default completion block used for tappedCompletion. It presents the modal profile
    /// view of the user assigned to the PersonButton.
    static let defaultTappedHandler: ((personButton: PersonButton) -> Void) = { personButton in
        if let person = personButton.person {
            let profileViewController = ProfileModalViewController(aPerson: person)
            profileViewController.trustedDriverListener = personButton
            let modalViewController = ModalViewController(viewController: profileViewController)
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if let rootVC = appDelegate.window?.rootViewController {
                modalViewController.presentOverViewController(rootVC, sender: personButton)
            }
        }
    }
    
    // MARK: Public properties

    /// Listener informed if the person in the PersonButton is deleted.
    weak var trustedDriverListener: TrustedDriverListener?

    /// Set this property to true to show a green check mark over the view, set to false to hide it.
    var chosen: Bool = false {
        didSet {
            if chosen == true {
                accessoryImgView.image = UIImage(named:"status-check")
                accessoryImgView.backgroundColor = AppConfiguration.green()
            } else {
                accessoryImgView.image = nil
                accessoryImgView.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    /**
    Size of the image view and first letter label.
    */
    @IBInspectable var imageSize: CGFloat = 40.0 {
        didSet {
            containerViewHeightConstraint.constant = imageSize
            
            imgView.layer.cornerRadius = imageSize / 2.0
            accessoryImgView.layer.cornerRadius = imageSize / 2.0
            firstLetterLabel.layer.cornerRadius = imageSize / 2.0
        }
    }
    
    /**
    Setting this property updates the nameLabel with the name passed in, and displays the first
    letter of the name in the firstLetterLabel positioned in the center of the imageView.
    */
    var name: String? = "Unknown" {
        didSet {
            updateLabelsForName(name)
        }
    }
    
    /**
    The person represented by this button, or nil if there's no person.
    */
    var person: Person?
    
    /**
    This closure will be called whenever the button is tapped. It defaults to showing the profile
    view over the entire screen if a person is assigned to the person property. If this is the 
    desired behavior ensure that self.person is assigned directly or via populateViewForPerson().
    */
    var tappedCompletion: ((personButton: PersonButton) -> Void) = defaultTappedHandler
    
    /**
    Setting this property adjusts the layout of the imageView and nameLabel. If set to true, the
    imageView is centered in the view, with the nameLabel centered below it. If set to false, the 
    imageView is set to the left of the view, with the nameLabel to the right of it.
    */
    @IBInspectable var verticalLayout: Bool = false {
        didSet {
            if verticalLayout {
                containerViewCenterXAlignment.priority = 999.0
                containerViewVerticalSpace.priority = 999.0
                containerViewCenterYAlignment.priority = 250.0
                containerViewLeadingSpace.priority = 250.0
                
                
                nameLabelVerticalSpace.priority = 999.0
                nameLabelCenterXAlignment.priority = 999.0
                nameLabelCenterYAlignment.priority = 250.0
                nameLabelLeadingSpace.priority = 250.0
                
                nameLabel.textAlignment = NSTextAlignment.Center
            }
            else {
                containerViewCenterXAlignment.priority = 250.0
                containerViewVerticalSpace.priority = 250.0
                containerViewCenterYAlignment.priority = 999.0
                containerViewLeadingSpace.priority = 999.0
                
                nameLabelVerticalSpace.priority = 250.0
                nameLabelCenterXAlignment.priority = 250.0
                nameLabelCenterYAlignment.priority = 999.0
                nameLabelLeadingSpace.priority = 999.0
                
                nameLabel.textAlignment = NSTextAlignment.Left
            }
            
            setNeedsLayout()
        }
    }
    
    // MARK: Outlets
    
    /// The top most image view. Used to show accessory images such as the green check mark.
    @IBOutlet weak var accessoryImgView: UIImageView!

	/// The container view for the firstLetterLabel, imgView, and accessoryImgView.
    @IBOutlet weak var containerView: UIView!

    /// The height of the imgView, accessoryImgView, and firstLetterLabel.
    @IBOutlet private weak var containerViewHeightConstraint: NSLayoutConstraint!
    
    /// Bottom most view, shows the first initial of the person in the PersonButton.
    @IBOutlet weak var firstLetterLabel: UILabel!
    
    /// Image view below the accessoryImgView.
    @IBOutlet weak var imgView: UIImageView!

    /// Label showing the name of the user, or the title of the button.
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: Outlets - Vertical layout constraints
    
    // All of these constraints are adjusted to priority 750 or 250 depending on if verticalLayout
    // is set to true or false. This controls where the views are laid out in the view.
    @IBOutlet private weak var containerViewCenterXAlignment: NSLayoutConstraint!
    @IBOutlet private weak var containerViewCenterYAlignment: NSLayoutConstraint!
    @IBOutlet private weak var containerViewLeadingSpace: NSLayoutConstraint!
    @IBOutlet private weak var containerViewVerticalSpace: NSLayoutConstraint!
    @IBOutlet private weak var nameLabelCenterXAlignment: NSLayoutConstraint!
    @IBOutlet private weak var nameLabelCenterYAlignment: NSLayoutConstraint!
    @IBOutlet private weak var nameLabelLeadingSpace: NSLayoutConstraint!
    @IBOutlet private weak var nameLabelVerticalSpace: NSLayoutConstraint!
    
    // MARK: Init and deinit methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
    }
    
    // MARK: Private methods
    
    /**
    Loads the view from the nib and adds it to the main view.
    */
    private func xibSetup() {
        let view = loadViewFromNib()
        
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view": view]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view": view]))
        
        accessoryImgView.clipsToBounds = true
        imgView.clipsToBounds = true
    }
    
    /**
    Loads the view from the nib.
    
    - returns The view loaded from the nib.
    */
    private func loadViewFromNib() -> UIView {
        
        let nib = UINib(nibName: "PersonButton", bundle: nil)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    // MARK: Instance methods
    
    /**
    Populates the view for the Person using the DriverViewModel. Also assigns Person to the person
    property.
    
    - parameter person The person whose data will be used to populate the view model.
    - parameter style  The style of button to display (optional). The default value is .Initials.
    */
    func populateViewForPerson(person: Person?, style: PersonButtonStyle = .Initials) {
        self.person = person

        let viewModel = DriverViewModel(driver: person)

        name = viewModel.text()
        nameLabel.textColor = viewModel.textColor()
        nameLabel.font = viewModel.font()

        if style == .Colored {
            accessoryImgView.backgroundColor = viewModel.imageBackground()
            accessoryImgView.image = viewModel.image()
        } else if style == .Gray {
            accessoryImgView.image = viewModel.image()
            accessoryImgView.backgroundColor = AppConfiguration.lightGray()
            nameLabel.textColor = AppConfiguration.lightGray()
        } else if style == .CannotDrive && person?.relationship != .CurrentUser {
            // "cannot drive" doesn't apply to current user
            accessoryImgView.backgroundColor = AppConfiguration.disabledLightGray()
            accessoryImgView.image = UIImage(named:"btn-x")!
            nameLabel.textColor = AppConfiguration.lightGray()
        }

        ImageController.sharedInstance.loadImageForPerson(person) { [weak self] image, error in
            // confirm person wasn't changed before assigning the image
            if self?.person?.id == person?.id {
                self?.imgView.image = image
            }
        }
    }
    
    /**
    Populates the view based on the provided type.
    
    - parameter buttonType The style of the button. Assigns preconfigured values based on the type.
    */
    func populateViewForType(buttonType: PersonButtonType) {
        accessoryImgView.hidden = false
        firstLetterLabel.text = nil
        person = nil

        switch buttonType {
        case .Add:
            nameLabel.text = AddText
            nameLabel.textColor = AppConfiguration.blue()
            accessoryImgView.backgroundColor = AppConfiguration.blue()
            accessoryImgView.image = UIImage(named: "status-add")
            
        case .AddPhoto:
            nameLabel.text = AddPhotoText
            nameLabel.textColor = AppConfiguration.blue()
            accessoryImgView.backgroundColor = UIColor.whiteColor()
            accessoryImgView.image = UIImage(named: "addphoto")
            
        case .Done:
            nameLabel.text = DoneText
            nameLabel.textColor = AppConfiguration.lightGray()
            accessoryImgView.backgroundColor = AppConfiguration.lightGray()
            accessoryImgView.image = UIImage(named: "status-check")
            
        case .Invite:
            nameLabel.text = InviteText
            nameLabel.textColor = AppConfiguration.blue()
            accessoryImgView.image = UIImage(named: "status-add")
            accessoryImgView.backgroundColor = AppConfiguration.blue()
            
        case .Invited:
            nameLabel.text = InvitedText
            nameLabel.textColor = AppConfiguration.lightGray()
            accessoryImgView.backgroundColor = AppConfiguration.lightGray()
            accessoryImgView.image = UIImage(named: "status-check")
            
        case .NotSureYet:
            nameLabel.text = NotSureYetText
            nameLabel.textColor = AppConfiguration.mediumGray()
            firstLetterLabel.text = "?"
        }
    }
    
    /**
    Resets the UI back to default.
    */
    func resetUI() {
        imgView.image = nil
        imgView.backgroundColor = UIColor.clearColor()
        accessoryImgView.image = nil
        accessoryImgView.backgroundColor = UIColor.clearColor()
        person = nil
        name = ""
        chosen = false
    }
    
    /**
    Updates the nameLabel with the name provided and assigns the first letter of the name to the
    firstLetterLabel.
    
    - parameter name The name to display.
    */
    func updateLabelsForName(name: String?) {
        guard let name = name else {
            nameLabel.text = nil
            firstLetterLabel.text = ""
            return
        }
        
        nameLabel.text = name
        if name.characters.count > 0 {
            firstLetterLabel.text = (name as NSString).substringToIndex(1).uppercaseString
        } else {
            firstLetterLabel.text = ""
        }
    }
    
    // MARK: Private Methods
    
    /**
    Called when the PersonButton is tapped. Calls the closure in self.tappedCompletion.
    
    - parameter personButton The PersonButton that was tapped.
    */
    @objc private func tapped(personButton: PersonButton) {
        tappedCompletion(personButton: self)
    }
    
    // MARK: Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clearColor()
        
        addTarget(self, action: #selector(tapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        name = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.layer.cornerRadius = imageSize / 2.0
    }
}

extension PersonButton: TrustedDriverListener {
    func trustedDriverWasDeleted(driver: Person) {
        trustedDriverListener?.trustedDriverWasDeleted(driver)
    }
}
