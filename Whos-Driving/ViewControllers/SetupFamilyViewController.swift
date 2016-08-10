import MessageUI
import UIKit

/// View controller shown when setting up the user for the first time. This view controller is for
/// setting up trusted drivers, household drivers and kids.
class SetupFamilyViewController: UIViewController {
    
    // MARK: Private Properties
    
    /// The user's address line one.
    private let address1: String
    
    /// The user's address line two.
    private let address2: String
    
    /// The user's city.
    private let city: String
    
    /// The user's email address.
    private let email: String
    
    /// The user's avatar image.
    private var image: UIImage?
    
    /// True if the user has sent a household driver invite.
    private var invitedSpouse = false
    
    /// InviteSender controller.
    private var invites: InviteSender?
    
    /// True if the user is currently inviting a trusted driver.
    private var isTrustedDriversFlow = false
    
    /// Array of kids the user has created.
    private var kidsArray: Array<Person>
    
    /// The user's phone number.
    private let mobileNumber: String
    
    /// The user's state.
    private let state: String
    
    /// The number of trusted drivers the user has sent.
    private var trustedDriversCount = 0
    
    /// The user's zip code.
    private let zip: String
    
    // MARK: IBOutlets
    
    /// Label in the headerContainerView.
    @IBOutlet private weak var headerLabel: UILabel!
    
    /// Horizontal spacing constraint for the headerContainerView.
    @IBOutlet private weak var headerContainerLeftConstraint: NSLayoutConstraint!
    
    /// View at the top of the view controller.
    @IBOutlet private weak var headerContainerView: UIView!
    
    /// Width constraint for the headerContainerView.
    @IBOutlet private weak var headerContainerWidthConstraint: NSLayoutConstraint!
    
    /// The button for inviting a spouse.
    @IBOutlet private weak var inviteSpouseButton: PersonButton!
    
    /// Collection view showing the kids the user has added.
    @IBOutlet private weak var kidsCollectionView: UICollectionView!
    
    /// Scroll view containing all the other views.
    @IBOutlet private weak var scrollView: UIScrollView!
    
    /// Label showing details of what the user should do on this setup screen.
    @IBOutlet private weak var subheadingLabel: UILabel!
    
    /// Title describing the 3rd step in the setup process.
    @IBOutlet private weak var title3Label: UILabel!
    
    /// Title describing the 4th step in the setup process.
    @IBOutlet private weak var title4Label: UILabel!
    
    /// Title describing the 5th step in the setup process.
    @IBOutlet private weak var title5Label: UILabel!
    
    /// Label with more information about the title5Label.
    @IBOutlet private weak var title5SubLabel: UILabel!
    
    /// Collection view showing the number of trusted driver invites that have been sent.
    @IBOutlet private weak var trustedDriverCollectionView: UICollectionView!

    // MARK: Init and Deinit Methods
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     Creates a new instance of this class, configured with the provided properties for creating a 
     new user.
     
     - parameter address1String Address line one of the new user.
     - parameter address2String Address line two of the new user.
     - parameter cityString City of the new user.
     - parameter emailString Email of the new user.
     - parameter userImage Avatar image of the new user.
     - parameter mobileNumberString Phone number of the new user.
     - parameter stateString State of the new user.
     - parameter zipString Zip code of the new user.
     
     - returns: Configured instance of this class.
     */
    required init(address1 address1String: String, address2 address2String: String, city cityString: String, email emailString: String, image userImage: UIImage?, mobileNumber mobileNumberString: String, state stateString: String, zip zipString: String) {
        address1 = address1String
        address2 = address2String
        city = cityString
        email = emailString
        image = userImage
        kidsArray = []
        mobileNumber = mobileNumberString
        state = stateString
        zip = zipString
        
        super.init(nibName: "SetupFamilyViewController", bundle: nil)
        
        title = NSLocalizedString("Welcome!", comment: "Welcome screen title")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Instance Methods
    
    /**
    Called when the save button is tapped.
    */
    func saveTapped() {
        let properties: [NSObject : AnyObject] = [
            AnalyticsController.InvitedSpouseKey : invitedSpouse,
            AnalyticsController.KidsCountKey : kidsArray.count,
            AnalyticsController.TrustedDriverInvitesCountKey : trustedDriversCount
        ]
        AnalyticsController().track("Clicked create user", context: .CreateUser, properties: properties)
        
        let savingViewController = UploadingViewController()
        savingViewController.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(savingViewController, animated: true)
        
        Profiles.sharedInstance.updateUser(address1, address2: address2, city: city, email: email, mobileNumber: mobileNumber, state: state, zip: zip, s3ImageURL: nil) { [weak self] (person, error) -> Void in
            if error != nil {
                savingViewController.navigationController?.popViewControllerAnimated(true)
                dLog("Error: \(error)")
                let alertController = defaultAlertController(error!.localizedDescription)
                self?.presentViewController(alertController, animated: true, completion: nil)
                return
            } else if let updatedImage = self?.image {
                if let person = person {
                    Profiles.sharedInstance.updateCurrentUsersProfile(person, image: updatedImage, completion: { [weak self] (error) -> Void in
                        if error != nil {
                            dLog("Error: \(error)")
                            let alertController = defaultAlertController(error!.localizedDescription)
                            self?.presentViewController(alertController, animated: true, completion: nil)
                        }
                        
                        self?.finishedCreatingUser()
                    })
                } else {
                    self?.finishedCreatingUser()
                }
            } else {
                self?.finishedCreatingUser()
            }
        }
    }
    
    // MARK: Private Methods
    
    /**
    Display an InviteSender for the provided flow.
    
    - parameter trustedDriverFlow True if this is a trusted driver invite, false for a household
                                  invite.
    */
    private func displayActionSheet(trustedDriverFlow: Bool) {
        isTrustedDriversFlow = trustedDriverFlow
        let inviteType = trustedDriverFlow ? InviteType.Trusted : InviteType.Household
        invites = InviteSender(presentingViewController: self, delegate: self)
        invites!.presentInvite(inviteType)
    }
    
    /**
     Checks if there are any pending Invites to show to the user after they've finished setting up
     their account. Otherwise dismisses the view.
     */
    private func finishedCreatingUser() {
        Profiles.sharedInstance.completeAccountSetup {
            complete in
            dLog("Account setup complete: \(complete)")
        }
        
        let invites = Invites.sharedInstace
        
        // pending invite token, show the invite screen
        if let pendingToken = invites.pendingInviteToken {
            invites.getInviteForInviteToken(pendingToken, completion: { [weak self] (invite, error) -> Void in
                if let invite = invite {
                    let acceptInviteVC = AcceptInviteViewController(invite: invite)
                    self?.navigationController?.pushViewController(acceptInviteVC, animated: true)
                } else {
                    self?.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: IBAction Methods
    
    /**
    Called when the invite button is tapped.
    
    - parameter sender The button that was tapped.
    */
    @IBAction func inviteButtonTapped(sender: UIButton) {
        displayActionSheet(false)
    }
    
    // MARK: UIViewController Methods
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerContainerWidthConstraint.constant = view.frame.width - (headerContainerLeftConstraint.constant * 2)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        headerContainerView.backgroundColor = AppConfiguration.green()
        headerContainerView.layer.borderColor = AppConfiguration.lightGray().CGColor
        headerContainerView.layer.borderWidth = AppConfiguration.borderWidth()
        
        headerLabel.textColor = AppConfiguration.white()
        scrollView.backgroundColor = AppConfiguration.offWhite()
        subheadingLabel.textColor = AppConfiguration.white()
        title3Label.textColor = AppConfiguration.darkGray()
        title4Label.textColor = AppConfiguration.darkGray()
        title5Label.textColor = AppConfiguration.darkGray()
        title5SubLabel.textColor = AppConfiguration.mediumGray()
        
        let saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem = saveButton
        
        let personCellNib = UINib(nibName: "PersonCollectionViewCell", bundle: NSBundle.mainBundle())
        kidsCollectionView.registerNib(personCellNib, forCellWithReuseIdentifier: PersonCollectionViewCell.reuseIdentifier)
        trustedDriverCollectionView.registerNib(personCellNib, forCellWithReuseIdentifier: PersonCollectionViewCell.reuseIdentifier)
        
        inviteSpouseButton.populateViewForType(PersonButtonType.Invite)
        
        Riders().getHouseholdRiders { [weak self] (riders, error) -> Void in
            if error == nil {
                self?.kidsArray = riders
                self?.kidsCollectionView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsController().screen("Create user setup family")
    }
}

// MARK: AddKidViewControllerDelegate methods

extension SetupFamilyViewController: AddKidViewControllerDelegate {
    func addedPerson(addKidViewController: AddKidViewController, addedPerson: Person) {
        kidsArray.append(addedPerson)
        
        kidsCollectionView.reloadData()
    }
}

// MARK: InviteSenderDelegate methods

extension SetupFamilyViewController: InviteSenderDelegate {
    func invitesFinished(success: Bool) {
        if isTrustedDriversFlow == true {
            if success {
                trustedDriversCount += 1
                trustedDriverCollectionView.reloadData()
            }
        } else {
            if success {
                invitedSpouse = true
                inviteSpouseButton.populateViewForType(PersonButtonType.Done)
            }
        }
    }
}

// MARK: UICollectionViewDataSource methods

extension SetupFamilyViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PersonCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! PersonCollectionViewCell
        cell.personButton.userInteractionEnabled = false
        cell.checkMarkWhenSelected = false
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == kidsCollectionView {
            return kidsArray.count + 1
        } else {
            return trustedDriversCount + 1
        }
    }
}

// MARK: UICollectionViewDelegate methods

extension SetupFamilyViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == kidsCollectionView {
            if indexPath.row < kidsArray.count {
                // TODO: Open the person's profile
            } else if let sender = collectionView.cellForItemAtIndexPath(indexPath) {
                if let navigationController = navigationController {
                    let addKidsViewController = AddKidViewController()
                    addKidsViewController.addKidDelegate = self
                    let modalViewController = ModalViewController(viewController: addKidsViewController)
                    modalViewController.presentOverViewController(navigationController, sender: sender)
                }
            }
        } else {
            if indexPath.row < trustedDriversCount {
                // TODO: Open the person's profile
            } else if collectionView.cellForItemAtIndexPath(indexPath) != nil {
                displayActionSheet(true)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let personCell = cell as! PersonCollectionViewCell
        if collectionView == kidsCollectionView {
            if indexPath.row < kidsArray.count {
                let person = kidsArray[indexPath.row]
                personCell.configureForPerson(person)
            } else {
                personCell.configureForPersonButtonType(PersonButtonType.Add)
            }
        } else {
            if indexPath.row < trustedDriversCount {
                personCell.configureForPersonButtonType(PersonButtonType.Done)
            } else {
                personCell.configureForPersonButtonType(PersonButtonType.Invite)
                if trustedDriversCount > 0 {
                    personCell.personButton.nameLabel.text = "Invite Another"
                }
            }
        }
    }
}
