import UIKit

/// View controller used for setting up the current user's contact info.
class SetupContactInfoViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: Properties
    
    /// Used to obtain the contact information for a user who signs-in to the app. Defaults to an
    /// instance of UserContactInfoStrategy.
    var contactInfoStrategy: ContactInfoStrategy = UserContactInfoStrategy()
    
    // MARK: Private properties
    
    /// ContactInfoFormatter for this class.
    private let contactInfoFormatter = ContactInfoFormatter()

    /// The current first responder.
    private var firstResponderField: UIView?

    /// StatePicker used for selecting the user's state.
    private var statePicker = StatePicker()
    
    /// Updated avatar image for the user.
    private var updatedImage: UIImage?
    
    // MARK: IBOutlets

    /// View for entering the user's address line one.
    @IBOutlet private weak var addressLine1TextField: TextField!
    
    /// View for entering the user's address line two.
    @IBOutlet private weak var addressLine2TextField: TextField!
    
    /// View for entering the user's city.
    @IBOutlet private weak var cityTextField: TextField!
    
    /// View for entering the user's email address.
    @IBOutlet private weak var emailTextField: TextField!
    
    /// Array of all the TextFields in the view.
    @IBOutlet private var formFields: [TextField]!
    
    /// Horizontal spacing constraint for the headerContainerView.
    @IBOutlet private weak var headerContainerLeftConstraint: NSLayoutConstraint!
    
    /// View at the top of the view controller.
    @IBOutlet private weak var headerContainerView: UIView!
    
    /// Width constraint for the headerContainerView.
    @IBOutlet private weak var headerContainerWidthConstraint: NSLayoutConstraint!
    
    /// View for entering the user's phone number.
    @IBOutlet private weak var mobilePhoneTextField: TextField!
    
    /// PersonButton showing the user's avatar and name.
    @IBOutlet private weak var profileImageButton: PersonButton!
    
    /// Scroll view containing all the views.
    @IBOutlet private weak var scrollView: UIScrollView!
    
    /// Vertical spacing of the scroll view and its super view.
    @IBOutlet private weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    /// View for entering the user's state.
    @IBOutlet private weak var stateTextField: TextField!
    
    /// Label above the first set of form fields.
    @IBOutlet private weak var title1Label: UILabel!
    
    /// Label above the second set of form fields.
    @IBOutlet private weak var title2Label: UILabel!
    
    /// Label showing a message welcoming the user to the app.
    @IBOutlet private weak var welcomeLabel: UILabel!
    
    /// Label showing more welcome messaging to the user.
    @IBOutlet private weak var welcomeSubheadingLabel: UILabel!
    
    /// View for entering the user's zip code.
    @IBOutlet private weak var zipTextField: TextField!
    
    // MARK: Action methods
    
    /**
    Called when the background is tapped.
    */
    func backgroundTapped() {
        addressLine1TextField.resignFirstResponder()
        addressLine2TextField.resignFirstResponder()
        cityTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        mobilePhoneTextField.resignFirstResponder()
        stateTextField.resignFirstResponder()
        zipTextField.resignFirstResponder()
    }
    
    /**
     Called when the profileImageButton is tapped.
     */
    private func changePhotoTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == true {
            let takePhotoAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default) { [weak self] (action) -> Void in
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                self?.presentViewController(imagePicker, animated: true, completion: nil)
            }
            actionSheet.addAction(takePhotoAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) == true {
            let photoLibrary = UIAlertAction(title: "Select From Camera Roll", style: UIAlertActionStyle.Default) { [weak self] (action) -> Void in
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self?.presentViewController(imagePicker, animated: true, completion: nil)
            }
            actionSheet.addAction(photoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
        actionSheet.addAction(cancelAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    /**
     Called when the next button is tapped.
     */
    func nextTapped() {
        if validateFields() {
            let setupFamilyViewController = SetupFamilyViewController(address1: addressLine1TextField.text!, address2: addressLine2TextField.text!, city: cityTextField.text!, email: emailTextField.text!, image: updatedImage, mobileNumber: mobilePhoneTextField.text!, state: stateTextField.text!, zip: zipTextField.text!)
            navigationController?.pushViewController(setupFamilyViewController, animated: true)
        }
    }
    
    // MARK: Instance methods
    
    /**
    Triggered by the UIKeyboardWillChangeFrameNotification.
    
    - parameter notification The notification that was triggered.
    */
    func keyboardWillChangeFrame(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardEndFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue {
                if let duration: NSTimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
                    UIView.animateWithDuration(duration, animations: { () -> Void in
                        self.scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardEndFrame.height, right: 0.0)
                    })
                }
            }
        }
    }
    
    /**
     Triggered by the UIKeyboardWillHideNotification.
     
     - parameter notification The notification that was triggered.
     */
    func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let duration: NSTimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
                UIView.animateWithDuration(duration, animations: { () -> Void in
                    self.scrollView.contentInset = UIEdgeInsetsZero
                })
            }
        }
    }
    
    /**
     Move the first responder to the next form field.
     */
    func nextFieldTapped() {
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
    }
    
    // MARK: Private methods
    
    /**
    Configures input views of any form fields that use a custom input view.
    */
    private func keyboardConfiguration() {
        let statePickerView = UIPickerView()
        statePickerView.dataSource = statePicker
        statePickerView.delegate = statePicker
        stateTextField.inputView = statePickerView
        statePicker.delegate = self
    }
    
    /**
     Validates that all the fields are filled out with valid information.
     
     - returns: True if all the fields are valid. If false, will show an alert view.
     */
    private func validateFields() -> Bool {        
        var errorString: String?
        
        if contactInfoFormatter.validateEmail(emailTextField.text!) == false {
            errorString = "A valid email is required to register. Please enter a valid email address."
        } else if contactInfoFormatter.validatePhoneString(mobilePhoneTextField.text!) == false {
            errorString = "Please enter a valid phone number."
        } else if contactInfoFormatter.validateZip(zipTextField.text!) == false {
            errorString = "Please enter a valid zip code."
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
    
    // MARK: UIViewController methods
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerContainerWidthConstraint.constant = view.frame.width - (headerContainerLeftConstraint.constant * 2)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Welcome!", comment: "Welcome screen title")
        
        navigationController?.delegate = nil
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        navigationItem.hidesBackButton = true
        
        let nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(nextTapped))
        navigationItem.rightBarButtonItem = nextButton
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
        
        headerContainerView.backgroundColor = AppConfiguration.green()
        headerContainerView.layer.borderColor = AppConfiguration.lightGray().CGColor
        headerContainerView.layer.borderWidth = AppConfiguration.borderWidth()
        
        scrollView.backgroundColor = AppConfiguration.offWhite()
        title1Label.textColor = AppConfiguration.darkGray()
        title2Label.textColor = AppConfiguration.darkGray()
        welcomeLabel.textColor = AppConfiguration.white()
        welcomeSubheadingLabel.textColor = AppConfiguration.white()
        
        let tappedHandler: (PersonButton) -> Void = { [weak self] personButton in
            self?.changePhotoTapped()
        }
        profileImageButton.tappedCompletion = tappedHandler
        profileImageButton.name = ""
        profileImageButton.nameLabel.textColor = AppConfiguration.white()
        profileImageButton.nameLabel.font = UIFont(name: Font.HelveticaNeueBold, size: 14.0)
        
        contactInfoStrategy.getContactInfo {
            [weak self] avatarURLString, email, name, phoneNumber in
            self?.emailTextField.text = email
            self?.profileImageButton.name = name
            self?.mobilePhoneTextField.text = self?.contactInfoFormatter.phoneStringFromString(phoneNumber)
            
            guard let avatarURLString = avatarURLString else {
                return
            }
            
            let URL = NSURL(string: avatarURLString)
            ImageController.sharedInstance.loadImageURL(URL, userID: nil, completion: {
                image, error in
                self?.profileImageButton.imgView.image = image
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        keyboardConfiguration()
        
        scrollViewBottomConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsController().screen("Create user setup contact info")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        backgroundTapped()
    }
}

// MARK: StatePickerDelegate methods

extension SetupContactInfoViewController: StatePickerDelegate {
    func statePicker(statePicker: StatePicker, pickedState: String) {
        stateTextField.text = pickedState
    }
}

// MARK: UIImagePickerControllerDelegate methods

extension SetupContactInfoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        updatedImage = image
        profileImageButton.imgView.image = image
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: UITextFieldDelegate methods

extension SetupContactInfoViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == mobilePhoneTextField {
            let characterSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
            
            if string.rangeOfCharacterFromSet(characterSet) == nil {
                // Strip the string back to numbers only
                var textFieldText = textField.text
                textFieldText = contactInfoFormatter.stringFromPhoneString(textFieldText!)
                
                if string.characters.count == 0 {
                    // Handle deletions
                    let textFieldConvertedText = textFieldText! as NSString
                    let range = NSMakeRange(textFieldConvertedText.length - 1, 1)
                    textFieldText = textFieldConvertedText.stringByReplacingCharactersInRange(range, withString: "")
                }
                else if textFieldText?.characters.count < contactInfoFormatter.maximumPhoneNumberLength {
                    // Append the additional string if it is within the max text length limit
                    textFieldText = textFieldText!.stringByAppendingString(string)
                }
                
                // Set the text on the text field
                mobilePhoneTextField.text = contactInfoFormatter.phoneStringFromString(textFieldText!)
            }
            
            return false
        } else if textField == zipTextField {
            if zipTextField.text?.characters.count == contactInfoFormatter.maximumZipCharacters &&
                string.characters.count > 0 {
                    // Return false if the field is at its max and the inserting character is not a delete
                    return false
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if firstResponderField == nil {
            scrollView.setContentOffset(CGPointMake(0.0, CGRectGetMaxY(headerContainerView.frame)), animated: true)
        }
        
        firstResponderField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        firstResponderField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nextFieldTapped()
        
        return true
    }
}
