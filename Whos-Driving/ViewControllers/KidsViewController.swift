import UIKit

/// View controller with tabs for viewing the current user's kids, and trusted driver's kids.
class KidsViewController: UIViewController {
    
    // MARK: Private Properties
    
    /// Button for adding a new kid.
    private var addButton: UIBarButtonItem?
    
    /// View shown when loading from the server.
    private var loadingView = LoadingView()
    
    /// Riders controller.
    private let riders = Riders()
    
    /// Array of riders to display in the collectionView.
    private var ridersArray: Array<Person>
    
    // MARK: IBOutlets

    /// The collection view showing the riders.
    @IBOutlet private weak var collectionView: UICollectionView!
    
    /// Empty state view when there are no riders to show.
    @IBOutlet private var emptyStateView: EmptyStateView!
    
    /// Segmented control for toggling between "my kids" and "other kids".
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    // MARK: Init Methods
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        ridersArray = []
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        title = NSLocalizedString("Kids", comment: "Kids tab title.")
        tabBarItem.image = UIImage(named: "tab-kids")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    
    /**
    Called when the add button is tapped.
    
    - parameter sender The button that was tapped.
    */
    @objc private func addTapped(sender: UIBarButtonItem) {
        if let tabBarController = tabBarController {
            AnalyticsController().track("Clicked add kid button")
            
            let addKidsViewController = AddKidViewController()
            addKidsViewController.addKidDelegate = self
            let modalViewController = ModalViewController(viewController: addKidsViewController)
            modalViewController.presentOverViewController(tabBarController, sender: view)
        }
    }
    
    /**
    Called when the segment changes on the segmentedControl.
    
    - parameter sender The UISegmentedControl that changes.
    */
    @IBAction func segmentedSelected(sender: UISegmentedControl) {
        loadRiders()
    }
    
    // MARK: Private Methods
    
    /**
    Loads the riders from the server and updates the UI.
    */
    private func loadRiders() {
        loadingView.addToView(view)
        
        collectionView.alpha = 0.0
        emptyStateView.alpha = 0.0
        
        if segmentedControl.selectedSegmentIndex == 0 {
            // My Kids selected
            addButton?.enabled = true
            emptyStateView.configureForStyle(.MyKids)

            riders.getHouseholdRiders({ [weak self] (riders, error) -> Void in
                self?.loadingView.remove()
                self?.ridersArray = riders
                self?.collectionView.reloadData()
                
                self?.emptyStateView.alpha = riders.count > 0 ? 0.0 : 1.0
                self?.collectionView.alpha = riders.count > 0 ? 1.0 : 0.0
            })
        } else {
            // Others' Kids selected
            addButton?.enabled = false
            emptyStateView.configureForStyle(.OtherKids)

            riders.getTrustedRiders(excludeHouseholdRiders: true, includeHouseholdDrivers: false, completion: { [weak self] (riders, error) -> Void in
                self?.loadingView.remove()
                self?.ridersArray = riders
                self?.collectionView.reloadData()
                
                self?.emptyStateView.alpha = riders.count > 0 ? 0.0 : 1.0
                self?.collectionView.alpha = riders.count > 0 ? 1.0 : 0.0
            })
        }
    }
    
    // MARK: UIViewController Methods
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadRiders()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppConfiguration.offWhite()
        
        segmentedControl.tintColor = AppConfiguration.blue()
        
        let personCellNib = UINib(nibName: "PersonCollectionViewCell", bundle: NSBundle.mainBundle())
        collectionView.registerNib(personCellNib, forCellWithReuseIdentifier: PersonCollectionViewCell.reuseIdentifier)
        
        addButton = UIBarButtonItem.barButtonForType(.Add, target: self, action: #selector(addTapped(_:)))
        navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsController().screen("Kids tab")
    }
}

// MARK: AddKidViewControllerDelegate Methods

extension KidsViewController : AddKidViewControllerDelegate {
    func addedPerson(addKidViewController: AddKidViewController, addedPerson: Person) {
        loadRiders()
    }
}

// MARK: ApplicationDidBecomeActiveListener methods

extension KidsViewController: ApplicationDidBecomeActiveListener {
    func applicationDidBecomeActive() {
        loadRiders()
    }
}

// MARK: ModalViewControllerDelegate methods

extension KidsViewController: ModalViewControllerDelegate {
    func modalViewControllerWillDismiss(viewController: ModalViewController) {
        loadRiders()
    }
}

// MARK: UICollectionViewDataSource Methods

extension KidsViewController : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PersonCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! PersonCollectionViewCell
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ridersArray.count
    }
}

// MARK: UICollectionViewDelegate methods

extension KidsViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? PersonCollectionViewCell {
            let person = ridersArray[indexPath.row]
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

extension KidsViewController: UserDidSignInListener {
    func userDidSignIn() {
        loadRiders()
    }
}
