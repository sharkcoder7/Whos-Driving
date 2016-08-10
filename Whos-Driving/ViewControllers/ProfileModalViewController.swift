import UIKit

/// Defines methods for responding to events in the ProfileModalViewController.
protocol ProfileModalViewControllerDelegate: class {
    
    /**
     Called when a trusted driver is deleted.
     
     - parameter driver The trusted driver that was removed.
     */
    func trustedDriverWasDeleted(driver: Person)
}

/// Profile view controller to show in a focus frame.
class ProfileModalViewController: ModalBaseViewController {
    
    // MARK: Public Properties

    /// Listener to be informed in the person is removed as a trusted driver.
    weak var trustedDriverListener: TrustedDriverListener?

    // MARK: Private Properties
    
    /**
    The data source for the collection view. Either household riders or drivers depending on the
    person being displayed.
    */
    private var dataSource: [Person] {
        get {
            return person.licensedDriver ? person.householdRiders : person.householdDrivers
        }
    }
    
    /**
    Controller for sending invites to trusted drivers.
    */
    private var invites: InviteSender?
    
    /**
    The person represented in this profile view controller.
    */
    private var person: Person
    
    /**
    The view model for this object.
    */
    private var viewModel: ProfileModalViewControllerViewModel
    
    // MARK: IBOutlets
    
    /// Button configured (or hidden) depending on the relationship between the current user and
    /// the user being shown in the ProfileModalViewController. For example, shows an action to 
    /// remove a trusted driver if you're currently a trusted driver with the persn.
    @IBOutlet private weak var actionButton: UIButton!
    
    /// Label showing the address of the person.
    @IBOutlet private weak var addressLabel: UILabel!
    
    /// Label above the collectionView.
    @IBOutlet private weak var associatedLabel: UILabel!
    
    /// Label giving further details of what happens if the actionButton is pressed.
    @IBOutlet private weak var bottomDetailLabel: UILabel!
    
    /// Collection view showing the user's household drivers or riders.
    @IBOutlet private weak var collectionView: UICollectionView!
    
    /// Container view for the action buttons and labels.
    @IBOutlet private weak var driverActionContainerView: UIView!
    
    /// Layout constraint to adjust if the driverActionContainerView should be hidden.
    @IBOutlet private weak var driverActionHiddenLayoutConstraint: NSLayoutConstraint!
    
    /// PersonButton representing the person in this profile view.
    @IBOutlet private weak var driverView: PersonButton!
    
    /// Loading spinner shown while the user's household drivers or riders are loaded.
    @IBOutlet private weak var loadingSpinner: UIActivityIndicatorView!
    
    /// Label showing the relationship between the current user and the person.
    @IBOutlet private weak var relationshipLabel: UILabel!
    
    /// Label giving a detailed description of what happens if the actionButton is pressed.
    @IBOutlet private weak var topDetailLabel: UILabel!

    // MARK: Init and dealloc methods
    
    /**
    Initializes an instance of this class with the provided Person object.
    
    - parameter aPerson The person represented by this profile view controller.
    
    - returns: New instance of this class.
    */
    required init(aPerson: Person) {
        person = aPerson
        viewModel = ProfileModalViewControllerViewModel(aPerson: aPerson)
        
        super.init(nibName: "ProfileModalViewController", bundle: nil)
        
        title = person.firstName
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private Methods
    
    /**
    Removes the person as a trusted driver or household driver. If successful, the view is dismissed.
    */
    private func deleteTrustedDriver() {
        Drivers().deleteTrustedDriver(person.id, completion: { [weak self] (error) -> Void in
            if error != nil {
                dLog("Error deleting driver: \(error)")
                let alert = defaultAlertController("There was an error removing the driver.")
                self?.presentViewController(alert, animated: true, completion: nil)
            } else {
                self?.trustedDriverListener?.trustedDriverWasDeleted(self!.person)
                self?.baseDelegate?.dismissViewController(self!)
            }
        })
    }
    
    /**
    Updates the views with the correct attributes of the Person.
    */
    private func populateViews() {
        driverView.populateViewForPerson(person)
        
        addressLabel.text = viewModel.textForAddressLabel()
        associatedLabel.text = viewModel.textForAssociatedLabel()
        relationshipLabel.text = viewModel.textForRelationshipLabel()
        topDetailLabel.text = viewModel.textForTopDetailLabel()
        bottomDetailLabel.text = viewModel.textForBottomDetailLabel()
        actionButton.setTitle(viewModel.textForActionButton(), forState: UIControlState.Normal)
        actionButton.backgroundColor = viewModel.backgroundColorForActionButton()
        
        if person.relationship == Relationship.CurrentUser || person.licensedDriver == false {
            driverActionContainerView.hidden = true
            driverActionHiddenLayoutConstraint.active = true
        } else {
            driverActionContainerView.hidden = false
            driverActionHiddenLayoutConstraint.active = false
        }
        
        if dataSource.count > 0 {
            collectionView.alpha = 1.0
            associatedLabel.alpha = 1.0
        } else {
            collectionView.alpha = 0.0
            associatedLabel.alpha = 0.0
        }
    }
    
    /**
     Gets the most recent version of the user and updates the UI.
     */
    private func updateUser() {
        loadingSpinner.startAnimating()

        Users().getUser(person.id) { [weak self] (user, error) -> Void in
            self?.loadingSpinner.stopAnimating()
            
            if let person = user {
                self?.person = person
                self?.viewModel = ProfileModalViewControllerViewModel(aPerson: person)
                self?.populateViews()
                self?.collectionView.reloadData()
            }
        }
    }
    
    // MARK: Actions
    
    /**
    Called when the actionButton is tapped.
    
    - parameter sender The button that was tapped.
    */
    @IBAction func actionButtonTapped(sender: UIButton) {
        let alertController: UIAlertController
        
        switch person.relationship {
        case .None:
            invites = InviteSender(presentingViewController: self, delegate: self)
            invites!.presentInvite(InviteType.Trusted)
            
        case .CurrentUser:
            fatalError("This case shouldn't happen. Button should be hidden")
            
        case .Household:
            alertController = UIAlertController(title: "Warning", message: "Removing spouse/partner will permanently delete your shared kids and remove those kids from all carpools. You will need to add your kids back to this app manually. The spouse/partner you are removing will no longer be on your trusted driver list.", preferredStyle: UIAlertControllerStyle.Alert)
            let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { [weak self] (confirmAction) -> Void in
                self?.deleteTrustedDriver()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
            
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
            
            presentViewController(alertController, animated: true, completion: nil)

        case .Trusted:
            alertController = UIAlertController(title: "Confirm removal", message: "You will be removed from \(person.firstName)'s list of drivers, and \(person.firstName) will be removed from your list of drivers.", preferredStyle: UIAlertControllerStyle.Alert)
            let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { [weak self] (confirmAction) -> Void in
                self?.deleteTrustedDriver()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
            
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    /**
     Called when the close button is tapped.
     */
    @objc private func closeButtonTapped() {
        baseDelegate?.dismissViewController(self)
    }
    
    /**
     Called when the edit button is tapped.
     */
    @objc private func editButtonTapped() {
        if person.licensedDriver == false {
            let editRiderVC = EditRiderViewController(rider: person)
            editRiderVC.delegate = self
            
            navigationController?.pushViewController(editRiderVC, animated: true)
        }
    }
    
    // MARK: UIViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionButton.layer.cornerRadius = 3.0
        driverView.firstLetterLabel.font = UIFont(name: Font.HelveticaNeueRegular, size: 28)
        let nib = UINib(nibName: "PersonCollectionViewCell", bundle: nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: PersonCollectionViewCell.reuseIdentifier)
        
        populateViews()
        
        if isRootViewController {
            let leftButton = UIBarButtonItem.barButtonForType(.Close, target: self, action: #selector(closeButtonTapped))
            navigationItem.leftBarButtonItem = leftButton
        }
        
        // can edit your own profile and your kid's profiles
        let canEdit = (person.licensedDriver == false && person.relationship == Relationship.Household)
        if canEdit {
            let rightButton = UIBarButtonItem.barButtonForType(.Edit, target: self, action: #selector(editButtonTapped))
            navigationItem.rightBarButtonItem = rightButton
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUser()
    }
}

// MARK: EditRiderViewControllerDelegate methods

extension ProfileModalViewController: EditRiderViewControllerDelegate {
    func editRiderViewControllerDidDeleteRider(viewController: EditRiderViewController, uploadingViewController: UploadingViewController, rider: Person) {
        if isRootViewController {
            uploadingViewController.dismiss()
        } else {
            uploadingViewController.popToRootViewController()
        }
    }
    
    func editRiderViewControllerDidEditRider(viewController: EditRiderViewController, rider: Person) {
        updateUser()
    }
}

// MARK: InvitesDelegate methods

extension ProfileModalViewController: InviteSenderDelegate {
    func invitesFinished(success: Bool) {
        dLog("Invite finished. Success: \(success)")
    }
}

// MARK: UICollectionViewDataSource methods

extension ProfileModalViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PersonCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! PersonCollectionViewCell
        let rider = dataSource[indexPath.row]
        cell.configureForPerson(rider)
        
        if isRootViewController {
            let tappedHandler: (PersonButton) -> Void = { [weak self] personButton in
                let profileVC = ProfileModalViewController(aPerson: rider)
                self?.navigationController?.pushViewController(profileVC, animated: true)
            }
            cell.personButton.tappedCompletion = tappedHandler
        } else {
            let tappedHandler: (PersonButton) -> Void = { personButton in
                // empty. can't continue drilling into profiles past 2nd view.
            }
            cell.personButton.tappedCompletion = tappedHandler        }

        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
}
