import UIKit

/// Protocol defining methods for being informed of events in the EditDrivingToFromViewController.
protocol EditDrivingToFromViewControllerDelegate: class {
    
    /**
     Called when an event is updated.
     
     - parameter viewController The EditDrivingToFromViewController sending this method.
     - parameter didUpdateEvent The event being updated.
     */
    func editDrivingViewController(viewController: EditDrivingToFromViewController, didUpdateEvent event: Event?)
}

/**
 Represents the sections in the EditDrivingToFromViewController's collection view.
 */
private enum EditDrivingCollectionViewSection: Int {
    /// This section has 1 cell, showing the "Not Sure" cell.
    case NotSureYet = 0
    /// This section contains all the possible drivers.
    case Drivers
}

/// This view controller is for editing either the TO or FROM leg of an carpool event.
class EditDrivingToFromViewController: ModalBaseViewController {

    // MARK: Properties
    
    /// True if the TO leg of the event is being edited.
    let drivingTo: Bool
    
    /// The delegate of this class.
    weak var editDrivingDelegate: EditDrivingToFromViewControllerDelegate?
    
    /// The event being edited.
    var event: Event

    // MARK: Private properties
    
    /// Array of drivers that can be selected as the driver of the event.
    private var drivers = [Person]()
    
    /// Index path of the "not sure" cell.
    private let notSureIndexPath = NSIndexPath(forRow: 0, inSection: EditDrivingCollectionViewSection.NotSureYet.rawValue)
    
    /// Array of riders that can be selected to ride in this event.
    private var riders = [Person]()
    
    /// View model for this class.
    private let viewModel: DetailsToFromViewModel
    
    // MARK: IBOutlets
    
    /// Background view for the lower portion of the view controller.
    @IBOutlet private weak var lowerBackground: UIView!
    
    /// Container view for the notesTextView.
    @IBOutlet private weak var notesContainer: UIView!
    
    /// Height constraint for the notesContainer.
    @IBOutlet private weak var notesContainerHeightConstraint: NSLayoutConstraint!
    
    /// Divider line separating the notesContainer from the view above it.
    @IBOutlet private weak var notesDividerView: UIView!
    
    /// View for entering the notes for this leg of the event.
    @IBOutlet private weak var notesTextView: TextView!
    
    /// Label above the notesTextView.
    @IBOutlet private weak var notesTitleLabel: UILabel!
    
    /// Container view for the titleLabel.
    @IBOutlet private weak var titleContainer: UIView!
    
    /// Title label.
    @IBOutlet private weak var titleLabel: UILabel!
    
    /// Background view for the upper portion of the view controller.
    @IBOutlet private weak var upperBackground: UIView!
    
    /// Collection view showing the people who can be selected to drive.
    @IBOutlet private weak var whosDrivingCollectionView: UICollectionView!
    
    /// Container view for the whos driving section.
    @IBOutlet private weak var whosDrivingContainer: UIView!
    
    /// Divider line for the whosDrivingContainer and the view above it.
    @IBOutlet private weak var whosDrivingDividerView: UIView!
    
    /// Loading spinner shown when the drivers are being loaded from the server.
    @IBOutlet private weak var whosDrivingLoadingSpinner: UIActivityIndicatorView!
    
    /// Title lable in the whosDrivingContainer.
    @IBOutlet private weak var whosDrivingTitleLabel: UILabel!
    
    /// Width constraint for the whosDrivingContainer.
    @IBOutlet private weak var whosDrivingWidthConstraint: NSLayoutConstraint!
    
    /// Collection view showing who can be selected to ride.
    @IBOutlet private weak var whosRidingCollectionView: UICollectionView!
    
    /// Container view for the who's riding views.
    @IBOutlet private weak var whosRidingContainer: UIView!
    
    /// Divider line between the whosRidingContainer and views above it.
    @IBOutlet private weak var whosRidingDividerView: UIView!
    
    /// Loading spinner shown when the riders are being loaded from the server.
    @IBOutlet private weak var whosRidingLoadingSpinner: UIActivityIndicatorView!
    
    /// Title label in the whosRidingContainer.
    @IBOutlet private weak var whosRidingTitleLabel: UILabel!
    
    // MARK: Init methods
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     Creates a new instance of this class with the provided properties.
     
     - parameter anEvent The event being edited.
     - parameter isDrivingTo True if the TO leg of the event is being edited, false for FROM.
     - parameter editDrivingDelegate The delegate of this class.
     
     - returns: Configured instance of this class.
     */
    required init(anEvent: Event, isDrivingTo: Bool, editDrivingDelegate: EditDrivingToFromViewControllerDelegate?) {
        self.editDrivingDelegate = editDrivingDelegate
        drivingTo = isDrivingTo
        event = anEvent
        viewModel = DetailsToFromViewModel(event: anEvent)
        super.init(nibName: "EditDrivingToFromViewController", bundle: nil)
        
        title = NSLocalizedString("Edit", comment: "The title of the edit driving to/from view controller.")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    
    /**
    Resigns the first responder of all views.
    */
    @objc private func dismissKeyboard() {
        notesTextView.resignFirstResponder()
    }
    
    /**
    Called when the cancel button is tapped.
    */
    @objc private func cancelButtonTapped() {
        baseDelegate?.dismissViewController(self)
    }
    
    /**
     Called when the next button is tapped.
     */
    @objc private func nextButtonTapped() {
        var selectedDriver: Person?
        if let selectedDriverIndexPath = whosDrivingCollectionView.indexPathsForSelectedItems()?.first {
            if selectedDriverIndexPath.section == EditDrivingCollectionViewSection.Drivers.rawValue {
                selectedDriver = drivers[selectedDriverIndexPath.row]
            }
        }
        
        var selectedRiders = [Person]()
        let selectedRidersIndexPaths = whosRidingCollectionView.indexPathsForSelectedItems()
        for indexPath in selectedRidersIndexPaths! {
            let rider = riders[indexPath.row]
            selectedRiders.append(rider)
        }
        
        if drivingTo {
            event.toNotes = notesTextView.text
            event.ridersTo = selectedRiders
            event.driverTo = selectedDriver
        } else {
            event.fromNotes = notesTextView.text
            event.ridersFrom = selectedRiders
            event.driverFrom = selectedDriver
        }
        
        let notifications = NotificationsViewController(event: event)
        notifications.delegate = self
        navigationController?.pushViewController(notifications, animated: true)
    }
    
    // MARK: UIViewController Methods
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        whosDrivingWidthConstraint.constant = view.frame.width
        
        // Add height to avoid a gap at the bottom of the view.
        let difference = view.frame.height - CGRectGetMaxY(notesContainer.frame)
        if difference > 0 {
            notesContainerHeightConstraint.constant += difference
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftButton = UIBarButtonItem.barButtonForType(.Cancel, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        
        let rightButton = UIBarButtonItem.barButtonForType(.Next, target: self, action: #selector(nextButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
        
        let nib = UINib(nibName: "PersonCollectionViewCell", bundle: nil)
        whosDrivingCollectionView.registerNib(nib, forCellWithReuseIdentifier: PersonCollectionViewCell.reuseIdentifier)
        whosDrivingCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 0)
        
        whosRidingCollectionView.registerNib(nib, forCellWithReuseIdentifier: PersonCollectionViewCell.reuseIdentifier)
        whosRidingCollectionView.allowsMultipleSelection = true
        whosRidingCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 0)
        
        let containerBackgroundColor = AppConfiguration.offWhite()
        let dividerColor = AppConfiguration.lightGray()
        let subheadingTextColor = AppConfiguration.darkGray()
        
        notesContainer.backgroundColor = containerBackgroundColor
        notesDividerView.backgroundColor = dividerColor
        notesTitleLabel.textColor = subheadingTextColor
        
        titleContainer.backgroundColor = AppConfiguration.white()
        titleLabel.attributedText = viewModel.attributedTitleString(drivingTo)
        titleLabel.textColor = AppConfiguration.black()
        
        whosDrivingContainer.backgroundColor = containerBackgroundColor
        whosDrivingDividerView.backgroundColor = dividerColor
        whosDrivingTitleLabel.textColor = subheadingTextColor
        
        whosRidingContainer.backgroundColor = containerBackgroundColor
        whosRidingDividerView.backgroundColor = dividerColor
        whosRidingTitleLabel.textColor = subheadingTextColor
        
        lowerBackground.backgroundColor = containerBackgroundColor
        upperBackground.backgroundColor = titleContainer.backgroundColor
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
        
        // Setup selectable riders
        if let selectableRiders = drivingTo ? event.selectableRidersTo : event.selectableRidersFrom {
            riders = selectableRiders
            whosRidingCollectionView.reloadData()
        }
        
        if let currentRiders = drivingTo ? event.ridersTo : event.ridersFrom {
            for rider in currentRiders {
                if let index = riders.indexOf(rider) {
                    let indexPath = NSIndexPath(forItem: index, inSection: 0)
                    whosRidingCollectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
                }
            }
        }
        
        // Setup selectable drivers
        var indexPath = NSIndexPath(forItem: 0, inSection: EditDrivingCollectionViewSection.NotSureYet.rawValue)
        
        if let selectableDrivers = drivingTo ? event.selectableDriversTo : event.selectableDriversFrom {
            drivers = selectableDrivers
            whosDrivingCollectionView.reloadData()
            
            if let currentDriver = drivingTo ? event.driverTo : event.driverFrom {
                if let index = drivers.indexOf(currentDriver) {
                    indexPath = NSIndexPath(forItem: index, inSection: EditDrivingCollectionViewSection.Drivers.rawValue)
                }
            }
        }
        
        whosDrivingCollectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
        
        // Fill in the event notes
        if let notes = drivingTo ? event.toNotes : event.fromNotes {
            notesTextView.text = notes
            notesTextView.textDidChange()
        }
    }
}

extension EditDrivingToFromViewController : UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if collectionView == whosDrivingCollectionView {
            return 2
        } else {
            return 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PersonCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! PersonCollectionViewCell
        cell.personButton.userInteractionEnabled = false

        if collectionView == whosDrivingCollectionView && indexPath.section == EditDrivingCollectionViewSection.NotSureYet.rawValue {
            cell.configureForPersonButtonType(.NotSureYet)
        } else {
            let person: Person
            if collectionView == whosDrivingCollectionView {
                person = drivers[indexPath.row]
            } else {
                person = riders[indexPath.row]
            }
            
            // Do this here instead of configureForPerson, since this is specific to this collection.
            let driverResponse = drivingTo ? person.driverResponseTo : person.driverResponseFrom
            if driverResponse == .Cannot && person.relationship != .CurrentUser {
                cell.userInteractionEnabled = false
            } else {
                cell.userInteractionEnabled = true
            }
            
            if driverResponse == .Cannot {
                cell.configureForPerson(person, style: .CannotDrive)
            } else {
                cell.configureForPerson(person)
            }
        }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == whosDrivingCollectionView {
            switch section {
            case EditDrivingCollectionViewSection.NotSureYet.rawValue:
                // don't show anything in the "not sure yet" section until the drivers have loaded
                if drivers.count > 0 {
                    return 1
                } else {
                    return 0
                }
                
            case EditDrivingCollectionViewSection.Drivers.rawValue:
                return drivers.count
                
            default:
                return 0
            }
        } else {
            return riders.count
        }
    }
}

extension EditDrivingToFromViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if collectionView == whosDrivingCollectionView {
            let selectedIndexPaths = collectionView.indexPathsForSelectedItems() ?? []
            let isCurrentlySelected = selectedIndexPaths.contains(indexPath)

            if isCurrentlySelected {
                collectionView.deselectItemAtIndexPath(indexPath, animated: false)
                collectionView.selectItemAtIndexPath(notSureIndexPath, animated: false, scrollPosition: .None)
                return false
            }
        }

        return true
    }
}

extension EditDrivingToFromViewController : NotificationsViewControllerDelegate {
    func notificationsViewController(viewController: NotificationsViewController, didUpdateEvent event: Event?) {
        editDrivingDelegate?.editDrivingViewController(self, didUpdateEvent: event)
    }
}
