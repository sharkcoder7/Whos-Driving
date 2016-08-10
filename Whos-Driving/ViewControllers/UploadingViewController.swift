import UIKit

/// This view controller is displayed when there's a background process happening with the server.
///
/// The view controller has no logic for dismissing itself. Instead, it's the responsibility of the
/// view controller that created the UploadingViewController to dismiss this view. It's recommended to
/// use one of the instance methods for dismissal. These methods are setup to wait a minimum amount 
/// of time before being called to allow the loading animation to be seen by the user.
class UploadingViewController: ModalBaseViewController {
    
    // MARK: Constants
    
    private let MinimumAnationDuration: NSTimeInterval = 2.0
    
    // MARK: Private properties
    
    /// When an instance method is called but animationHasRun is false, the method is instead added
    /// to this completion block. When the loading animation has run for the minimum duration this
    /// completion block is called. If it's nil, nothing happens. Only the most recent instance 
    /// method called will be saved here.
    private var animationCompletionBlock: (() -> (Void))?
    
    /// True if the loading animation has run for the minimum amount of time. If false, the view
    /// controller will save the latest instance method called on it in animationCompletionBlock to 
    /// be called when the loading animation has finished running for the minimum time.
    private var animationHasRun = false
    
    // MARK: IBOutlets

    /// Loading spinner shown while the communication with the server is taking place.
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Init Methods
    
    /**
    Creates a new instance of this class.
    
    - parameter title The title for the view controller.
    
    - returns: Configured instance of this class.
    */
    required init(title: String? = "") {
        super.init(nibName: "UploadingViewController", bundle: nil)
        
        self.title = title
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Instance methods
    
    /**
    Dismisses all the modally presented views. 
    
    If animationHasRun is false, this method will instead be called after the animation has run the 
    minimum duration.
    */
    func dismiss() {
        if animationHasRun {
            baseDelegate?.dismissViewController(self)
        } else {
            animationCompletionBlock = ({ [weak self] () -> (Void) in
                self?.dismiss()
            })
        }
    }
    
    /**
    Pops the top 2 view controllers off the navigation controller's stack. If there aren't enough
    view controllers, just pops 1 view controller.
    
    If animationHasRun is false, this method will instead be called after the animation has run the
    minimum duration.
    */
    func popTwoViewControllers() {
        if animationHasRun {
            let count = navigationController?.viewControllers.count
            if count >= 3 {
                if let viewControllerTwoBack = navigationController?.viewControllers[count! - 3] {
                    navigationController?.popToViewController(viewControllerTwoBack, animated: true)
                }
            } else {
                navigationController?.popViewControllerAnimated(true)
            }
        } else {
            animationCompletionBlock = ({ [weak self] () -> (Void) in
                self?.popTwoViewControllers()
            })
        }
    }
    
    /**
    Pops the navigation controller to its root view controller.
    
    If animationHasRun is false, this method will instead be called after the animation has run the
    minimum duration.
    */
    func popToRootViewController() {
        if animationHasRun {
            navigationController?.popToRootViewControllerAnimated(true)
        } else {
            animationCompletionBlock = ({ [weak self] () -> (Void) in
                self?.popToRootViewController()
            })
        }
    }
    
    /**
    Displays an alert controller with the provided error message. When the user taps OK, this view
    controller is popped from the navigation stack.
    
    If animationHasRun is false, this method will instead be called after the animation has run the
    minimum duration.
    
    - parameter errorMessage The message to display in the alert controller.
    - parameter completion Completion block to be called when the user dismisses the alert 
                           controller. If nil, defaults to pop the top view controller off the 
                           navigation stack.
    */
    func presentError(errorMessage: String, completion: (() -> Void)?) {
        activityIndicator.stopAnimating()
        
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { [weak self] (action) -> Void in
            if completion != nil {
                completion!()
            } else {
                self?.navigationController?.popViewControllerAnimated(true)
            }
        })
        alertController.addAction(dismissAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
    Pushes the provided view controller onto the navigation stack.
    
    If animationHasRun is false, this method will instead be called after the animation has run the
    minimum duration.
    
    - parameter viewController The view controller to pop onto the stack.
    */
    func pushViewController(viewController: UIViewController) {
        if animationHasRun {
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            animationCompletionBlock = ({ [weak self] () -> (Void) in
                self?.pushViewController(viewController)
            })
        }
    }
    
    // MARK: Private methods
    
    /**
    Starts the loading animation and sets a timer. Instance methods called before this timer fires
    are instead added to the animationCompletionBlock instead of being immediately called.
    */
    private func startLoadingAnimation() {
        animationHasRun = false
        NSTimer.scheduledTimerWithTimeInterval(MinimumAnationDuration, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)
    }
    
    /**
    Called when the loading animation has run for the minimum amount of time. If any instance methods
    were assigned to the animationCompletionBlock, they're called when this method is called.
    */
    @objc private func timerFired() {
        animationHasRun = true
        if animationCompletionBlock != nil {
            animationCompletionBlock!()
            animationCompletionBlock = nil
        }
    }
    
    // MARK: UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppConfiguration.offWhite()

        startLoadingAnimation()
        
        navigationItem.hidesBackButton = true
    }
}
