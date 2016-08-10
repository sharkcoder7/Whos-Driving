import Crashlytics
import Fabric
import FBSDKCoreKit
import FBSDKLoginKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Properties
    
    /// This is the root view controller of the main window of the app.
    var tabBarController: TabBarViewController?
    
    /// The main window of the app.
    var window: UIWindow?

    // MARK: Instance methods
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        return handleUserActivity(userActivity)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        dLog("\(error)")
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        AnalyticsController().setup()
        AnalyticsController().track("Launched app")

        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        tabBarController = TabBarViewController()
        window?.rootViewController = tabBarController
        
        window?.makeKeyAndVisible()
        
        UIActivityIndicatorView.appearance().color = AppConfiguration.mediumGray()
        
        if let unwrappedLaunchOptions = launchOptions {
            if let remoteNotification = unwrappedLaunchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
                AnalyticsController().track("Launched app from remote notification")

                dLog("Launched with remote notification.")
                tabBarController?.handleRemoteNotification(remoteNotification)
            } else if let userActivityDict = unwrappedLaunchOptions[UIApplicationLaunchOptionsUserActivityDictionaryKey] as? [NSObject : AnyObject] {
                for (_, value) in userActivityDict {
                    if let userActivity = value as? NSUserActivity {
                        handleUserActivity(userActivity)
                        break
                    }
                }
            }
        }
        
        Fabric.with([Crashlytics.self()])
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        dLog("Received remote notification.")

        tabBarController?.handleRemoteNotification(userInfo)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Devices().registerDevice(deviceToken) { (error) -> Void in
            if error != nil {
                dLog("Error registering device with server: \(error)")
            } else {
                dLog("Success registering device with server.")
            }
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        
        if SessionCredentialsHandler.loggedIn() {
            AppDelegate.notifyViewControllerDidBecomeActive(window?.rootViewController)
        }
    }
    
    // MARK: Class methods
    
    /**
    Recursively checks all child view controllers of the provided UIViewController to see if any of
    them conform to the ApplicationDidBecomeActiveListener protocol. If they do, it calls
    -applicationDidBecomeActive.
    
    - parameter viewController The root view controller. This view controller and all of it's children
                               will be checked for the ApplicationDidBecomeActiveListender protocol.
    */
    static func notifyViewControllerDidBecomeActive(viewController: UIViewController?) {
        if let viewController = viewController as? ApplicationDidBecomeActiveListener {
            viewController.applicationDidBecomeActive()
        }
        
        for childViewController in viewController?.childViewControllers ?? [] {
            notifyViewControllerDidBecomeActive(childViewController)
        }
    }
    
    // MARK: Private methods
    
    /**
    Handle an NSUserActivity by opening it from the app if possible.
    
    - parameter userActivity The NSUserActivity passed to the app.
    
    - returns: True if the application can handle the NSUserActivity.
    */
    private func handleUserActivity(userActivity: NSUserActivity) -> Bool {
        if let webpageURL = userActivity.webpageURL {
            if let accountConfirmationToken = Users.getAccountConfirmationTokenFromURL(webpageURL) {
                tabBarController?.handleAccountConfirmationToken(accountConfirmationToken)
                return true
            }
            
            if let passwordResetToken = Users.getResetPasswordTokenFromURL(webpageURL) {
                tabBarController?.handlePasswordResetToken(passwordResetToken)
                return true
            }
            
            if let inviteToken = Invites.getInviteTokenFromURL(webpageURL) {
                // Check hasAuthenticationToken here instead of SessionCredentialsHandler.loggedIn()
                // because on app startup the FBSDKAccessToken.currentAccessToken() is nil.
                if WebServiceController.sharedInstance.hasAuthenticationToken {
                    tabBarController?.handleInviteToken(inviteToken)
                } else {
                    // user not logged in, saving the token to pendingInviteToken
                    Invites.sharedInstace.pendingInviteToken = inviteToken
                }
                
                return true
            }
        }
        
        return false
    }
}

/// Protocol optionally implemented by view controllers to opt into a callback when the app becomes
/// active. The app delegate will automatically invoke this method.
///
protocol ApplicationDidBecomeActiveListener {
    /// Invoked when the app becomes active.
    func applicationDidBecomeActive()
}
