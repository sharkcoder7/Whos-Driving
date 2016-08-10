import UIKit

/// Objects that conform to this protocol will receive messages when the modal view controller is
/// dismissed.
@objc protocol ModalViewControllerDelegate: class {
    
    /**
     Called when the modal view controller finished its dismiss animation and is no longer visible.
     
     - parameter viewController The view controller that was dismissed.
     */
    optional func modalViewControllerDidDismiss(viewController: ModalViewController)

    /**
     Called when the modal view controller will be dismissed from view.
     
     - parameter viewController The view controller being dismissed.
     */
    optional func modalViewControllerWillDismiss(viewController: ModalViewController)
}

/// Container view controller for ModalBaseViewController's. Used as a custom navigation controller
/// when presenting a focus frame.
class ModalViewController: UIViewController {
    
    // MARK: Constants
    
    /// Animation duration of the first half of the intro animation.
    private let introAnimationFirstHalfDuration = 0.15
    
    /// Animation duration of the second half of the intro animation.
    private let introAnimationSecondHalfDuration = 0.4
    
    /// Spring dampening used for the intro animation.
    private let introAnimationSpringDampening = 0.63 as CGFloat
    
    /// Minimum scale.
    private let minimumScalePercentage = 0.0001 as CGFloat
    
    /// Scale to use for the first half of the intro animation.
    private let partialScalePercentage = 0.35 as CGFloat
    
    /// Padding to adjust the endpoint of the intro animation to make it look better.
    private let translationEndpointPadding = 20 as CGFloat
    
    // MARK: Properties
    
    /// Delegate that receives messages when this view controller is dismissed.
    weak var delegate: ModalViewControllerDelegate?
    
    // MARK: Private properties
    
    /// Navigation controller that holds the ModalBaseViewController's being presented.
    private let contentNavigationController: UINavigationController
    
    /// The endpoint for the introOutro animation.
    private var introOutroTranslationEndpoint: CGPoint?
    
    // MARK: IBOutlets
    
    /// Background view.
    @IBOutlet private weak var backgroundView: UIView!
    
    /// Container view for the other views in this class.
    @IBOutlet private weak var contentContainerView: UIView!
    
    /// The UINavigationBar at the top of this view controller.
    @IBOutlet weak var navBar: UINavigationBar!
    
    // MARK: Init and deinit methods
    
    /**
    Creates a new instance of this class.
    
    - parameter viewController The first ModalBaseViewController subclass to show in the 
                               contentNavigationController.
    
    - returns: Configured instance of this class.
    */
    required init(viewController: ModalBaseViewController) {
        contentNavigationController = UINavigationController(rootViewController: viewController)
        contentNavigationController.navigationBarHidden = true
        contentNavigationController.extendedLayoutIncludesOpaqueBars = true
        contentNavigationController.edgesForExtendedLayout = UIRectEdge.All
        
        super.init(nibName: "ModalViewController", bundle: nil)
        
        contentNavigationController.delegate = self
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Instance methods
    
    /**
    Animate the view controller being dismissed.
    */
    func animateOut() {
        delegate?.modalViewControllerWillDismiss?(self)
        
        if let translationEndpoint = introOutroTranslationEndpoint {
            UIView.animateWithDuration(introAnimationSecondHalfDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.navBar.alpha = 0.0
                let scale = CGAffineTransformMakeScale(self.minimumScalePercentage, self.minimumScalePercentage)
                self.contentNavigationController.view.transform = scale
                
                let translate = CGAffineTransformMakeTranslation(translationEndpoint.x, translationEndpoint.y)
                self.contentContainerView.transform = translate
                
                self.backgroundView.alpha = 0.0
                }) { (finished) -> Void in
                    self.delegate?.modalViewControllerDidDismiss?(self)
                    
                    self.contentNavigationController.view.removeFromSuperview()
                    self.contentNavigationController.willMoveToParentViewController(nil)
                    self.contentNavigationController.removeFromParentViewController()
                    
                    self.view.removeFromSuperview()
                    self.willMoveToParentViewController(nil)
                    self.removeFromParentViewController()
            }
        }
    }
    
    /**
     Present this view controller over the provided parent view controller, and add self.view to
     the parent view controller's view hierarchy.
     
     - parameter parentViewController The parent view controller to add self as a child view 
                                      controller to.
     - parameter sender The view to add self.view to.
     */
    func presentOverViewController(parentViewController: UIViewController, sender: UIView) {
        // Add self as a child to the provided view controller
        view.translatesAutoresizingMaskIntoConstraints = false
        parentViewController.addChildViewController(self)
        parentViewController.view.addSubview(view)
        
        parentViewController.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view" : view]))
        parentViewController.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view" : view]))
        
        // Add the navigation controller as a child to self
        contentNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(contentNavigationController)
        contentContainerView.addSubview(contentNavigationController.view)
        contentNavigationController.didMoveToParentViewController(self)
        
        contentContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view" : contentNavigationController.view]))
        contentContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view" : contentNavigationController.view]))
        
        // Translate the container view
        let convertedFrame = sender.convertRect(sender.bounds, toView: parentViewController.view)
        let convertedCenter = CGPointMake(convertedFrame.origin.x + (convertedFrame.width / 2), convertedFrame.origin.y + (convertedFrame.height / 2) - translationEndpointPadding)
        introOutroTranslationEndpoint = CGPointMake(convertedCenter.x - contentNavigationController.view.center.x, convertedCenter.y - contentNavigationController.view.center.y)
        
        let translate = CGAffineTransformMakeTranslation(introOutroTranslationEndpoint!.x, introOutroTranslationEndpoint!.y)
        contentContainerView.transform = translate
        
        // Scale the navigation controller view
        let scaleDown = CGAffineTransformMakeScale(minimumScalePercentage, minimumScalePercentage)
        contentNavigationController.view.transform = scaleDown
        
        // Two part animation, translate and partially scale in, then fully scale in once centered
        UIView.animateWithDuration(introAnimationFirstHalfDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.backgroundView.alpha = 1.0
            self.contentContainerView.transform = CGAffineTransformIdentity
            
            let partialScale = CGAffineTransformMakeScale(self.partialScalePercentage, self.partialScalePercentage)
            self.contentNavigationController.view.transform = partialScale
        }) { (finished) -> Void in
            UIView.animateWithDuration(self.introAnimationSecondHalfDuration, delay: 0.0, usingSpringWithDamping: self.introAnimationSpringDampening, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.navBar.alpha = 1.0
                self.contentNavigationController.view.transform = CGAffineTransformIdentity
            }) { (finished) -> Void in
                    self.didMoveToParentViewController(parentViewController)
            }
        }
    }
    
    // MARK: UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        
        backgroundView.backgroundColor = AppConfiguration.blue(0.86)
        
        contentContainerView.layer.shadowColor = AppConfiguration.black().CGColor
        contentContainerView.layer.shadowOffset = CGSizeZero
        contentContainerView.layer.shadowOpacity = 0.35
        contentContainerView.layer.shadowRadius = 5.0
    }
}

// MARK: ModalBaseViewControllerDelegate methods

extension ModalViewController: ModalBaseViewControllerDelegate {
    func dismissViewController(viewController: ModalBaseViewController) {
        animateOut()
    }
}

// MARK: UINavigationBarDelegate methods

extension ModalViewController: UINavigationBarDelegate {
    func navigationBar(navigationBar: UINavigationBar, shouldPopItem item: UINavigationItem) -> Bool {
        contentNavigationController.popViewControllerAnimated(true)

        // pushing and popping of UINavigationItems is handled in navigationController:willShowViewController:animated:
        return false
    }
    
    func navigationBar(navigationBar: UINavigationBar, shouldPushItem item: UINavigationItem) -> Bool {
        // pushing and popping of UINavigationItems is handled in navigationController:willShowViewController:animated:
        return false
    }
}

// MARK: UINavigationControllerDelegate methods

extension ModalViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        // when items are pushed/popped from the navigation stack, reset the navigation bar's UINavigationItems to match the new stack.
        var navItems = [UINavigationItem]()

        for viewController in navigationController.viewControllers {
            let navItem = viewController.navigationItem
            navItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
            navItems.append(viewController.navigationItem)
        }
        // don't animate if the items are being added for the first time (this is done on initial display of the nav controller)
        let animated = navBar.items?.count > 0
        navBar.setItems(navItems, animated: animated)

        // set the newly shown view controller as the baseDelegate
        if let modalBaseVC = viewController as? ModalBaseViewController {
            modalBaseVC.baseDelegate = self
        }
    }
}
