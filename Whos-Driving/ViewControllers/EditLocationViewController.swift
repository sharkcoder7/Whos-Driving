import UIKit

/// Protocol defining methods for responding to events in the EditLocationViewController.
protocol EditLocationViewControllerDelegate: class {
    
    /**
     Called when an event is updated.
     
     - parameter viewController The EditLocationViewController sending this method.
     - parameter event The event that was updated.
     */
    func editLocationController(viewController: EditLocationViewController, didUpdateEvent event: Event?)
    
    /**
     Called when an event is deleted.
     
     - parameter viewController The EditLocationViewController sending this method.
     */
    func editLocationControllerDidDeleteEvent(viewController: EditLocationViewController)
}

/// View controller for editing/deleting an event.
class EditLocationViewController: ModalBaseViewController {
    
    // MARK: Public properties
    
    /// Delegate of this class.
    weak var editLocationDelegate: EditLocationViewControllerDelegate?
    
    /// The event being edited.
    var event: Event
    
    // MARK: Private Properties
    
    /// The date formatter for this class.
    private let timeFormatter = NSDateFormatter()
    
    /// View model for this class.
    private let viewModel: DetailsSummaryViewModel!
    
    // MARK: IBOutlets
    
    /// Label showing the current date of the carpool event.
    @IBOutlet private weak var dateLabel: UILabel!
    
    /// Button for deleting the event.
    @IBOutlet private weak var deleteButton: UIButton!
    
    /// Scroll view containing the other views.
    @IBOutlet private weak var editLocationScrollView: UIScrollView!
    
    /// View for editing the end time of the event.
    @IBOutlet private weak var endTimeTextField: TextField!
    
    /// Label above the endTimeTextField.
    @IBOutlet private weak var endTimeTitleLabel: UILabel!
    
    /// View for editing the location of the event.
    @IBOutlet private weak var locationTextField: TextField!
    
    /// Label above the locationTextField.
    @IBOutlet private weak var locationTitleLabel: UILabel!
    
    /// Background view in the lower portion of the view controller.
    @IBOutlet private weak var lowerBackgroundView: UIView!
    
    /// Divider line for the lowerContainerView.
    @IBOutlet private weak var lowerContainerBorderView: UIView!
    
    /// Container view for the form fields.
    @IBOutlet private weak var lowerContainerView: UIView!
    
    /// Divider line for the notesContainerView.
    @IBOutlet private weak var notesContainerBorderView: UIView!
    
    /// Container view for the noteLabel, above the lowerContainerView.
    @IBOutlet private weak var notesContainerView: UIView!
    
    /// Width constraint for the notesContainerView. This constraint is used to control the width of 
    /// the scroll view
    @IBOutlet private weak var noteContainerWidthConstraint: NSLayoutConstraint!
    
    /// Label showing a disclaimer about editing a carpool event.
    @IBOutlet private weak var noteLabel: UILabel!
    
    /// View for editing the start time of the event.
    @IBOutlet private weak var startTimeTextField: TextField!
    
    /// Label above the startTimeTextField.
    @IBOutlet private weak var startTimeTitleLabel: UILabel!
    
    /// Title label.
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: Init Methods
    
    /**
    Creates a new instance of this class.
    
    - parameter event The event being edited.
    - parameter editLocationDelegate The delegate of this class.
    
    - returns: Configured instance of this class.
    */
    required init(event: Event, editLocationDelegate: EditLocationViewControllerDelegate) {
        self.editLocationDelegate = editLocationDelegate
        self.event = event
        viewModel = DetailsSummaryViewModel(event: event)
        super.init(nibName: "EditLocationViewController", bundle: nil)
        
        title = NSLocalizedString("Edit", comment: "The title of the edit location view controller.")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    
    /**
    Called when the background is tapped.
    */
    @objc private func backgroundTapped() {
        locationTextField.resignFirstResponder()
        startTimeTextField.resignFirstResponder()
        endTimeTextField.resignFirstResponder()
    }
    
    /**
     Called when the cancel button is tapped.
     */
    @objc private func cancelButtonTapped() {
        baseDelegate?.dismissViewController(self)
    }

    /**
     Called when the delete button is tapped.
     
     - parameter sender The button that was tapped.
     */
    @IBAction func deleteButtonTapped(sender: UIButton) {
        let alertController = UIAlertController(title: "Delete event?", message: "Are you sure you want to delete this event?", preferredStyle: UIAlertControllerStyle.Alert)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default) { [weak self] (action) -> Void in
            self?.deleteEvent()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     Called when the next button is tapped.
     */
    @objc private func nextButtonTapped() {
        if validateFields() {
            event.location = locationTextField.text
            
            let notifications = NotificationsViewController(event: event)
            notifications.delegate = self
            navigationController?.pushViewController(notifications, animated: true)
        }
    }
    
    // MARK: Private methods
    
    /**
    Called when the user changes the date in either hte startTimeView or endTimeView.
    
    - parameter sender The UIDatePicker that changed.
    */
    @objc private func dateChanged(sender: UIDatePicker) {
        if startTimeTextField.isFirstResponder() == true {
            event.startTime = sender.date
            startTimeTextField.text = timeFormatter.stringFromDate(sender.date)
        }
        else if endTimeTextField.isFirstResponder() == true {
            event.endTime = sender.date
            endTimeTextField.text = timeFormatter.stringFromDate(sender.date)
        }
    }
    
    /**
     Input view for the startTimeView and endTimeView.
     
     - returns: UIDatePicker used as the input view for start/end time views.
     */
    private func datePickerKeyboard() -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .Time
        datePicker.minuteInterval = 5
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return datePicker
    }
    
    /**
     Delete the current event.
     */
    private func deleteEvent() {
        let uploadingVC = UploadingViewController()
        navigationController?.pushViewController(uploadingVC, animated: true)
        
        Events().deleteEventById(event.id) { [weak self] (error) -> Void in
            if error != nil {
                uploadingVC.presentError("Error deleting event. Please try again", completion: nil)
            } else {
                uploadingVC.dismiss()
                
                self?.editLocationDelegate?.editLocationControllerDidDeleteEvent(self!)
            }
        }
    }
    
    /**
     Validate that all the fields are filled in with valid data.
     
     - returns: True if the fields are filled in properly. If false, an alert view is shown.
     */
    private func validateFields() -> Bool {
        var errorString: String?
        
        let locationText = locationTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if locationText.characters.count == 0 {
            errorString = "Please enter a location for the event."
        } else if event.startTime.timeIntervalSinceDate(event.endTime) > 0 {
            errorString = "The end time must be later than the start time."
        }
        
        if let message = errorString {
            let alertController = defaultAlertController(message)
            presentViewController(alertController, animated: true, completion: nil)
            
            return false
        } else {
            return true
        }
    }
    
    // MARK: ModalBaseViewController Methods
    
    override func keyboardWillHide(notification: NSNotification) {
        adjustScrollViewForKeyboardWillHide(editLocationScrollView, notification: notification)
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        if firstResponderView == startTimeTextField || firstResponderView == endTimeTextField {
            adjustScrollViewForKeyboardWillShow(editLocationScrollView, forView: endTimeTextField, notification: notification)
        } else {
            adjustScrollViewForKeyboardWillShow(editLocationScrollView, forView: nil, notification: notification)
        }
    }
    
    // MARK: UIViewController Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeFormatter.dateFormat = "h:mm a"

        let borderColor = AppConfiguration.lightGray()
        lowerContainerBorderView.backgroundColor = borderColor
        notesContainerBorderView.backgroundColor = borderColor
        
        let containerColor = AppConfiguration.offWhite()
        lowerContainerView.backgroundColor = containerColor
        notesContainerView.backgroundColor = containerColor
        lowerBackgroundView.backgroundColor = containerColor
        
        titleLabel.text = viewModel.titleString()
        titleLabel.textColor = AppConfiguration.black()
        dateLabel.attributedText = viewModel.attributedDateTimeStringOfSize(14.0)
        dateLabel.textColor = AppConfiguration.black()
        locationTextField.text = viewModel.locationString()
        locationTitleLabel.textColor = AppConfiguration.darkGray()
        startTimeTitleLabel.textColor = AppConfiguration.darkGray()
        endTimeTitleLabel.textColor = AppConfiguration.darkGray()
        noteLabel.textColor = AppConfiguration.darkGray()
        
        let startDatePicker = datePickerKeyboard()
        startDatePicker.date = event.startTime
        startTimeTextField.inputView = startDatePicker
        startTimeTextField.text = timeFormatter.stringFromDate(event.startTime)
        startTimeTextField.delegate = self

        let endDatePicker = datePickerKeyboard()
        endDatePicker.date = event.endTime
        endTimeTextField.inputView = endDatePicker
        endTimeTextField.text = timeFormatter.stringFromDate(event.endTime)
        endTimeTextField.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
        
        let leftButton = UIBarButtonItem.barButtonForType(.Cancel, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        
        let rightButton = UIBarButtonItem.barButtonForType(.Next, target: self, action: #selector(nextButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
        
        if event.ownerId != Profiles.sharedInstance.currentUserId {
            deleteButton.hidden = true
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        noteContainerWidthConstraint.constant = view.frame.size.width
    }
}

// MARK: NotificationsViewControllerDelegate methods

extension EditLocationViewController : NotificationsViewControllerDelegate {
    func notificationsViewController(viewController: NotificationsViewController, didUpdateEvent: Event?) {
        editLocationDelegate?.editLocationController(self, didUpdateEvent: didUpdateEvent)
    }
}

// MARK: UITextFieldDelegate methods

extension EditLocationViewController {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == startTimeTextField || textField == endTimeTextField {
            // this is to prevent the user from editing the start/end time manually and instead can only use the UIDatePicker
            return false
        }
        
        return true
    }
}
