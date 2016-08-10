import UIKit

/// Defines methods for responding to events in the ModalBaseViewController
protocol ModalBaseViewControllerDelegate: class {
    
    /**
     Called when the modal view controller should be dismissed.
     
     - parameter viewController The ModalBaseViewController sending this method.
     */
    func dismissViewController(viewController: ModalBaseViewController)
}

/// The base class for all of the view controllers shown in a focus frame. This class should not be 
/// used as is.
class ModalBaseViewController: UIViewController {
    
    // MARK: Properties
    
    /// Delegate of this class.
    weak var baseDelegate: ModalBaseViewControllerDelegate?
    
    /// The current first responder.
    var firstResponderView: UIView?
    
    // MARK: IBOutlets
    
    /// Array of all the form fields.
    @IBOutlet private var formFields: [UITextField]!
    
    /// The scroll view containing the other views.
    @IBOutlet weak var scrollView: UIScrollView?
    
    /// Bottom constraint for the scroll view and its super view.
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint?
    
    // MARK: Instance Methods
    
    /**
    Adjusts the provided scroll view's content inset to UIEdgeInsetsZero, animated using the duration
    of the keyboard hiding animation.
    
    - parameter scrollView The scroll view to adjust.
    - parameter notification The notification from the OS triggered by the keyboard hiding.
    */
    func adjustScrollViewForKeyboardWillHide(scrollView: UIScrollView, notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let duration: NSTimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else {
            return
        }

        UIView.animateWithDuration(duration, animations: { () -> Void in
            scrollView.contentInset = UIEdgeInsetsZero
        })
    }
    
    /**
     Adjusts the provided scroll view's content inset to accomodate the keyboard being shown. Uses the
     animation duration of the keyboard showing animation.
     
     - parameter scrollView The scroll view to adjust.
     - parameter forView The view to scroll into view. If nil, defaults to firstResponderView.
     - parameter notification The notification from the OS triggered by the keyboard showing.
     */
    func adjustScrollViewForKeyboardWillShow(scrollView: UIScrollView, forView: UIView?, notification: NSNotification) {
        guard let keyboardEndFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue else {
            dLog("No keyboard end frame. Returning.")
            return
        }
        guard let modalContainerViewController = parentViewController?.parentViewController else {
            dLog("No modal container view controller. Returning.")
            return
        }
        guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue else {
            dLog("No keyboard animation duration. Returning.")
            return
        }
        
        let viewToShow: UIView
        if let unwrappedForView = forView {
            viewToShow = unwrappedForView
        } else if let unwrappedFirstResponder = firstResponderView {
            viewToShow = unwrappedFirstResponder
        } else {
            dLog("No view to adjust scroll view for. Must provide forView parameter, or have a valid firstResponderView. Returning.")
            return
        }
        
        // Calculate how much to adjust the content inset
        let convertedViewFrame = view.convertRect(view.bounds, toView: modalContainerViewController.view)
        let bottomGap = modalContainerViewController.view.bounds.height - CGRectGetMaxY(convertedViewFrame)
        let bottomContentInset = keyboardEndFrame.height - bottomGap
        let contentInset = UIEdgeInsetsMake(0, 0, bottomContentInset, 0)
        
        // Calculate how much the scroll view needs to be adjusted so bottom of viewToShow is visible
        let convertedFieldFrame = scrollView.convertRect(viewToShow.frame, fromView: viewToShow.superview)
        let scrollViewHeight = scrollView.frame.size.height
        let scrollViewAdjustedHeight = scrollViewHeight - bottomContentInset
        let maxYPadding: CGFloat = 5.0
        let maxY = CGRectGetMaxY(convertedFieldFrame) + maxYPadding
        var contentOffset: CGPoint?
        if maxY > scrollViewAdjustedHeight {
            let offsetY = maxY - scrollViewAdjustedHeight
            contentOffset = CGPointMake(0.0, offsetY)
        }
        
        UIView.animateWithDuration(duration, animations: { () -> Void in

            scrollView.contentInset = contentInset
            if let unwrappedOffset = contentOffset {
                scrollView.setContentOffset(unwrappedOffset, animated: false)
            }
        })
    }
    
    /**
     Triggered by the UIKeyboardWillHideNotification.
     
     - parameter notification The notification that was triggered.
     */
    func keyboardWillHide(notification: NSNotification) {
        if let scrollView = scrollView {
            adjustScrollViewForKeyboardWillHide(scrollView, notification: notification)
        }
    }
    
    /**
     Triggered by the UIKeyboardWillShowNotification.
     
     - parameter notification The notification that was triggered.
     */
    func keyboardWillShow(notification: NSNotification) {
        if let scrollView = scrollView {
            adjustScrollViewForKeyboardWillShow(scrollView, forView: nil, notification: notification)
        }
    }
    
    // MARK: UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = UIRectEdge.Bottom
        extendedLayoutIncludesOpaqueBars = true
        
        view.clipsToBounds = true
        view.layer.borderColor = AppConfiguration.lightGray().CGColor
        view.layer.borderWidth = AppConfiguration.borderWidth()
        view.layer.cornerRadius = 2.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: UITextFieldDelegate Methods

extension ModalBaseViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        firstResponderView = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        firstResponderView = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        for textField in formFields {
            if textField.isFirstResponder() {
                if let nextField = formFields.filter({$0.tag == textField.tag + 1}).first {
                    nextField.becomeFirstResponder()
                    break;
                } else {
                    textField.resignFirstResponder()
                }
            }
        }
        
        return true
    }
}

// MARK: UITextViewDelegate methods

extension ModalBaseViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        firstResponderView = textView
        
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        firstResponderView = nil
        
        return true
    }
}

// MARK: UIBarButtonItem extension

extension UIBarButtonItem {
    enum BarButtonType {
        case Add
        case Cancel
        case Close
        case DontSend
        case Edit
        case History
        case Next
        case None
        case Save
        case Send
    }
    
    /**
     Convenience method to create a UIBarButtonItem configured by the BarButtonType type provided.
     
     - parameter buttonType The style of the button.
     - parameter target The target called when the button is tapped.
     - parameter action The selector called on the target when the button is tapped.
     
     - returns: A configured UIBarButtonItem
     */
    class func barButtonForType(buttonType: BarButtonType, target: NSObject?, action: Selector) -> UIBarButtonItem {
        let barButtonItem: UIBarButtonItem
        
        var image: UIImage?
        var titleString = " "
        
        switch (buttonType) {
            
        case .Add:
            image = UIImage(named: "nav-add")
            
        case .Cancel:
            titleString = NSLocalizedString("Cancel", comment: "Cancel modal button title")
            
        case .Close:
            image = UIImage(named: "nav-close")
            
        case .DontSend:
            titleString = NSLocalizedString("Don't Notify", comment: "Don't Send modal button title")
            
        case .Edit:
            image = UIImage(named: "nav-edit")
            
        case .Next:
            titleString = NSLocalizedString("Next", comment: "Next modal button title")
            
        case .None:
            break;
            
        case .History:
            image = UIImage(named: "nav-history")
            
        case .Save:
            titleString = NSLocalizedString("Save", comment: "Save modal button title")
            
        case .Send:
            titleString = NSLocalizedString("Send", comment: "Send modal button title")
        }
        
        if let image = image {
            barButtonItem = UIBarButtonItem(image: image, style: .Plain, target: target, action: action)
        } else {
            barButtonItem = UIBarButtonItem(title: titleString, style: .Plain, target: target, action: action)
        }
        
        return barButtonItem
    }
}
