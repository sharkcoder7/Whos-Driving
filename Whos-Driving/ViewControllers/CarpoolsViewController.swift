import UIKit

/// Shows the list of carpool events for the current user. Has tabs for seeing present events or
/// past events.
class CarpoolsViewController: UIViewController {

    // MARK: Private Properties
    
    /// Button for adding a new carpool.
    private var addCarpoolButton: UIBarButtonItem!
    
    /// The data source powering the table views.
    private var dataSource: EventsDataSource
    
    /// View shown when data is being loaded from the server.
    private var loadingView = LoadingView()
    
    /// After an event is created it is sent back to this view controller to upload to the server.
    /// This is the EventFactory used to create that event and can be re-uploaded if the communication
    /// with the server fails.
    private var pendingEventFactory: EventFactory?
    
    // MARK: IBOutlets
    
    /// Empty state view shown when there aren't events to show.
    @IBOutlet private weak var emptyStateView: EmptyStateView!
    
    /// Label shown when the user is looking at the "past" tab but doesn't have any past events.
    @IBOutlet private weak var pastEventsEmptyStateLabel: UILabel!
    
    /// Container view for the segmentedControler.
    @IBOutlet private weak var segmentedControlContainerView: UIView!
    
    /// Segmented control for toggling to view past or present carpool events.
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    /// Table view showing the list of events.
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: Init Methods
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        dataSource = EventsDataSource(events: [Event]())
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        title = NSLocalizedString("Carpools", comment: "Carpools tab title.")
        tabBarItem.image = UIImage(named: "tab-car")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: IBAction Methods
    
    /**
    Called when the segmentedControl changes segments.
    
    - parameter sender The UISegmentedControl that was changed.
    */
    @IBAction func segmentedSelected(sender: UISegmentedControl) {
        addCarpoolButton.enabled = false

        updateEvents()
    }

    // MARK: Instance Methods
    
    /**
    Called when the addButton is tapped.
    
    - parameter sender The button that was tapped.
    */
    func addButtonTapped(sender: UIBarButtonItem) {
        let createEventViewController = CreateEventViewController(nibName: "CreateEventViewController", bundle: nil)
        AnalyticsController().track("Clicked create carpool")

        createEventViewController.createEventDelegate = self
        createEventViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(createEventViewController, animated: true)
    }

    /**
     Handles a remote notification by loading the event associated with the provided eventId and
     displaying the detail view for it.
     
     - parameter eventId The eventId that a remote notification was sent for.
     */
    func handleRemoteNotificationForEvent(eventId: String) {
        Events().getEventById(eventId, noUserView: true) { [weak self] (event, error) -> Void in
            dLog("Event id: \(event?.id) Error: \(error)")
            
            if let event = event {
                var showResponseView = true
                let currentUserId = Profiles.sharedInstance.currentUserId

                if currentUserId != nil && currentUserId == event.ownerId {
                    // Don't show the response view if this user created the event.
                    showResponseView = false
                }

                let detailVC = CarpoolDetailsViewController(event: event, showResponseView: showResponseView)
                self?.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
    
    // MARK: Private Methods
    
    /**
    To fix a bug with the headers when drilling into the navigation stack and coming back to this view,
    this is called to reset the header views to the proper position.
    */
    private func adjustHeaderPosition() {
        if tableView.contentOffset.y != 0 {
            scrollViewDidScroll(tableView)
        }
    }
    
    /**
     Create a new carpool event and upload it to the server using the provided EventFactory.
     
     - parameter factory The EventFactory used to create a new carpool event.
     */
    private func createEventWithFactory(factory: EventFactory) {
        setUploadingState(.Uploading)

        let params = factory.eventDictionary()
        
        Events().createEvent(params, completion: { [weak self] (newEvent, error) -> Void in
            if error == nil {
                self?.updateEvents()
                self?.pendingEventFactory = nil
                self?.setUploadingState(.Success)
                let dispatchTime = dispatchTimeSinceNow(2.0)
                dispatch_after(dispatchTime, dispatch_get_main_queue(), { () -> Void in
                    self?.hideUploadingView()
                })
            } else {
                self?.pendingEventFactory = factory
                self?.setUploadingState(.Failed)
            }
        })
    }
    
    /**
     Hide the uploading view.
     */
    private func hideUploadingView() {
        UIView.animateWithDuration(0.3) { () -> Void in
            self.tableView.tableHeaderView = nil
        }
    }
    
    /**
     Setup the empty state view.
     */
    private func setupEmptyStateView() {
        let animationDuration = 0.25
        
        if segmentedControl.selectedSegmentIndex == 0 {
            Drivers().getTrustedDrivers(includeCurrentUser: false) { [weak self] (drivers, error) -> Void in
                let count = drivers?.count
                
                let emptyStateStyle = count > 0 ? EmptyStateStyle.CarpoolsDone : EmptyStateStyle.CarpoolsAlmostDone
                self?.emptyStateView.configureForStyle(emptyStateStyle)
                self?.addCarpoolButton.enabled = emptyStateStyle == .CarpoolsDone
                
                UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                    self?.emptyStateView.alpha = 1.0
                    self?.pastEventsEmptyStateLabel.alpha = 0.0
                })
            }
        } else {
            // show different empty state for "past" events
            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                self.emptyStateView.alpha = 0.0
                self.pastEventsEmptyStateLabel.alpha = 1.0
            })
        }
    }
    
    /**
     Updated the UploadingState of the UploadingView, or if the UploadingView isn't being shown,
     show it.
     
     - parameter state The UploadingState to set on the UploadingView.
     */
    private func setUploadingState(state: UploadingState) {
        if let uploadingView = tableView.tableHeaderView as? UploadingView {
            uploadingView.uploadingState = state
        } else {
            showUploadingView(state)
        }
    }
    
    /**
     Show the UploadingView.
     
     - parameter state The UploadingState to set on the UploadingView.
     */
    private func showUploadingView(state: UploadingState = .Uploading) {
        let uploadingView = UploadingView(frame: CGRectMake(0, 0, tableView.frame.size.width, 44.0))
        uploadingView.uploadingState = state
        uploadingView.delegate = self
        tableView.tableHeaderView = uploadingView
        
        tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    /**
     Fetch events from the server and update the UI.
     */
    private func updateEvents() {
        loadingView.addToView(view)

        let eventScope: EventScope

        if segmentedControl.selectedSegmentIndex == 0 {
            eventScope = .Upcoming
        } else {
            eventScope = .Past
        }

        Events().getEvents(eventScope) { [weak self] events, error in
            self?.loadingView.remove()

            if error != nil {
                return
            }

            self?.dataSource = EventsDataSource(events: events)
            self?.tableView.reloadData()

            if events.count > 0 {
                self?.emptyStateView.alpha = 0.0
                self?.pastEventsEmptyStateLabel.alpha = 0.0
                if self?.segmentedControl.selectedSegmentIndex == 0 {
                    self?.addCarpoolButton.enabled = true
                }
            } else {
                self?.setupEmptyStateView()
            }

            self?.adjustHeaderPosition()
        }
    }

    // MARK: UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCarpoolButton = UIBarButtonItem.barButtonForType(.Add, target: self, action: #selector(addButtonTapped(_:)))
        addCarpoolButton.tintColor = AppConfiguration.white()
        addCarpoolButton.enabled = false
        navigationItem.rightBarButtonItem = addCarpoolButton
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        view.backgroundColor = AppConfiguration.offWhite()
        
        emptyStateView.imageView.layer.cornerRadius = emptyStateView.imageView.bounds.size.height / 2.0
        
        let carpoolsCellNib = UINib(nibName: "CarpoolsCell", bundle: nil)
        tableView.registerNib(carpoolsCellNib, forCellReuseIdentifier: CarpoolsCell.CarpoolsCellReuseId)
        
        let carpoolsHeaderNib = UINib(nibName: "CarpoolsHeader", bundle: nil)
        tableView.registerNib(carpoolsHeaderNib, forHeaderFooterViewReuseIdentifier: CarpoolsHeader.headerReuseId)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadingView.addToView(view)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateEvents()
        
        AnalyticsController().screen("Carpools tab")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        loadingView.remove()
        hideUploadingView()
        pendingEventFactory = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        adjustHeaderPosition()
    }
}

// MARK: ApplicationDidBecomeActiveListener methods

extension CarpoolsViewController: ApplicationDidBecomeActiveListener {
    func applicationDidBecomeActive() {
        updateEvents()
    }
}

// MARK: CreateEventDelegate

extension CarpoolsViewController: CreateEventDelegate {
    func didCreateEventFactory(factory: EventFactory) {
        createEventWithFactory(factory)
    }
}

// MARK: UIScrollViewDelegate Methods

extension CarpoolsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Manually scroll the section headers out as the new one takes its place
        let sectionIndexSet = NSMutableIndexSet()
        
        // Get a set of all visible secitons
        for cell in tableView.visibleCells {
            if let indexPath = tableView.indexPathForCell(cell) {
                sectionIndexSet.addIndex(indexPath.section)
            }
        }
        
        if sectionIndexSet.count >= 2 {
            // Get the top and second to top headers
            let firstHeader = tableView.headerViewForSection(sectionIndexSet.firstIndex)
            let secondHeader = tableView.headerViewForSection(sectionIndexSet.firstIndex + 1)
            
            let headerTopDistance = CarpoolsHeader.headerHeight
            let firstHeaderMaxY = firstHeader!.frame.origin.y + headerTopDistance
            
            // Adjust the frame to let the second header push the first header out
            if firstHeaderMaxY > secondHeader!.frame.origin.y {
                var frame = firstHeader!.frame
                frame.origin.y = secondHeader!.frame.origin.y - headerTopDistance
                firstHeader!.frame = frame
            }
        }
    }
}

// MARK: UITableViewDataSource Methods

extension CarpoolsViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CarpoolsCell.CarpoolsCellReuseId, forIndexPath: indexPath) as! CarpoolsCell
        
        let event = dataSource.eventForIndexPath(indexPath)
        let style = segmentedControl.selectedSegmentIndex == 0 ? CarpoolsCellStyle.Standard : CarpoolsCellStyle.Gray
        
        cell.populateFromEvent(event, style: style)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionArray = dataSource.dataArray[section]
        return sectionArray.count
    }
}

// MARK: UITableViewDelegate Methods

extension CarpoolsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event = dataSource.eventForIndexPath(indexPath)
        let detailViewController = CarpoolDetailsViewController(event: event, showResponseView: false)
        
        navigationController?.pushViewController(detailViewController, animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(CarpoolsHeader.headerReuseId) as! CarpoolsHeader
        
        let sectionArray = dataSource.dataArray[section]
        if let event = sectionArray.first {
            header.setDate(event.startTime)
        }
        
        return header
    }
}

// MARK: UploadingViewDelegate

extension CarpoolsViewController: UploadingViewDelegate {
    func uploadingViewTapped(view: UploadingView) {
        if view.uploadingState == .Failed {
            if let unwrappedFactory = pendingEventFactory {
                createEventWithFactory(unwrappedFactory)
            }
        }
    }
}

// MARK: UserDidSignInListener methods

extension CarpoolsViewController: UserDidSignInListener {
    func userDidSignIn() {
        updateEvents()
    }
}
