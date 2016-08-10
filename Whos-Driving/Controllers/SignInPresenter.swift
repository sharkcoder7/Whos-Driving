import Foundation
import UIKit

/// An instance of this class is used to manage displaying the sign-in view controller. It maintains
/// a reference to the navigation controller that is displaying the sign-in view controller and 
/// allows additional view controllers to be presented when the sign-in view controller is currently
/// displayed to the user.
///
final class SignInPresenter: NSObject {
    
    // MARK: Private Properties
    
    /// This property is used to present the sign-in view controller. Most likely, this property
    /// is a reference to the root view controller of the application.
    private var presentingViewController: UIViewController?
    
    /// The navigation controller that is displaying the sign-in view controller. This property is
    /// used to push other view controllers onto the navigation stack when the sign-in view
    /// controller is already displayed.
    ///
    /// This is useful, for example, when the app is displaying the sign-in screen and the user
    /// opens the app by clicking on a password reset link in an email.
    private var signInNavigationController: NavigationController?
    
    /// The sign-in view controller that is currently displayed. In certain scenarios, this property
    /// becomes the delegate for other view controllers that are pushed onto the navigation stack
    /// (i.e. the reset password view controller).
    private var signInViewController: SignInViewController?
    
    // MARK: Init Methods
    
    /**
     This is the designated initializer for this class.
     
     - parameter presentingViewController: this view controller is used to present the sign-in flow
     to the user. This should be the root view controller of the application.
     
     - returns: a new instance of the class.
     */
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
    
    // MARK: Instance Methods
    
    /**
     Presents an IntroViewController modally to the user. This method does not attempt to verify
     that no other view controller is currently being presented modally to the user.
     
     - parameter introViewController: the view controller to present.
     - parameter animated:            a bool indicating if the view controller should be presented
     with animation.
     - parameter completion:          the closure to be executed when the presentation completes.
     This closure returns nothing and takes no parameters.
     */
    func presentIntroViewController(introViewController: IntroViewController, animated: Bool, completion: (() -> ())?) {
        let navigationController = NavigationController(rootViewController: introViewController)
        navigationController.modalPresentationStyle = .OverCurrentContext
        navigationController.modalTransitionStyle = .CoverVertical
        navigationController.transitioningDelegate = self
        
        presentingViewController?.presentViewController(navigationController, animated: animated, completion: completion)
    }
    
    /**
     Presents a view controller to the user that allows them to reset their password. This method
     verifies that a sign-in view controller is already displayed to the user before presenting the
     reset password view controller.
     
     - parameter passwordResetToken: The token from the services that can be used to reset the users
     password.
     */
    func presentPasswordResetViewController(withResetToken passwordResetToken: String) {
        let pushPasswordResetViewController: (onNavigationController: NavigationController) -> () = {
            navigationController in
            let passwordResetViewController = ResetPasswordViewController.viewController(withPasswordResetToken: passwordResetToken)
            passwordResetViewController.delegate = self.signInViewController
            navigationController.pushViewController(passwordResetViewController, animated: true)
        }
        
        guard let signInNavigationController = signInNavigationController else {
            let signInViewController = SignInViewController.viewController()
            let navigationController = NavigationController(rootViewController: signInViewController)
            navigationController.transitioningDelegate = self
            self.signInNavigationController = navigationController
            
            pushPasswordResetViewController(onNavigationController: self.signInNavigationController!)
            
            presentingViewController?.presentViewController(navigationController, animated: true, completion: nil)
            
            return
        }
        
        pushPasswordResetViewController(onNavigationController: signInNavigationController)
    }
    
    /**
     Presents a sign-in view controller to the user.
     
     - parameter signInViewController: the view controller to present to the user.
     - parameter animated:             a bool indicating if the view controller should be presented
     with animation.
     - parameter completion:           the closure to be executed when the presentation completes.
     This closure returns nothing and takes no parameters.
     */
    func presentSignInViewController(signInViewController: SignInViewController, animated: Bool, completion: (() -> ())?) {
        self.signInViewController = signInViewController
        signInNavigationController = NavigationController(rootViewController: signInViewController)
        self.signInNavigationController?.transitioningDelegate = self
        
        if presentingViewController?.presentedViewController == nil {
            presentingViewController?.presentViewController(self.signInNavigationController!, animated: animated, completion: completion)
        }
    }
}

// MARK: UIViewControllerTransitioningDelegate methods

extension SignInPresenter: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return IntroViewTransitionAnimation()
    }
}
