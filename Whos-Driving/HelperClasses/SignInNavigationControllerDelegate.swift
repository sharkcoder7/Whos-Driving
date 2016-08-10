import Foundation
import UIKit

// MARK: SignInNavigationControllerDelegate

/// This class is used by the sign in view controller to provide a custom navigation controller
/// transition.
final class SignInNavigationControllerDelegate: NSObject {
    
}

// MARK: UINavigationControllerDelegate Methods

extension SignInNavigationControllerDelegate: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimatedTransition()
    }
}

// MARK: AnimatedTransition

/// This class performs the animations for the navigation controller delegate.
private class AnimatedTransition: NSObject {
    
}

// MARK: UIViewControllerAnimatedTransitioning Methods

extension AnimatedTransition: UIViewControllerAnimatedTransitioning {
    dynamic private func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = transitionContext.containerView() else {
            return
        }
        
        guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) else {
            return
        }
        
        guard let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
            return
        }
        
        // Add the to view controller's view as a subview
        
        containerView.addSubview(toViewController.view)
        toViewController.view.alpha = 0.0
        toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
        
        // Create the animations for the transition
        
        let endHeight: CGFloat = 64.0
        let fromViewControllerHeight = CGRectGetHeight(fromViewController.view.frame)
        
        // Translate
        
        let tx: CGFloat = 0.0
        let ty: CGFloat = -(fromViewControllerHeight / 2) + (endHeight / 2)
        let translate = CGAffineTransformMakeTranslation(tx, ty)
        
        // Scale
        
        let sx: CGFloat = 1.0
        let sy: CGFloat = endHeight / fromViewControllerHeight
        
        let translateAndScale = CGAffineTransformScale(translate, sx, sy)
        
        // Define the animation variables/closures
        
        let duration = transitionDuration(transitionContext)
        
        let animations: () -> () = {
            fromViewController.view.transform = translateAndScale
        }
        
        let completion: (Bool) -> () = {
            complete in
            UIView.animateWithDuration(duration) {
                fromViewController.view.alpha = 0.0
                toViewController.view.alpha = 1.0
                transitionContext.completeTransition(complete)
            }
        }
        
        // Execute the animation
        
        UIView.animateWithDuration(duration, animations: animations, completion: completion)
    }
    
    dynamic private func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.6
    }
}
