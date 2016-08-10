import MessageUI
import UIKit

/// View controller for editing the current user's profile.
class EditProfileViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: Private Properties
    
    /// The ContactInfoFormatter for this class.
    private var contactInfoFormatter = ContactInfoFormatter()
    
    /// The InviteSender for this class.
    private var invites: InviteSender?
    
    /// The current user.
    private var person: Person
    
    /// StatePicker for this class.
    private var statePicker = StatePicker()
    
    /// New image selected for the user's avatar.
    private var updatedImage: UIImage?

    // MARK: IBOutlets

    /// View for editing the address line one.
    @IBOutlet private weak var addressLineOneTextField: TextField!

    /// View for editing the address line two.
    @IBOutlet private weak var addressLineTwoTextField: TextField!

    /// View for editing the city.
    @IBOutlet private weak var cityTextField: TextField!

    /// View for editing the email address.
    @IBOutlet private weak var emailTextField: TextField!
    
    /// View for editing the user's first name.
    @IBOutlet private weak var firstNameTextField: TextField!
    
    /// Array of all the TextFields, ordered from upper left to bottom right.
    @IBOutlet var formFields: [TextField]!

    /// View for editing the user's last name.
    @IBOutlet private weak var lastNameTextField: TextField!
    
    /// Shows the user's partner's avatar, or an invite button if they don't have a partner.
    @IBOutlet private weak var partnerPersonButton: PersonButton!

    /// Shows the current user's avatar.
    @IBOutlet private weak var personButton: PersonButton!
    
    /// View for editing the phone number
    @IBOutlet private weak var phoneTextField: TextField!

    /// Scroll view containing all the views.
    @IBOutlet private weak var scrollView: UIScrollView!
    
    /// The button for signing out the current user.
    @IBOutlet private weak var signOutButton: UIButton!
    
    /// View for editing the state.
    @IBOutlet private weak var stateTextField: TextField!
    
    /// View for editing the zip code.
    @IBOutlet private weak var zipTextField: TextField!

    
    // MARK: Init and deinit methods
    
    /**
    Creates a new instance of this class with the provided Person.
    
    - parameter aPerson The person to edit.
    
    - returns: Configured instance of this class.
    */
    required init(aPerson: Person) {
        person = aPerson
        
        super.init(nibName: "EditProfileViewController", bundle: nil)
        
        title = NSLocalizedString("Edit Profile", comment: "Edit profile view title.")
        hidesBottomBarWhenPushed = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private Methods
    
    /**
     Configures inputViews for the form fields.
     */
    private func configureKeyboard() {
        statePicker.delegate = self

        let statePickerView = UIPickerView()
        statePickerView.dataSource = statePicker
        statePickerView.delegate = statePicker
        stateTextField.inputView = statePickerView
    }
    
    /**
     Send a Household invite.
     */
    private func invitePartner() {
        invites = InviteSender(presentingViewController: self, delegate: self)
        invites!.presentInvite(InviteType.Household)
    }
    
    /**
     Bring the user to the next form field in the formFields array.
     */
    private func nextFieldTapped() {
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
    
    /**
     Configures the UI for the current user.
     */
    private func setupViewsForCurrentPerson() {
        personButton.populateViewForPerson(person)
        personButton.nameLabel.text = "Change Photo"
        personButton.nameLabel.textColor = AppConfiguration.blue()
        personButton.nameLabel.sizeToFit()
        
        firstNameTextField.text = person.firstName
        lastNameTextField.text = person.lastName
        emailTextField.text = person.email
        if let phoneNumber = person.phoneNumber {
            phoneTextField.text = contactInfoFormatter.phoneStringFromString(phoneNumber)
        }
        addressLineOneTextField.text = person.address.line1
        addressLineTwoTextField.text = person.address.line2
        cityTextField.text = person.address.city
        stateTextField.text = person.address.state
        zipTextField.text = person.address.zip
        partnerPersonButton.trustedDriverListener = self

        setupPartnerPersonButton(person.partner)
    }

    /**
     Configure the partnerPersonButton for the provided Person.
     
     - parameter partner The current's user partner, or nil if they don't have one.
     */
    private func setupPartnerPersonButton(partner: Person?) {
        if let partner = partner {
            partnerPersonButton.populateViewForPerson(partner)
            partnerPersonButton.nameLabel.numberOfLines = 1
        } else {
            partnerPersonButton.populateViewForType(PersonButtonType.Invite)
            partnerPersonButton.nameLabel.numberOfLines = 0
            partnerPersonButton.nameLabel.text = "Invite\nSpouse/Partner"

            partnerPersonButton.tappedCompletion = { [weak self] personButton in
                self?.invitePartner()
            }
        }
    }
    
    /**
     Validate that all the form fields have been filled out with valid information.
     
     - returns: True if the fields have valid information. An alert view is shown if false.
     */
    func validateFields() -> Bool {
        var errorString: String?
        
        if firstNameTextField.text?.characters.count == 0 || lastNameTextField.text?.characters.count == 0 {
            errorString = "Please enter a first and last name."
        } else if contactInfoFormatter.validateEmail(emailTextField.text!) == false {
            errorString = "A valid email is required. Please enter a valid email address."
        } else if contactInfoFormatter.validatePhoneString(phoneTextField.text!) == false {
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
    
    // MARK: Actions
    
    /**
    Called when the background is tapped.
    */
    @objc private func backgroundTapped() {
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        addressLineOneTextField.resignFirstResponder()
        addressLineTwoTextField.resignFirstResponder()
        cityTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        phoneTextField.resignFirstResponder()
        stateTextField.resignFirstResponder()
        zipTextField.resignFirstResponder()
    }
    
    /**
     Called when the user's avatar is tapped.
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
    Triggered by the UIKeyboardWillChangeFrameNotification.
    
    - parameter notification The notification that was triggered.
    */
    @objc private func keyboardWillChangeFrame(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardEndFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue {
                if let duration: NSTimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
                    UIView.animateWithDuration(duration, animations: { () -> Void in
                        self.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardEndFrame.height, 0.0)
                        self.view.layoutIfNeeded()
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
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    /**
    Called when the save button is tapped.
    */
    @objc private func saveTapped() {
        if validateFields() {
            AnalyticsController().track("Clicked save profile")
            
            let address = Address(line1: addressLineOneTextField.text, line2: addressLineTwoTextField.text, city: cityTextField.text, state: stateTextField.text, zip: zipTextField.text)
            person.address = address
            person.firstName = firstNameTextField.text!
            person.lastName = lastNameTextField.text!
            person.email = emailTextField.text
            person.phoneNumber = phoneTextField.text
            
            let uploadingVC = UploadingViewController(title: title)
            navigationController?.pushViewController(uploadingVC, animated: true)
            
            let profiles = Profiles.sharedInstance
            profiles.updateCurrentUsersProfile(person, image: updatedImage, completion: { (error) -> Void in
                if error != nil {
                    uploadingVC.presentError("Error saving user. Please try again", completion: nil)
                } else {
                    uploadingVC.popTwoViewControllers()
                }
            })
        }
    }
    
    /**
     Called when the signOutButton is tapped.
     
     - parameter sender The button that was tapped.
     */
    @IBAction func signOutTapped(sender: AnyObject) {
        SessionCredentialsHandler.logoutWithFacebook()
        let tabBarVC = tabBarController as! TabBarViewController
        tabBarVC.presentSignIn()
    }
    
    // MARK: UIViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)

        view.backgroundColor = AppConfiguration.offWhite()
        
        let saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem = saveButton
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        let tappedHandler: (PersonButton) -> Void = { [weak self] personButton in
            self?.changePhotoTapped()
        }
        personButton.tappedCompletion = tappedHandler
        personButton.nameLabel.textColor = AppConfiguration.blue()
        
        signOutButton.backgroundColor = AppConfiguration.blue()
        signOutButton.layer.cornerRadius = 3.0
        
        configureKeyboard()
        setupViewsForCurrentPerson()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        backgroundTapped()
    }
}

// MARK: InvitesDelegate methods

extension EditProfileViewController: InviteSenderDelegate {
    func invitesFinished(success: Bool) {
        partnerPersonButton.populateViewForType(PersonButtonType.Invited)
    }
}

// MARK: StatePickerDelegate methods

extension EditProfileViewController: StatePickerDelegate {
    func statePicker(statePicker: StatePicker, pickedState: String) {
        stateTextField.text = pickedState
    }
}

// MARK: TrustedDriverListener methods

extension EditProfileViewController: TrustedDriverListener {
    func trustedDriverWasDeleted(driver: Person) {
        setupPartnerPersonButton(nil)
    }
}

// MARK: UITextViewDelegate methods

extension EditProfileViewController: UITextViewDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneTextField {
            let characterSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
            
            if string.rangeOfCharacterFromSet(characterSet) == nil {
                // Strip the string back to numbers only
                var textFieldText = textField.text!
                textFieldText = contactInfoFormatter.stringFromPhoneString(textFieldText)
                
                if string.characters.count == 0 {
                    // Handle deletions
                    let textFieldConvertedText = textFieldText as NSString
                    let range = NSMakeRange(textFieldConvertedText.length - 1, 1)
                    textFieldText = textFieldConvertedText.stringByReplacingCharactersInRange(range, withString: "")
                }
                else if textFieldText.characters.count < contactInfoFormatter.maximumPhoneNumberLength {
                    // Append the additional string if it is within the max text length limit
                    textFieldText = textFieldText.stringByAppendingString(string)
                }
                
                // Set the text on the text field
                phoneTextField.text = contactInfoFormatter.phoneStringFromString(textFieldText)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nextFieldTapped()
        
        return true
    }
}

// MARK: UIImagePickerControllerDelegate Methods

extension EditProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        updatedImage = image
        personButton.imgView.image = image
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
