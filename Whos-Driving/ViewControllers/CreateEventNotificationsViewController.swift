import UIKit

/// View controller for selecting show should be notified when this new event is created.
class CreateEventNotificationsViewController: UIViewController {

    // MARK: Properties
    
    /// The delegate of this class.
    var createEventDelegate: CreateEventDelegate?
    
    // MARK: Private properties
    
    /// Array of drivers that are valid to be notified when this event is created.
    private var drivers = [Person]()
    
    /// The EventFactory with the properties of the event being created.
    private let eventFactory: EventFactory
    
    // MARK: IBOutlets
    
    /// The content view below the headerView.
    @IBOutlet private weak var contentView: UIView!
    
    /// Collection view showing the drivers that can be selected to be notified.
    @IBOutlet private weak var driversCollectionView: UICollectionView!
    
    /// Loading spinner shown when the drivers are being fetched from the server.
    @IBOutlet private weak var driversLoadingSpinner: UIActivityIndicatorView!
    
    /// Label shown when there aren't any valid drivers to show to notify of this event.
    @IBOutlet private weak var emptyStateLabel: UILabel!
    
    /// View at the top of the view controller.
    @IBOutlet private weak var headerView: UIView!
    
    /// Label above the speech bubble views.
    @IBOutlet private weak var messageWillSayLabel: UILabel!
    
    /// Scroll view containing all the views.
    @IBOutlet private weak var scrollView: UIScrollView!
    
    /// Background view for the speechBubbleLabel. Rounded to look like a speech bubble.
    @IBOutlet private weak var speechBubbleBackground: UIView!
    
    /// The label showing a preview of what the notification will look like when sent to other users.
    @IBOutlet private weak var speechBubbleLabel: UILabel!
    
    /// Image in the lower left corner that has the image for the speech bubble tail.
    @IBOutlet private weak var speechBubbleTail: UIImageView!
    
    /// Label above the driversCollectionView.
    @IBOutlet private weak var whosDrivingLabel: UILabel!
    
    // MARK: Init and deinit methods
    
    /**
    Creates a new instance of this class.
    
    - parameter eventFactory The EventFactory containing the properties of the carpool event being
                             created.
    
    - returns: Configured instance of this class.
    */
    required init(eventFactory: EventFactory) {
        self.eventFactory = eventFactory
        
        super.init(nibName: "CreateEventNotificationsViewController", bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private methods
    
    /**
    Called when the save button is tapped.
    */
    @objc private func saveTapped() {
        var selectedDriverIds = [String]()
        let selectedDriversIndexPaths = driversCollectionView.indexPathsForSelectedItems()!
        for indexPath in selectedDriversIndexPaths {
            let driver = drivers[indexPath.row]
            selectedDriverIds.append(driver.id)
        }
        eventFactory.notificationIds = selectedDriverIds

        func continueAndCreateEvent() {
            let properties: [NSObject : AnyObject] = [
                AnalyticsController.DriverToKey : eventFactory.driverTo != nil,
                AnalyticsController.DriverFromKey : eventFactory.driverFrom != nil,
                AnalyticsController.RidersToCountKey : eventFactory.ridersTo.count,
                AnalyticsController.RidersFromCountKey : eventFactory.ridersFrom.count,
                AnalyticsController.NotificationsCountKey : selectedDriverIds.count,
            ]
            AnalyticsController().track("Completed notification screen", context: .CreateCarpool, properties: properties)
            
            createEventDelegate?.didCreateEventFactory(eventFactory)
            navigationController?.popToRootViewControllerAnimated(true)
        }

        let noDriversSelectedToNotify = selectedDriverIds.count == 0
        let atLeastOneDriverNeeded = eventFactory.driverFrom == nil || eventFactory.driverTo == nil

        if noDriversSelectedToNotify && atLeastOneDriverNeeded {
            let message = "You have chosen to create a carpool in need of a driver, but you have not selected anyone to be notified asking them to drive. Continue?"
            let alertController = UIAlertController(title: "Warning", message: message, preferredStyle: .Alert)
            let cancelButton = UIAlertAction(title: "Go back and edit", style: .Cancel) { _ in }

            let continueButton = UIAlertAction(title: "OK", style: .Default) { _ in
                continueAndCreateEvent()
            }

            alertController.addAction(cancelButton)
            alertController.addAction(continueButton)
            presentViewController(alertController, animated: true) {}
        } else {
            continueAndCreateEvent()
        }
    }
    
    /**
     Sets driver to, driver from, and the parents of any riders to the list of drivers that can be
     notified, and preselects all of them.
     */
    private func setupDriversArray() {
        var driversToNotify = Set<Person>()
        
        // Add all the drivers and the parents of riders to a set
        if let driverFrom = eventFactory.driverFrom {
            driversToNotify.insert(driverFrom)
        }
        if let driverTo = eventFactory.driverTo {
            driversToNotify.insert(driverTo)
        }
        
        let ridersFrom = eventFactory.ridersFrom
        for rider in ridersFrom {
            driversToNotify = driversToNotify.union(rider.householdDrivers)
        }
        
        let ridersTo = eventFactory.ridersTo
        for rider in ridersTo {
            driversToNotify = driversToNotify.union(rider.householdDrivers)
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
        driversCollectionView.reloadData()
        
        if drivers.count > 0 {
            emptyStateLabel.hidden = true
            speechBubbleBackground.hidden = false
            speechBubbleTail.hidden = false
            messageWillSayLabel.hidden = false
            
            // Set all the drivers to be selected
            for (index, _) in drivers.enumerate() {
                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                driversCollectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
            }
        } else {
            emptyStateLabel.hidden = false
            speechBubbleBackground.hidden = true
            speechBubbleTail.hidden = true
            messageWillSayLabel.hidden = true
        }
    }
    
    // MARK: UIViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.backgroundColor = AppConfiguration.blue()
        view.backgroundColor = AppConfiguration.offWhite()
        contentView.backgroundColor = AppConfiguration.offWhite()
        
        let nib = UINib(nibName: "PersonCollectionViewCell", bundle: nil)
        driversCollectionView.registerNib(nib, forCellWithReuseIdentifier: PersonCollectionViewCell.reuseIdentifier)
        driversCollectionView.allowsMultipleSelection = true
        
        title = NSLocalizedString("New carpool", comment: "Create new carpool view controller title")
        
        let saveButton = UIBarButtonItem(title: "Create", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem = saveButton
        
        let backButton = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        whosDrivingLabel.textColor = AppConfiguration.darkGray()
        messageWillSayLabel.textColor = AppConfiguration.darkGray()
        emptyStateLabel.textColor = AppConfiguration.darkGray()
        speechBubbleBackground.layer.cornerRadius = 13.0
        
        let viewModel = CreateEventNotificationViewControllerViewModel(eventFactory: eventFactory)
        speechBubbleLabel.text = viewModel.speechBubbleText()
        
        setupDriversArray()
    }
}

// MARK: UICollectionViewDataSource methods

extension CreateEventNotificationsViewController : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let person: Person = drivers[indexPath.row]
    
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PersonCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! PersonCollectionViewCell
        cell.configureForPerson(person)
        cell.personButton.userInteractionEnabled = false

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drivers.count
    }
}

// MARK: UIScrollViewDelegate methods

extension CreateEventNotificationsViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            // change the background colors so the background blends when the scroll view is bounced.
            let buffer: CGFloat = 10.0
            let offset = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let viewHeight = scrollView.frame.size.height
            
            if offset < buffer {
                view.backgroundColor = AppConfiguration.blue()
            } else if (offset + viewHeight) > (contentHeight - buffer) {
                view.backgroundColor = AppConfiguration.offWhite()
            }
        }
    }
}
