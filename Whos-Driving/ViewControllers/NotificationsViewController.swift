import UIKit

/// Defines methods for responding to events in the NotificationsViewController.
protocol NotificationsViewControllerDelegate: class {
    
    /**
     Called when an event is updated.
     
     - parameter viewController The NotificationsViewController sending this method.
     - parameter event The event that was updated.
     */
    func notificationsViewController(viewController: NotificationsViewController, didUpdateEvent event: Event?)
}

/// View controller for selecting who to notify when an event is updated.
class NotificationsViewController: ModalBaseViewController {
    
    // MARK: Properties
    
    /// Delegate of this class.
    weak var delegate: NotificationsViewControllerDelegate?
    
    // MARK: Private properties
    
    /// Array of drivers who can be selected to be notified.
    private var drivers = [Person]()
    
    /// The event being updated.
    private var event: Event
    
    // MARK: IBOutlet Properties
    
    /// The collection view showing the list of possible drivers to send notifications to.
    @IBOutlet private weak var collectionView: UICollectionView!
    
    /// Divider line between the header view and the main content view.
    @IBOutlet private weak var dividerLine: UIView!
    
    /// Loading spinner shown when the drivers are being loaded from the server.
    @IBOutlet private weak var driversLoadingSpinner: UIActivityIndicatorView!
    
    /// Label shown if there aren't any valid drivers to send notifications to.
    @IBOutlet private weak var emptyStateLabel: UILabel!
    
    /// Container view below the header view.
    @IBOutlet private weak var lowerContainerView: UIView!
    
    /// Title label.
    @IBOutlet private weak var titleLabel: UILabel!
    
    /// Label above the collectionView.
    @IBOutlet private weak var whoToNotifyLabel: UILabel!
    
    // MARK: Init and deinit methods
    
    /**
    Creates a new instance of this class.
    
    - parameter event The event being updated to send notifications for.
    
    - returns: Configured instance of this class.
    */
    required init(event: Event) {
        self.event = event
        
        super.init(nibName: "NotificationsViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private methods
    
    /**
    Send notifications to the selected drivers.
    
    - parameter changesetNotice The array of changes made to the event. This is returned by the
                                server when updating the event and should not be manually created.
    */
    private func sendNotifications(changesetNotice changesetNotice: [String]) {
        var selectedDriverIds = [String]()
        let selectedDriversIndexPaths = collectionView.indexPathsForSelectedItems()!
        for indexPath in selectedDriversIndexPaths {
            let driver = drivers[indexPath.row]
            selectedDriverIds.append(driver.id)
        }
        
        if selectedDriverIds.count > 0 {
            EventNotifications().sendNotification(event.id, recipientIds: selectedDriverIds, changesetNotice: changesetNotice, completion: { (error) -> Void in
                
            })
        }
    }
    
    /**
     Sets driver to, driver from, and the parents of any riders to the list of drivers that can be
     notified, and preselects all of them.
     */
    private func setupDriversArray() {
        var driversToNotify = Set<Person>()
        
        // Add all the drivers and the parents of riders to a set
        if let driverFrom = event.driverFrom {
            driversToNotify.insert(driverFrom)
        }
        if let driverTo = event.driverTo {
            driversToNotify.insert(driverTo)
        }
        
        if let ridersFrom = event.ridersFrom {
            for rider in ridersFrom {
                driversToNotify = driversToNotify.union(rider.householdDrivers)
            }
        }
        
        if let ridersTo = event.ridersTo {
            for rider in ridersTo {
                driversToNotify = driversToNotify.union(rider.householdDrivers)
            }
        }
        
        // Remove the current user if present
        if let currentUser = Profiles.sharedInstance.currentUser {
            driversToNotify.remove(currentUser)
        }
        
        // Sort by last name
        let allDrivers = Array(driversToNotify)
        let sortedDrivers = allDrivers.sort { (person1, person2) -> Bool in
            return person1.lastName < person2.lastName
        }
        drivers = sortedDrivers
        collectionView.reloadData()
        
        if drivers.count > 0 {
            emptyStateLabel.hidden = true
            
            // Set all the drivers to be selected
            for (index, _) in drivers.enumerate() {
                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
            }
        } else {
            emptyStateLabel.hidden = false
        }
    }
    
    /**
     Update the event on the server.
     
     - parameter send True to send notifications to the selected drivers.
     */
    private func updateEvent(sendNotification send: Bool) {
        let uploadingVC = UploadingViewController()
        navigationController?.pushViewController(uploadingVC, animated: true)
        
        Events().updateEvent(event) { [weak self] (event, changesetNotice, error) -> Void in
            if error != nil {
                uploadingVC.presentError("Error saving event. Please try again.", completion: { () -> Void in
                    uploadingVC.popTwoViewControllers()
                })
            } else {
                if send {
                    self?.sendNotifications(changesetNotice: changesetNotice)
                }
                self?.delegate?.notificationsViewController(self!, didUpdateEvent: event)

                uploadingVC.dismiss()
            }
        }
    }

    // MARK: Actions
    
    /**
    Called when the save button is tapped.
    */
    @objc private func saveButtonTapped() {
        updateEvent(sendNotification: true)
    }
    
    // MARK: UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButton = UIBarButtonItem.barButtonForType(.Save, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
        
        dividerLine.backgroundColor = AppConfiguration.lightGray()
        lowerContainerView.backgroundColor = AppConfiguration.offWhite()
        titleLabel.textColor = AppConfiguration.black()
        whoToNotifyLabel.textColor = AppConfiguration.darkGray()
        emptyStateLabel.textColor = AppConfiguration.darkGray()
        
        let nib = UINib(nibName: "PersonCollectionViewCell", bundle: nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: PersonCollectionViewCell.reuseIdentifier)
        collectionView.allowsMultipleSelection = true
        
        setupDriversArray()
    }
}

// MARK: UICollectionViewDataSource methods

extension NotificationsViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PersonCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! PersonCollectionViewCell
        cell.personButton.userInteractionEnabled = false
        let person = drivers[indexPath.row]
        cell.configureForPerson(person)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drivers.count
    }
}
