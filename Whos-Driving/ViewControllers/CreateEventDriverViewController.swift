import UIKit

/**
 Represents the sections in the CreateEventDriverViewController's collection view.
 */
private enum CreateEventDriverCollectionViewSection: Int {
    /// This section has 1 cell, showing the "Not Sure" cell.
    case NotSureYet = 0
    /// This section contains all the possible drivers.
    case Drivers
}

/// View controller shown for selecting the drivers and riders for one of the legs of a carpool event.
/// The isDrivingTo property is set true or false to determine which leg of the event is being
/// created.
class CreateEventDriverViewController: UIViewController {
    
    // MARK: Properties
    
    /// The delegate of this class.
    var createEventDelegate: CreateEventDelegate?
    
    // MARK: Private properties
    
    /// Array of drivers that can be selected to drive.
    private var drivers = [Person]()
    
    /// The EventFactory passed between the different create event view controllers that has the
    /// values of the event being created.
    private let eventFactory: EventFactory
    
    /// True if this view controller is configuring the TO leg of the event. False if it's
    /// configuring the FROM leg.
    private let isDrivingTo: Bool
    
    /// The index path of the "not sure" cell.
    private let notSureIndexPath = NSIndexPath(forRow: 0, inSection: CreateEventDriverCollectionViewSection.NotSureYet.rawValue)
    
    /// Array of riders that can be selected to ride.
    private var riders = [Person]()
    
    // MARK: IBOutlets
    
    /// Container view for all the forms and table views.
    @IBOutlet private weak var contentView: UIView!
    
    /// Collection view showing all the drivers that can be selected to drive this leg.
    @IBOutlet private weak var driversCollectionView: UICollectionView!
    
    /// Loading spinner shown when the drivers are being loaded from the server.
    @IBOutlet private weak var driversLoadingSpinner: UIActivityIndicatorView!
    
    /// Label showing the details of what leg is being created.
    @IBOutlet private weak var headerDetailLabel: UILabel!
    
    /// Title label in the headerView.
    @IBOutlet private weak var headerTitleLabel: UILabel!
    
    /// View at the top of the view controller.
    @IBOutlet private weak var headerView: UIView!
    
    /// Label above the notesTextView.
    @IBOutlet private weak var notesLabel: UILabel!
    
    /// View for entering the notes for this leg of the carpool.
    @IBOutlet private weak var notesTextView: TextView!
    
    /// Collection view showing the riders that can be selected for this leg.
    @IBOutlet private weak var ridersCollectionView: UICollectionView!
    
    /// Loading spinner shown when the riders are being loaded from the server.
    @IBOutlet private weak var ridersLoadingSpinner: UIActivityIndicatorView!
    
    /// Scroll view containing all the views.
    @IBOutlet private weak var scrollView: UIScrollView!
    
    /// Label above the driversCollectionView.
    @IBOutlet private weak var whosDrivingLabel: UILabel!
    
    /// Label above the ridersCollectionView.
    @IBOutlet private weak var whosRidingLabel: UILabel!
    
    // MARK: Init and deinit methods
    
    /**
    Creates a new instance of this class with the provided properties.
    
    - parameter eventFactory EventFactory passed between the different create event view controllers.
    - parameter drivers Array of drivers that can be selected to drive.
    - parameter riders Array of riders that can be selected to ride.
    - parameter isDrivingTo True is this view should configure the TO leg, otherwise false for the 
                            FROM leg.
    
    - returns: Configured instance of this class.
    */
    required init(eventFactory: EventFactory, drivers: [Person], riders: [Person], isDrivingTo: Bool) {
        self.eventFactory = eventFactory
        self.isDrivingTo = isDrivingTo
        self.drivers = drivers
        self.riders = riders
        
        super.init(nibName: "CreateEventDriverViewController", bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private methods
    
    /**
    Called when the background is tapped.
    */
    @objc private func backgroundTapped() {
        notesTextView.resignFirstResponder()
    }
    
    /**
     Triggered by the UIKeyboardWillChangeFrameNotification.
     
     - parameter notification The notification that was triggered.
     */
    @objc private func keyboardWillChangeFrame(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardEndFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue {
                if let duration: NSTimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
                    UIView.animateWithDuration(duration, animations: { () -> Void in
                        self.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardEndFrame.height, 0.0)
                        let convertedFrame = self.scrollView.convertRect(self.notesTextView.frame, fromView: self.contentView)
                        self.scrollView.scrollRectToVisible(convertedFrame, animated: true)
                    })
                }
            }
        }
    }
    
    /**
     Triggered by the UIKeyboardWillHideNotification.
     
     - parameter notification The notification that was triggered.
     */
    @objc private func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let duration: NSTimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
                UIView.animateWithDuration(duration, animations: { () -> Void in
                    self.scrollView.contentInset = UIEdgeInsetsZero
                })
            }
        }
    }
    
    /**
     Called when the next button is tapped.
     */
    @objc private func nextTapped() {
        var selectedDriver: Person?
        if let selectedDriverIndexPath = driversCollectionView.indexPathsForSelectedItems()!.first {
            if selectedDriverIndexPath.section == CreateEventDriverCollectionViewSection.Drivers.rawValue {
                selectedDriver = drivers[selectedDriverIndexPath.row]
            }
        }
        
        var selectedRiders = [Person]()
        let selectedRidersIndexPaths = ridersCollectionView.indexPathsForSelectedItems()
        for indexPath in selectedRidersIndexPaths! {
            let rider = riders[indexPath.row]
            selectedRiders.append(rider)
        }

        if isDrivingTo {
            AnalyticsController().track("Completed driving to screen", context: .CreateCarpool, properties: nil)

            eventFactory.toNotes = notesTextView.text
            eventFactory.ridersTo = selectedRiders
            eventFactory.driverTo = selectedDriver
            
            let createEventDriverVC = CreateEventDriverViewController(eventFactory: eventFactory, drivers: drivers, riders: riders, isDrivingTo: false)
            createEventDriverVC.createEventDelegate = createEventDelegate
            navigationController?.pushViewController(createEventDriverVC, animated: true)
        } else {
            AnalyticsController().track("Completed driving from screen", context: .CreateCarpool, properties: nil)

            eventFactory.fromNotes = notesTextView.text
            eventFactory.ridersFrom = selectedRiders
            eventFactory.driverFrom = selectedDriver
            
            let createEventNotificationsVC = CreateEventNotificationsViewController(eventFactory: eventFactory)
            createEventNotificationsVC.createEventDelegate = createEventDelegate
            navigationController?.pushViewController(createEventNotificationsVC, animated: true)
        }
    }
    
    // MARK: UIViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if riders.count == 0 {
            ridersLoadingSpinner.startAnimating()
            Riders().getTrustedRiders(excludeHouseholdRiders: false, includeHouseholdDrivers: true) { [weak self] (riders, error) -> Void in
                self?.ridersLoadingSpinner.stopAnimating()
                
                self?.riders = riders
                self?.ridersCollectionView.reloadData()            }
        }
        
        // default to the "not sure yet" section.
        let notSureIndexPath = NSIndexPath(forItem: 0, inSection: CreateEventDriverCollectionViewSection.NotSureYet.rawValue)
        
        if drivers.count == 0 {
            driversLoadingSpinner.startAnimating()
            Profiles.sharedInstance.getCurrentUserAndPartner { [weak self] (userAndPartner, error) -> Void in
                self?.driversLoadingSpinner.stopAnimating()
                if let unwrappedUserAndPartner = userAndPartner {
                    self?.drivers = unwrappedUserAndPartner
                }
                self?.driversCollectionView.reloadData()
                self?.driversCollectionView.selectItemAtIndexPath(notSureIndexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.None)
            }
        } else {
            driversCollectionView.selectItemAtIndexPath(notSureIndexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.None)
        }
        
        headerView.backgroundColor = AppConfiguration.blue()
        view.backgroundColor = AppConfiguration.offWhite()
        contentView.backgroundColor = AppConfiguration.offWhite()
        
        let nib = UINib(nibName: "PersonCollectionViewCell", bundle: nil)
        driversCollectionView.registerNib(nib, forCellWithReuseIdentifier: PersonCollectionViewCell.reuseIdentifier)
        driversCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        ridersCollectionView.registerNib(nib, forCellWithReuseIdentifier: PersonCollectionViewCell.reuseIdentifier)
        ridersCollectionView.allowsMultipleSelection = true
        ridersCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        // For Driving From, automatically select riders that were selected in the previous step.
        for rider in eventFactory.ridersTo {
            if let index = riders.indexOf(rider) {
                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                ridersCollectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            }
        }

        title = NSLocalizedString("New carpool", comment: "Create new carpool view controller title")
        
        let nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(nextTapped))
        navigationItem.rightBarButtonItem = nextButton
        
        let backButton = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        let viewModel = CreateEventDriverViewControllerViewModel(eventFactory: eventFactory, isDrivingTo: isDrivingTo)
        headerTitleLabel.attributedText = viewModel.headerTitle()
        headerDetailLabel.text = viewModel.headerDetailText()
        whosDrivingLabel.attributedText = viewModel.whosDrivingText()
        whosRidingLabel.textColor = AppConfiguration.darkGray()
        notesLabel.textColor = AppConfiguration.darkGray()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        backgroundTapped()
    }
}

extension CreateEventDriverViewController : UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if collectionView == driversCollectionView {
            return 2
        } else {
            return 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PersonCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! PersonCollectionViewCell

        if collectionView == driversCollectionView && indexPath.section == CreateEventDriverCollectionViewSection.NotSureYet.rawValue {
            cell.configureForPersonButtonType(.NotSureYet)
        } else {
            let person: Person
            
            if collectionView == driversCollectionView {
                person = drivers[indexPath.row]
            } else {
                person = riders[indexPath.row]
            }
            
            cell.configureForPerson(person)
        }
        
        cell.personButton.userInteractionEnabled = false

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == driversCollectionView {
            switch section {
            case CreateEventDriverCollectionViewSection.NotSureYet.rawValue:
                // don't show anything in the "not sure yet" section until the drivers have loaded
                if drivers.count > 0 {
                    return 1
                } else {
                    return 0
                }
                
            case CreateEventDriverCollectionViewSection.Drivers.rawValue:
                return drivers.count
                
            default:
                return 0
            }
        } else {
            return riders.count
        }
    }
}

extension CreateEventDriverViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if collectionView == driversCollectionView {
            // this allows deselecting a cell in the drivers collection view
            
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PersonCollectionViewCell
            if cell.selected {
                collectionView.deselectItemAtIndexPath(indexPath, animated: false)
                collectionView.selectItemAtIndexPath(notSureIndexPath, animated: false, scrollPosition: .None)
                return false
            }
        }
        
        return true
    }
}

extension CreateEventDriverViewController : UIScrollViewDelegate {
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
