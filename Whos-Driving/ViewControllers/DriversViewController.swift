import MessageUI
import UIKit

/// View controller showing the current user's household and trusted drivers.
class DriversViewController: UIViewController {
    
    // MARK: Private Properties
    
    /// The current user.
    private var currentUser: Person?
    
    /// The Drivers controller object for fetching drivers.
    private let drivers = Drivers()
    
    /// Array of trusted/household drivers.
    private var driversArray: Array<Person>
    
    /// InviteSender object for inviting household/trusted drivers.
    private var invites: InviteSender?
    
    /// True if an invite has been sent.
    private var inviteSent: Bool = false
    
    /// Loading view shown when loading data from the server.
    private var loadingView = LoadingView()
    
    // MARK: IBOutlets
    
    /// Collection view showing the drivers.
    @IBOutlet private weak var collectionView: UICollectionView!
    
    /// Empty state view shown when the user has no household or trusted drivers.
    @IBOutlet private weak var emptyStateView: EmptyStateView!
    
    // MARK: Init Methods
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        driversArray = []
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        title = NSLocalizedString("Drivers", comment: "Drivers tab title.")
        tabBarItem.image = UIImage(named: "tab-drivers")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Instance Methods
    
    /**
    Called when the invite button is tapped.
    */
    func inviteTapped() {
        AnalyticsController().track("Clicked invite driver button")

        invites = InviteSender(presentingViewController: self, delegate: self)
        
        if currentUser?.partner != nil {
            invites?.presentInvite(InviteType.Trusted)
        } else {
            let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let inviteSpouseAction = UIAlertAction(title: "Invite my spouse/partner", style: UIAlertActionStyle.Default) { [weak self] (action) -> Void in
                self?.invites?.presentInvite(InviteType.Household)
            }
            actionSheetController.addAction(inviteSpouseAction)
            
            let inviteDriver = UIAlertAction(title: "Invite a trusted driver", style: UIAlertActionStyle.Default) { [weak self] (action) -> Void in
                self?.invites?.presentInvite(InviteType.Trusted)
            }
            actionSheetController.addAction(inviteDriver)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            actionSheetController.addAction(cancelAction)
            
            presentViewController(actionSheetController, animated: true, completion: nil)
        }
    }
    
    // MARK: Private Methods
    
    /**
    Update the UI of the emptyStateView.
    */
    func configureEmptyStateView() {
        let style: EmptyStateStyle = inviteSent ? .DriversInviteSent : .Drivers
        emptyStateView.configureForStyle(style)
    }
    
    /**
     Fetch the drivers from the server and update the UI.
     */
    func updateDrivers() {
        loadingView.addToView(view)
        
        collectionView.alpha = 0.0
        
        drivers.getTrustedDrivers(includeCurrentUser: false) { [weak self] (drivers, error) -> Void in
            self?.loadingView.remove()
            if let unwrappedDrivers = drivers {
                self?.driversArray = unwrappedDrivers
            }
            
            self?.collectionView.reloadData()
            
            let emptyStateAlpha = ((self?.driversArray.count > 0) ? 0.0 : 1.0) as CGFloat
            let collectionViewAlpha = ((self?.driversArray.count > 0) ? 1.0 : 0.0) as CGFloat
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self?.emptyStateView.alpha = emptyStateAlpha
                self?.collectionView.alpha = collectionViewAlpha
            })
        }
    }
    
    // MARK: UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let personCellNib = UINib(nibName: "PersonCollectionViewCell", bundle: nil)
        collectionView.registerNib(personCellNib, forCellWithReuseIdentifier: PersonCollectionViewCell.reuseIdentifier)
        
        let inviteButton = UIBarButtonItem(title: "Invite", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(inviteTapped))
        navigationItem.rightBarButtonItem = inviteButton
        
        collectionView.backgroundColor = AppConfiguration.offWhite()
        
        configureEmptyStateView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Profiles.sharedInstance.getCurrentUserProfile() { [weak self] (currentUser, accountSetupComplete, error) -> Void in
            self?.currentUser = currentUser
        }
        
        updateDrivers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsController().screen("Drivers tab")
    }
}

// MARK: ApplicationDidBecomeActiveListener methods

extension DriversViewController: ApplicationDidBecomeActiveListener {
    func applicationDidBecomeActive() {
        updateDrivers()
    }
}

// MARK: ModalViewControllerDelegate methods

extension DriversViewController: ModalViewControllerDelegate {
    func modalViewControllerWillDismiss(viewController: ModalViewController) {
        updateDrivers()
    }
}

// MARK: UICollectionViewDelegate

extension DriversViewController: InviteSenderDelegate {
    func invitesFinished(success: Bool) {
        dLog("Invite sent")
        inviteSent = true
        configureEmptyStateView()
    }
}

// MARK: UICollectionViewDataSource Methods

extension DriversViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PersonCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! PersonCollectionViewCell

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return driversArray.count
    }
}

// MARK: UICollectionViewDelegate methods

extension DriversViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? PersonCollectionViewCell {
            let person = driversArray[indexPath.row]
            cell.configureForPerson(person)
            
            let tappedHandler: (PersonButton) -> Void = { [weak self] personButton in
                let profileViewController = ProfileModalViewController(aPerson: person)
                let modalViewController = ModalViewController(viewController: profileViewController)
                modalViewController.delegate = self
                if let rootVC = self?.tabBarController {
                    modalViewController.presentOverViewController(rootVC, sender: cell)
                }
            }
            cell.personButton.tappedCompletion = tappedHandler
        }
    }
}

// MARK: UserDidSignInListener methods

extension DriversViewController: UserDidSignInListener {
    func userDidSignIn() {
        updateDrivers()
    }
}
