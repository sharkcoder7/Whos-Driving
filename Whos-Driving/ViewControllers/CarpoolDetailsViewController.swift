import UIKit

/// The status of the header view.
enum HeaderContainerStatus {
    /// Header is hidden
    case Hidden
    /// Header is displaying the ResponseConfirmationView
    case Confirm
    /// Header is displaying the banner if appropriate. This can be the small banner or the larger banner with driver_status responses
    case Banner
}

/// This view controller shows the details of a carpool event.
class CarpoolDetailsViewController: UIViewController {
    
    // MARK: Constants
    
    /// The height of the headerContainerView when the confirm view is shown.
    private let HeaderContainerHeightConfirm: CGFloat = 350.0
    
    /// The height to set the headerContainerPaddingConstraint when the headerContainerView is shown.
    private let HeaderContainerPadding: CGFloat = 13.0
    
    // MARK: Properties
    
    /// The event being display in this view.
    var event: Event
    
    // MARK: Private Properties
    
    /// The status of the header. This depends on what actions the user has taken. The default is
    /// .Banner.
    private var headerStatus = HeaderContainerStatus.Banner
    
    /// This is initially set as the lastViewed date of the Event in this view. It's stored separately
    /// so that if updates occur while this view is open we don't use the new lastViewed date of the
    /// event and end up hiding recent changes. When the user taps the "dismiss" button this is
    /// updated so only changes that occur after they dismiss will be shown.
    private var lastViewed: NSDate?
    
    // Loading view to display while event details are being loaded.
    private let loadingView = LoadingView()
    
    /// Yes if the response view for responding to a notification should be showing. Has no effect
    /// If the driver TO and FROM are both full already since no header is shown in that case.
    private var showResponseView: Bool
    
    // MARK: IBOutlets
    
    /// The view showing the details of the driving FROM leg of the event.
    @IBOutlet private weak var drivingFromView: DetailsToFromView!
    
    /// The view showing the details of the driving TO leg of the event.
    @IBOutlet private weak var drivingToView: DetailsToFromView!
    
    /// Height constraint for the headerContainerView.
    @IBOutlet private weak var headerContainerHeightConstraint: NSLayoutConstraint!
    
    /// Top padding constraint for the headerContainerView.
    @IBOutlet private weak var headerContainerPaddingConstraint: NSLayoutConstraint!
    
    /// The container view for the headerView and the responseConfirmationView.
    @IBOutlet private weak var headerContainerView: UIView!
    
    /// DetailHeaderView showing a prompt to the user to respond to the event. Can expand to show
    /// possible responses.
    @IBOutlet private weak var headerView: DetailHeaderView!
    
    /// Scroll view containing all the other views.
    @IBOutlet private weak var scrollView: UIScrollView!
    
    /// The view showing the details of the event, such as location and date.
    @IBOutlet private weak var summaryView: DetailsSummaryView!
    
    /// Width constraint for the summaryView.
    @IBOutlet private weak var summaryWidthConstraint: NSLayoutConstraint!
    
    /// Height constraint for the recentChangesView.
    @IBOutlet private weak var recentChangeHeightConstraint: NSLayoutConstraint!
    
    /// View showing a list of recent changes to the event being shown.
    @IBOutlet private weak var recentChangesView: RecentChangesView!
    
    /// View shown after a user send a driver status response. This view confirms the server 
    /// received the response and shows if it was successful or not.
    @IBOutlet private weak var responseConfirmationView: ResponseConfirmationView!

    // MARK: Init Methods
    
    /**
    Initializes a new instance of this class configured with an event, and a flag of whether the
    response view should be initially shown or hidden.
    
    - parameter event The event shown in this view.
    - parameter showResponseView True if the response view should be initially showing. False if it
                                 should be hidden and only the banner visible.
    
    - returns: Configured instance of this class.
    */
    required init(event: Event, showResponseView: Bool) {
        self.event = event
        self.showResponseView = showResponseView
        lastViewed = event.lastReadAt
        
        super.init(nibName: "CarpoolDetailsViewController", bundle: nil)
        
        title = NSLocalizedString("Carpool Details", comment: "Carpool Details title.")
        hidesBottomBarWhenPushed = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Instance methods
    
    /**
    Reloads the event from the server and refreshes the UI.
    */
    func loadEvent() {
        loadingView.addToView(view)
        
        Events().getEventById(event.id) { [weak self] event, error in
            self?.loadingView.remove()
            
            if let _ = error {
                return
            }
            
            if let event = event {
                self?.event = event
                self?.refresh(animated: true)
            }
        }
    }
    
    // MARK: Actions
    
    @objc private func historyButtonTapped() {
        let historyVC = CarpoolHistoryViewController(event: event)
        
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    // MARK: Private methods
    
    /**
    Performs "Genie effect" animation of the recentChangesView to the right bar button item.
    */
    private func animateRecentChangesHidden() {
        // add copy of recent changes view to navigation controller so it can be animated above the nav bar
        let convertedFrame = view.convertRect(recentChangesView.frame, toView: navigationController?.view)
        let animRecentChangesView = RecentChangesView(frame: convertedFrame)
        animRecentChangesView.configureForHistoryItems(recentChangesView.historyItems)
        navigationController?.view.addSubview(animRecentChangesView)
        navigationController?.view.layoutIfNeeded()
        
        // hide the other recent changes view
        recentChangesView.hidden = true
        recentChangeHeightConstraint.constant = 0
        
        // perform animations
        let animDuration = 0.55

        // move along bezier path animation
        let startPoint = animRecentChangesView.center
        let insetFromRightEdge: CGFloat = 10.0
        let insetFromTopEdge: CGFloat = 40.0
        let endpoint = CGPoint(x: view.frame.size.width - insetFromRightEdge, y: insetFromTopEdge)
        
        let path = UIBezierPath()
        path.moveToPoint(startPoint)
        let point1 = CGPoint(x: startPoint.x, y: (startPoint.y + endpoint.y) / 2.0)
        let point2 = CGPoint(x: (startPoint.x + endpoint.x) / 2.0, y: endpoint.y)
        path.addCurveToPoint(endpoint, controlPoint1: point1, controlPoint2: point2)
        
        let anim = CAKeyframeAnimation(keyPath: "position")
        anim.path = path.CGPath
        anim.duration = animDuration
        animRecentChangesView.layer.addAnimation(anim, forKey: "curve animation")
        
        // scale animation
        let minimumScale = 0.0001 as CGFloat
        UIView.animateWithDuration(animDuration, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            animRecentChangesView.transform = CGAffineTransformMakeScale(minimumScale, minimumScale)
            self.scrollView.layoutIfNeeded()
            self.scrollView.setContentOffset(CGPoint.zero, animated: false)
            
            }) { (finished) -> Void in
                animRecentChangesView.removeFromSuperview()
        }
    }
    
    /**
     After a user taps 'Submit' and submits their driver status response, this will perform the flip
     animation to the response confirmation view.
     */
    private func animateFlipToResponseConfirmationView() {
        UIView.transitionWithView(headerContainerView, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: { () -> Void in
            self.headerView.hidden = true
            self.responseConfirmationView.hidden = false
            self.headerStatus = .Confirm
            let headerHeight = self.headerHeightForStatus()
            self.headerContainerHeightConstraint.constant = headerHeight
            self.headerContainerPaddingConstraint.constant = headerHeight > 0 ? self.HeaderContainerPadding : 0
            self.scrollView.layoutIfNeeded()
            }, completion: nil)
    }

    /**
    Refreshes the UI.
     
     - parameter animated True to animate the changes to the UI.
    */
    private func refresh(animated animated: Bool) {
        populateViews()
        updateHeader(animated: animated)
        updateRecentChanges(animated: animated)
    }

    /**
    Populates the views for the current event.
    */
    private func populateViews() {
        drivingFromView.populateViewFor(event, isDrivingTo: false)
        drivingToView.populateViewFor(event, isDrivingTo: true)
        summaryView.populateView(event)
    }
    
     /**
     Updates the header container view. This will always set the headerView to be shown and the
     responseConfirmation view to be hidden.
     
     - parameter animated True to animate the changes to the header.
     */
    private func updateHeader(animated animated: Bool) {
        let animationDuration = animated ? 0.5 : 0.0
        
        headerView.hidden = false
        responseConfirmationView.hidden = true
        headerStatus = .Banner
        
        scrollView.layoutIfNeeded()
        
        UIView.animateWithDuration(animationDuration) { () -> Void in
            self.headerView.configureForStatus(self.event.driverStatus, responses: self.event.driverResponses, shouldShowResponseView: self.showResponseView)
            let headerHeight = self.headerHeightForStatus()
            self.headerContainerHeightConstraint.constant = headerHeight
            self.headerContainerPaddingConstraint.constant = headerHeight > 0 ? self.HeaderContainerPadding : 0
            
            self.scrollView.layoutIfNeeded()
        }
    }
    
     /**
     Updates the RecentChangesView with the the EventHistoryItems that haven't yet been viewed by
     the user.
     
     - parameter animated True to animate the changes to the RecentChangesView.
     */
    private func updateRecentChanges(animated animated: Bool) {
        scrollView.layoutIfNeeded()

        let animationDuration = animated ? 0.3 : 0.0

        let sinceItems = EventHistoryItem.itemsSinceDate(event.eventHistory, date: lastViewed)
        let recentChangesHeight = recentChangesView.configureForHistoryItems(sinceItems)
        recentChangesView.hidden = false
        
        UIView.animateWithDuration(animationDuration) { () -> Void in
            self.recentChangeHeightConstraint.constant = recentChangesHeight
            
            self.scrollView.layoutIfNeeded()
        }
    }

     /**
     Returns the height of the header view for the current headerStatus.
     
     - returns: The height of the header view.
     */
    private func headerHeightForStatus() -> CGFloat {
        switch headerStatus {
        case .Banner:
            return headerView.preferredHeight()
        case .Confirm:
            return HeaderContainerHeightConfirm
        case .Hidden:
            return 0.0
        }
    }
    
    // MARK: UIViewController Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButton = UIBarButtonItem.barButtonForType(.History, target: self, action: #selector(historyButtonTapped))
        navigationItem.rightBarButtonItem = rightButton

        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)

        scrollView.backgroundColor = AppConfiguration.offWhite()
        
        drivingFromView.delegate = self
        drivingFromView.detailsToFromViewDelegate = self
        
        drivingToView.delegate = self
        drivingToView.detailsToFromViewDelegate = self
        
        summaryView.delegate = self
        summaryView.detailsSummaryViewDelegate = self
        
        headerView.delegate = self
        
        responseConfirmationView.delegate = self
        
        recentChangesView.delegate = self
        
        refresh(animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        summaryWidthConstraint.constant = view.frame.width
        let headerHeight = headerHeightForStatus()
        headerContainerHeightConstraint.constant = headerHeight
        headerContainerPaddingConstraint.constant = headerHeight > 0 ? HeaderContainerPadding : 0
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        loadEvent()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsController().screen("Carpool detail")
    }
}

// MARK: ApplicationDidBecomeActiveListener methods

extension CarpoolDetailsViewController: ApplicationDidBecomeActiveListener {
    func applicationDidBecomeActive() {
        loadEvent()
    }
}

// MARK: DetailHeaderViewDelegate methods

extension CarpoolDetailsViewController: DetailHeaderViewDelegate {
    func detailHeaderViewHeaderLabelTapped(detailHeaderView: DetailHeaderView) {
        showResponseView = !showResponseView
        
        updateHeader(animated: true)
    }
    
    func detailHeaderViewSubmitButtonTapped(detailHeaderView: DetailHeaderView, driverStatus: DriverStatus) {
        let properties = [AnalyticsController.DriverStatusResponseKey : driverStatus.rawValue]
        AnalyticsController().track("Clicked submit driver response button", context: nil, properties: properties)

        headerView.submitting = true
        DriverStatuses().updateDriverStatus(driverStatus, eventId: event.id) { [weak self] (event, responseConfirmation, error) -> Void in
            self?.headerView.submitting = false

            if error != nil {
                let alertController = defaultAlertController("Error communicating with the server! Please try again")
                self?.presentViewController(alertController, animated: true, completion: nil)
                
            } else {
                if let unwrappedEvent = event {
                    self?.event = unwrappedEvent
                    self?.populateViews()
                    self?.updateRecentChanges(animated: true)
                }
                
                if let unwrappedConfrimation = responseConfirmation {
                    self?.responseConfirmationView.configureForResponse(unwrappedConfrimation)
                    self?.showResponseView = false
                    
                    self?.headerContainerView.layoutIfNeeded()
                    
                    self?.animateFlipToResponseConfirmationView()
                } else {
                    self?.updateHeader(animated: false)
                }
            }
        }
    }
}

// MARK: DetailsToFromViewDelegate methods

extension CarpoolDetailsViewController: DetailsToFromViewDelegate {
    func DetailsToFromViewEditButtonTapped(detailsView: DetailsToFromView) {
        if (detailsView.drivingTo) {
            AnalyticsController().track("Clicked edit driving to")
        } else {
            AnalyticsController().track("Clicked edit driving from")
        }
        
        let editViewController = EditDrivingToFromViewController(anEvent: event, isDrivingTo: detailsView.drivingTo, editDrivingDelegate: self)
        let modalViewController = ModalViewController(viewController: editViewController)
        modalViewController.presentOverViewController(tabBarController!, sender: detailsView.editButton)
    }
}

// MARK: DetailsSummaryViewDelegate methods

extension CarpoolDetailsViewController: DetailsSummaryViewDelegate {
    func detailsSummaryViewEditButtonTapped(detailsSummaryView: DetailsSummaryView) {
        AnalyticsController().track("Clicked edit event details")

        let editViewController = EditLocationViewController(event: event, editLocationDelegate: self)
        let modalViewController = ModalViewController(viewController: editViewController)
        modalViewController.presentOverViewController(tabBarController!, sender: detailsSummaryView.editButton)
    }
    
    func detailsSummaryViewLocationTapped(detailsSummaryView: DetailsSummaryView) {
        if let unwrappedEventLocation = detailsSummaryView.event?.location {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let copyAction = UIAlertAction(title: "Copy Address", style: .Default) { (action) -> Void in
                UIPasteboard.generalPasteboard().string = unwrappedEventLocation
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)

            alertController.addAction(copyAction)
            alertController.addAction(cancelAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func detailsSummaryViewMapViewTapped(detailsSummaryView: DetailsSummaryView) {
        if let unwrappedEventLocation = detailsSummaryView.event?.location {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let openInMapsAction = UIAlertAction(title: "Open in Maps", style: UIAlertActionStyle.Default) { (action) -> Void in
                let locationQuery = unwrappedEventLocation.stringByReplacingOccurrencesOfString(" ", withString: "+")
                let mapUrlString = "http://maps.apple.com/?q=\(locationQuery)"
                if let mapUrl = NSURL(string: mapUrlString) {
                    UIApplication.sharedApplication().openURL(mapUrl)
                }
            }
            
            let copyAction = UIAlertAction(title: "Copy Address", style: UIAlertActionStyle.Default) { (action) -> Void in
                UIPasteboard.generalPasteboard().string = unwrappedEventLocation
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            alertController.addAction(openInMapsAction)
            alertController.addAction(copyAction)
            alertController.addAction(cancelAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: DetailsViewDelegate methods

extension CarpoolDetailsViewController: DetailsViewDelegate {
    func detailsViewRequestsLayout(detailsView: DetailsBaseView, duration: Double) {
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}

// MARK: EditDrivingToFromViewControllerDelegate methods

extension CarpoolDetailsViewController: EditDrivingToFromViewControllerDelegate {
    func editDrivingViewController(viewController: EditDrivingToFromViewController, didUpdateEvent event: Event?) {
        if let event = event {
            self.event = event
        }
        
        // after user edits the event, hide the response view if it was showing
        showResponseView = false
        refresh(animated: true)
    }
}

// MARK: EditLocationViewControllerDelegate methods

extension CarpoolDetailsViewController: EditLocationViewControllerDelegate {
    func editLocationController(viewController: EditLocationViewController, didUpdateEvent event: Event?) {
        if let event = event {
           self.event = event
        }
        
        // after user edits the event, hide the response view if it was showing
        showResponseView = false
        refresh(animated: true)
    }
    
    func editLocationControllerDidDeleteEvent(viewController: EditLocationViewController) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
}

// MARK: RecentChangesViewDelegate methods

extension CarpoolDetailsViewController: RecentChangesViewDelegate {
    func recentChangesViewDismissButtonTapped(view: RecentChangesView) {
        animateRecentChangesHidden()
        
        if let firstItem = event.eventHistory.first {
            // Save whatever the date of the top most item in this list is when the view is dismissed. 
            // The user has seen up to that point in history. Any changes that have occured after that
            // date can be assumed to have not been seen yet.
            let lastItemViewedDate = firstItem.date
            lastViewed = lastItemViewedDate
        }
    }
}

// MARK: ResponseConfirmationViewDelegate methods

extension CarpoolDetailsViewController: ResponseConfirmationViewDelegate {
    func responseConfirmationViewDismissButtonTapped(responseConfirmationView: ResponseConfirmationView) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.headerStatus = .Hidden
            let headerHeight = self.headerHeightForStatus()
            self.headerContainerHeightConstraint.constant = headerHeight
            self.headerContainerPaddingConstraint.constant = headerHeight > 0 ? self.HeaderContainerPadding : 0
            
            self.scrollView.layoutIfNeeded()
            }) { (finished) -> Void in
                self.headerView.hidden = true
                self.responseConfirmationView.hidden = false
        }
    }
}
