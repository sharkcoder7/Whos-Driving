import UIKit

/// Custom tab bar class. Acts as an entry point for global actions such as handling notifications
/// and sign in/sign out.
class TabBarViewController: UITabBarController {
    
    // MARK: Private Properties
    
    /// True if this is the first time this view has been seen. Is updated in viewDidAppear.
    private var firstView = true
    
    /// Used to present the sign-in flow to the user. Initialized in the designated initializer.
    private var signInPresenter: SignInPresenter!

    // MARK: Init Methods
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        WebServiceController.sharedInstance.errorDelegate = self
        
        view.backgroundColor = UIColor.whiteColor();
        view.tintColor = AppConfiguration.blue()
        
        setupViewController()
        self.signInPresenter = SignInPresenter(presentingViewController: self)
        
        tabBar.translucent = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Instance Methods
    
    /**
     Unwinds the navigation stack and displays the sign-in view controller and the account
     confirmation view controller.
     
     - parameter accountConfirmationToken: Used to identify and verify the user before presenting
     the account confirmation screen.
     */
    func handleAccountConfirmationToken(accountConfirmationToken: String) {
        let confirmAccountViewController = ConfirmAccountViewController.viewController(withConfirmationToken: accountConfirmationToken)
        presentViewController(confirmAccountViewController, animated: true, completion: nil)
    }
    
    /**
    Unwinds the navigation stack and displays the Driver view controller, then loads the details of 
    the provided inviteToken from the server and displays the info to the user, or an alert if any 
    issues are encountered.
    
    - parameter inviteToken Used to load the details of the Invite from the server.
    */
    func handleInviteToken(inviteToken: String) {
        unwindStackToTab(1)
        
        Invites.sharedInstace.getInviteForInviteToken(inviteToken) { [weak self] (invite, error) -> Void in
            if let error = error {
                let alert = defaultAlertController(error.localizedDescription)
                self?.presentViewController(alert, animated: true, completion: nil)
            } else {
                if let invite = invite {
                    let acceptInviteVC = AcceptInviteViewController(invite: invite)
                    let navController = NavigationController(rootViewController: acceptInviteVC)
                    navController.navigationBarHidden = true
                    self?.presentViewController(navController, animated: true, completion: nil)
                }
            }
        }
    }
    
    /**
     Unwinds the navigation stack and displays the sign-in view controller and the password reset
     view controller.
     
     - parameter passwordResetToken: Used to identify and verify the user before a password reset.
     */
    func handlePasswordResetToken(passwordResetToken: String) {
        unwindStackToTab(0)
        
        signInPresenter.presentPasswordResetViewController(withResetToken: passwordResetToken)
    }
    
    /**
    Handle receiving of a remote notification.
    
    - parameter userInfo The userInfo dictionary from the remote notification.
    */
    func handleRemoteNotification(userInfo: [NSObject : AnyObject]) {
        guard let remoteNotification = RemoteNotification(userInfo: userInfo) else {
            return
        }
        
        if UIApplication.sharedApplication().applicationState == .Active {
            if remoteNotification.type == .New {
                // do nothing for new event notifications
                return
            }
            
            // if user is active, check if they're currently looking at the event detail that was updated, otherwise return and do nothing
            if selectedIndex != 0 {
                return
            }
            guard let carpoolsNavController = selectedViewController as? UINavigationController else {
                return
            }
            if carpoolsNavController.viewControllers.count < 2 {
                return
            }
            guard let carpoolDetailsVC = carpoolsNavController.viewControllers[1] as? CarpoolDetailsViewController else {
                return
            }
            if remoteNotification.eventId != carpoolDetailsVC.event.id {
                dLog("Event ID of remote notification doesn't match current event detail")
                return
            }
            
            switch remoteNotification.type {
            case .New:
                // This shouldn't be possible because you can't be viewing the event details of a new event
                return
                
            case .Edit:
                let authorName = remoteNotification.authorName
                
                let alertController = UIAlertController(title: "Carpool Updated", message: "\(authorName) has just updated the carpool you're currently looking at. Would you like to refresh this screen?", preferredStyle: UIAlertControllerStyle.Alert)
                let noAction = UIAlertAction(title: "No", style: .Default, handler: { (action) -> Void in
                    AnalyticsController().track("Clicked 'No' on remote notification alert")
                })
                alertController.addAction(noAction)
                var refreshAction: UIAlertAction?
                
                if let carpoolDetailsVC = carpoolsNavController.viewControllers.last as? CarpoolDetailsViewController {
                    var modalVC: ModalViewController?
                    for viewController in childViewControllers {
                        if viewController.isKindOfClass(ModalViewController) {
                            modalVC = viewController as? ModalViewController
                            break
                        }
                    }
                    
                    if let modalVC = modalVC {
                        // If there's a modalVC, alert them they'll lose any changes they've made
                        alertController.message = "\(authorName) has just updated the carpool you're currently looking at. Would you like to refresh this screen?\n\nIf you refresh, you will lose any unsaved changes you've made to this carpool."
                        refreshAction = UIAlertAction(title: "Refresh", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            AnalyticsController().track("Clicked 'Refresh' on remote notification alert")
                            
                            modalVC.animateOut()
                            carpoolDetailsVC.loadEvent()
                        })
                    } else {
                        refreshAction = UIAlertAction(title: "Refresh", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            AnalyticsController().track("Clicked 'Refresh' on remote notification alert")
                            
                            carpoolDetailsVC.loadEvent()
                        })
                    }
                } else if let carpoolHistoryVC = carpoolsNavController.viewControllers.last as? CarpoolHistoryViewController {
                    refreshAction = UIAlertAction(title: "Refresh", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                        AnalyticsController().track("Clicked 'Refresh' on remote notification alert")
                        
                        carpoolHistoryVC.reloadEvent()
                    })
                }
                
                if let unwrappedRefreshAction = refreshAction {
                    alertController.addAction(unwrappedRefreshAction)
                    presentViewController(alertController, animated: true, completion: nil)
                } else {
                    dLog("Missing logic to refresh a view in the carpool detail stack. Need refresh action for the current controller.")
                }
                
            case .Delete:
                let alert = UIAlertController(title: "Carpool Deleted", message: "The carpool you're currently looking at has been deleted!", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                    carpoolDetailsVC.navigationController?.popToRootViewControllerAnimated(true)
                }))
                
                presentViewController(alert, animated: true, completion: nil)
            }

        } else {
            showEventDetailForEvent(remoteNotification.eventId)
        }
    }
    
    /**
     Present the account setup screens. This should be used instead of -presentSignIn() if the user
     is already signed in, but their account setup is incomplete.
     */
    func presentAccountSetup() {
        let accountSetupVC = SetupContactInfoViewController(nibName: "SetupContactInfoViewController", bundle: nil)
        let navController = NavigationController(rootViewController: accountSetupVC)
        presentViewController(navController, animated: true, completion: nil)
    }
    
    /**
     Present the sign in view controller for the user to sign into Facebook.
     */
    func presentSignIn() {
        let introViewDisplayed = NSUserDefaults.standardUserDefaults().boolForKey(IntroViewController.introViewDisplayedKey)
        
        let completion: () -> () = {
            [weak self] in
            self?.resetForSignOut()
        }
        
        if introViewDisplayed == false {
            let introVC = IntroViewController.viewController()
            introVC.signInDelegate = self
            signInPresenter.presentIntroViewController(introVC, animated: true, completion: completion)
        } else {
            let signInVC = SignInViewController.viewController()
            signInVC.delegate = self
            signInPresenter.presentSignInViewController(signInVC, animated: true, completion: completion)
        }
    }
    
    // MARK: Private methods
    
    /**
    Notify all of the tab bar view controllers that the user did successfully sign in.
    */
    private func notififySignInListeners() {
        registerForNotifications()
        
        if let viewControllers = viewControllers {
            for viewController in viewControllers {
                if let navController = viewController as? UINavigationController {
                    if let rootVC = navController.viewControllers.first as? UserDidSignInListener {
                        rootVC.userDidSignIn()
                    }
                }
            }
        }
    }
    
    /**
     Registers the user for remote notifications, and asks the user if they would like to receive
     notifications.
     */
    private func registerForNotifications() {
        let application = UIApplication.sharedApplication()
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }
    
    /**
    Reset the app after a user signs out. This clears the URL cache and recreates all the view
    controllers in the tabs from scratch.
    */
    private func resetForSignOut() {
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        setupViewController()
    }
    
    /**
     Setup the view controllers in the tab bar.
     */
    private func setupViewController() {
        let carpools = CarpoolsViewController(nibName: "CarpoolsViewController", bundle: nil);
        let carpoolsNavigationController = NavigationController(rootViewController: carpools)

        let drivers = DriversViewController(nibName: "DriversViewController", bundle: nil);
        let driversNavigationController = NavigationController(rootViewController: drivers)
        
        let kids = KidsViewController(nibName: "KidsViewController", bundle: nil);
        let kidsNavigationController = NavigationController(rootViewController: kids)
        
        let profile = ProfileViewController(nibName: "ProfileViewController", bundle: nil);
        let profileNavigationController = NavigationController(rootViewController: profile)
        
        viewControllers = [carpoolsNavigationController, driversNavigationController, kidsNavigationController, profileNavigationController]
    }
    
    /**
     Unwinds the navigation stack for all tabs, switches to the carpool tab, dismisses any modal 
     views and passes the eventId to the CarpoolViewController to load and present the details for
     that event.
     
     - parameter eventId The id of the event to show the details of.
     */
    private func showEventDetailForEvent(eventId: String) {
        unwindStackToTab(0)
        
        if let unwrappedViewControllers = viewControllers {
            if let navController = unwrappedViewControllers[0] as? UINavigationController {
                if let carpoolsVC = navController.viewControllers[0] as? CarpoolsViewController {
                    carpoolsVC.handleRemoteNotificationForEvent(eventId)
                }
            }
        }
    }
    
    /**
     Unwinds the navigation stack for all tabs, dismisses any modal views and switches to the specified
     tab.
     
     - parameter tabBarIndex The tab in the tab bar controller to select. Defaults to 0.
     */
    private func unwindStackToTab(tabBarIndex: NSInteger = 0) {
        if let unwrappedViewControllers = viewControllers {
            if tabBarIndex > unwrappedViewControllers.count - 1 {
                dLog("Invalid tab bar index.")
                return
            }
            
            if let navController = unwrappedViewControllers[tabBarIndex] as? UINavigationController {
                // select the view controller from tabBarIndex
                selectedViewController = navController
                
                // unwind the navigation stack of all the view controllers
                for viewController in unwrappedViewControllers {
                    if let navController = viewController as? UINavigationController {
                        navController.popToRootViewControllerAnimated(false)
                    }
                }
                
                // dismiss all ModalViewControllers
                for viewController in childViewControllers {
                    if let modalVC = viewController as? ModalViewController {
                        modalVC.animateOut()
                    }
                }
            }
        }
    }
    
    // MARK: UIViewController Methods
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if SessionCredentialsHandler.loggedIn() == false {
            presentSignIn()
        } else {
            if firstView {
                Profiles().getCurrentUserProfile({ [weak self] (currentUser, accountSetupComplete, error) -> Void in
                    if accountSetupComplete == false {
                        self?.presentAccountSetup()
                    }
                })
                
                notififySignInListeners()
            }
        }
        
        firstView = false        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Ensures that the modal view background always stays in front of the
        // tab bar when pushing and popping views behind the modal.
        for viewController in childViewControllers {
            if viewController.isKindOfClass(ModalViewController) {
                view.bringSubviewToFront(viewController.view)
            }
        }
    }
}

// MARK: SignInViewControllerDelegate methods

extension TabBarViewController: SignInViewControllerDelegate {
    func signInViewControllerDidSignIn() {
        notififySignInListeners()
    }
}

// MARK: WebServiceControllerErrorDelegate methods

extension TabBarViewController: WebServiceControllerErrorDelegate {
    func webServiceControllerEncounteredAuthError(webServiceController: WebServiceController) {
        presentSignIn()
    }
    
    func webServiceControllerEncounteredKillSwitch(webServiceController: WebServiceController, message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        presentViewController(alertController, animated: true, completion: nil)
    }
}

class IntroViewTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1.0
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = transitionContext.containerView() else {
            return
        }

        let endFrame = containerView.bounds

        let backgroundView = UIView(frame: endFrame)
        backgroundView.backgroundColor = AppConfiguration.lightBlue()
        backgroundView.alpha = 0.0
        containerView.addSubview(backgroundView)

        var startFrame = endFrame
        startFrame.origin.y = endFrame.size.height * 2.0

        let view = transitionContext.viewForKey(UITransitionContextToViewKey)!
        view.frame = startFrame
        view.alpha = 0.0

        containerView.addSubview(view)

        UIView.animateWithDuration(0.2, delay: 0.0, options: [.CurveEaseOut], animations: {
            backgroundView.alpha = 1.0
        }, completion: nil)

        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [.CurveEaseInOut], animations: {
            view.frame = endFrame
            view.alpha = 1.0
        }, completion: { finished in
            backgroundView.removeFromSuperview()
            transitionContext.completeTransition(finished)
        })
    }
}

/**
 *  Objects that conform to this protocol will be alerted when a user signs in to the app.
 */
protocol UserDidSignInListener: class {
    
    /**
     Called when the user signs in, or the app launches with a signed in user.
     */
    func userDidSignIn()
}
