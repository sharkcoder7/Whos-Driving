import UIKit

/// Protocol for being informed when a new EventFactory is created and should be uploaded to the server.
protocol CreateEventDelegate: class {
    
    /**
     Called when a new EventFactory is created and is ready to be uploaded to the server.
     
     - parameter factory The EventFactory to use for creating a new event.
     */
    func didCreateEventFactory(factory: EventFactory)
}

/// The first view controller shown when creating a new carpool event. Has form fields for naming
/// the event and specifying the location and start/end date.
class CreateEventViewController: UIViewController {
    
    // MARK: Properties
    
    /// Delegate of this class. This delegate is forwarded to the other view controllers in the
    /// create event process.
    weak var createEventDelegate: CreateEventDelegate?
    
    // MARK: Private properties
    
    /// Array of drivers that can be selected as drivers to or from the event being created. This
    /// array is forward to the other view controllers in the create event process so they don't
    /// need to be reloaded.
    private var drivers = [Person]()
    
    /// The end date of the event.
    private var endDate: NSDate?

    /// Array of riders that can be selected as riders to or from the event being created. This
    /// array is forward to the other view controllers in the create event process so they don't
    /// need to be reloaded.
    private var riders = [Person]()
    
    /// The start date of the event being created.
    private var startDate: NSDate?

    // MARK: IBOutlets
    
    /// Container view for all the form fields.
    @IBOutlet private weak var contentView: UIView!
    
    /// View for entering the end time of the event.
    @IBOutlet private weak var endTimeView: CarpoolTextView!
    
    /// Header view.
    @IBOutlet private weak var headerView: UIView!
    
    /// View for entering the location of the event.
    @IBOutlet private weak var locationView: CarpoolTextView!
    
    /// View for entering the name of the event.
    @IBOutlet private weak var nameView: CarpoolTextView!
    
    /// Scroll view containing all the views.
    @IBOutlet private weak var scrollView: UIScrollView!
    
    /// View for entering the start time of the event.
    @IBOutlet private weak var startTimeView: CarpoolTextView!
    
    // MARK: Private Methods
    
    /**
    Called when the background is tapped.
    */
    @objc private func backgroundTapped() {
        dismissKeyboard()
    }
    
    /**
     Called when the user changes the date in either hte startTimeView or endTimeView.
     
     - parameter sender The UIDatePicker that changed.
     */
    @objc private func dateChanged(sender: UIDatePicker) {
        let dateFormatter = AppConfiguration.displayDateFormatter()
        
        if startTimeView.textField.isFirstResponder() == true {
            startDate = sender.date
            startTimeView.textField.text = dateFormatter.stringFromDate(sender.date)
        }
        else if endTimeView.textField.isFirstResponder() == true {
            endDate = sender.date
            endTimeView.textField.text = dateFormatter.stringFromDate(sender.date)
        }
    }
    
    /**
     Input view for the startTimeView and endTimeView.
     
     - returns: UIDatePicker used as the input view for start/end time views.
     */
    private func datePickerKeyboard() -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.minuteInterval = 5
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return datePicker
    }
    
    /**
     Resigns all the first responders.
     */
    private func dismissKeyboard() {
        nameView.textField.resignFirstResponder()
        locationView.textField.resignFirstResponder()
        startTimeView.textField.resignFirstResponder()
        endTimeView.textField.resignFirstResponder()
    }
    
    /**
     Called when endTimeView begins editing to ensure the end date is set to a later date than the 
     start date.
     
     - parameter sender The endTimeView.
     */
    func endTimeEditingDidBegin(sender: UITextView) {
        // Check to make sure the end date is set to a later date than the start date
        if let start = startDate {
            if endDate == nil {
                endDate = start
            } else if start.timeIntervalSinceDate(endDate!) > 0 {
                endDate = start
            }
            
            let datePicker = sender.inputView as! UIDatePicker
            datePicker.date = endDate!
        }
    }
    
    /**
     Triggered by the UIKeyboardWillChangeFrameNotification.
     
     - parameter notification The notification that was triggered.
     */
    @objc private func keyboardWillChangeFrame(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardEndFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue {
                if let duration: NSTimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
                    UIView.animateWithDuration(duration, animations: { () -> Void in
                        self.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardEndFrame.height, 0.0)
                    })
                }
            }
        }
    }
    
    /**
     Triggered by the UIKeyboardWillHideNotification.
     
     - parameter notification The notification that was triggered.
     */
    @objc private func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let duration: NSTimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
                UIView.animateWithDuration(duration, animations: { () -> Void in
                    self.scrollView.contentInset = UIEdgeInsetsZero
                })
            }
        }
    }
    
    /**
     Called when the next button is tapped.
     */
    @objc private func nextTapped() {
        if validateFields() {
            AnalyticsController().track("Completed event details screen", context: .CreateCarpool, properties: nil)

            let eventFactory = EventFactory()
            eventFactory.name = nameView.textField.text
            eventFactory.location = locationView.textField.text
            eventFactory.startTime = startDate
            eventFactory.endTime = endDate
            
            let createEventDriverVC = CreateEventDriverViewController(eventFactory: eventFactory, drivers: drivers, riders: riders, isDrivingTo: true)
            createEventDriverVC.createEventDelegate = createEventDelegate
            navigationController?.pushViewController(createEventDriverVC, animated: true)
        }
    }
    
    /**
     Validates that all the form fields have been filled out properly. If not, an alert view is 
     shown.
     
     - returns: True if all the fields have filled out properly.
     */
    private func validateFields() -> Bool {
        var errorString: String?
        
        let trimmedEventName = nameView.textField.text?.trimmedString()
        let trimmedLocation = locationView.textField.text?.trimmedString()
        
        if trimmedEventName?.characters.count == 0 {
            errorString = "Please enter a name for this event."
        } else if trimmedLocation?.characters.count == 0 {
            errorString = "Please enter a location for this event."
        } else if startDate == nil {
            errorString = "Please enter a start date for this event."
        } else if endDate == nil {
            errorString = "Please enter an end date for this event."
        } else if startDate!.timeIntervalSinceDate(endDate!) > 0 {
            errorString = "The end date must be later than the start date."
        }
        
        if let message = errorString {
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            presentViewController(alertController, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    // MARK: UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.backgroundColor = AppConfiguration.blue()
        view.backgroundColor = AppConfiguration.offWhite()
        contentView.backgroundColor = AppConfiguration.offWhite()
        
        title = NSLocalizedString("New carpool", comment: "Create new carpool view controller title")
        view.backgroundColor = AppConfiguration.offWhite()
        
        let nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(nextTapped))
        navigationItem.rightBarButtonItem = nextButton
        
        let backButton = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        startTimeView.textField.inputView = datePickerKeyboard()
        startTimeView.textField.delegate = self
        endTimeView.textField.inputView = datePickerKeyboard()
        endTimeView.textField.delegate = self
        
        endTimeView.textField.addTarget(self, action: #selector(endTimeEditingDidBegin(_:)), forControlEvents: UIControlEvents.EditingDidBegin)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
        
        Riders().getTrustedRiders(excludeHouseholdRiders: false, includeHouseholdDrivers: true) { [weak self] (riders, error) -> Void in
            self?.riders = riders
        }
        
        Profiles.sharedInstance.getCurrentUserAndPartner { [weak self] (userAndPartner, error) -> Void in
            if let unwrappedUserAndPartner = userAndPartner {
                self?.drivers = unwrappedUserAndPartner
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: UITextFieldDelegate methods

extension CreateEventViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == startTimeView.textField || textField == endTimeView.textField {
            // this is to prevent the user from editing the start/end time manually and instead can only use the UIDatePicker
            return false
        }
        
        return true
    }
}
