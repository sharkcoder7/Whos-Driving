import AddressBookUI
import UIKit

/// Protocol for responding to events in the AddKidViewController.
protocol AddKidViewControllerDelegate: class {
    
    /**
     Called when a new kid is successfully added.
     
     - parameter addKidViewController The AddKidViewController that added the new kid.
     - parameter addedPerson The kid that was added.
     */
    func addedPerson(addKidViewController: AddKidViewController, addedPerson: Person)
}

/// This view controller is used to add a new kid for the current user.
class AddKidViewController: ModalBaseViewController, UINavigationControllerDelegate {
    
    // MARK: Properties
    
    /// Delegate of this class.
    weak var addKidDelegate: AddKidViewControllerDelegate?
    
    /// The image selected by the user to use to create/update the kid.
    var updatedImage: UIImage?
    
    // MARK: Private Properties
    
    /// The ABPeoplePickerNavigationController used for adding a kid from the contact list.
    private let addressBookPickerViewController = ABPeoplePickerNavigationController()
    
    /// The ContactInfoFormatter used by this class.
    private let contactInfoFormatter = ContactInfoFormatter()
    
    /// The UIImagePickerController for selecting an image for the user's avatar.
    private let imagePicker = UIImagePickerController()
    
    // MARK: IBOutlets
    
    /// Label next to the headerButton.
    @IBOutlet weak var addFromContactsLabel: UILabel!
    
    /// Divider line between the header and rest of the content.
    @IBOutlet private weak var dividerLine: UIView!
    
    /// TextField for entering the kid's first name.
    @IBOutlet weak var firstNameField: TextField!
    
    /// Label in the footer.
    @IBOutlet private weak var footerLabel: UILabel!
    
    /// Bottom space constraint between the footer label and the bottom of its superview.
    @IBOutlet private weak var footerLabelBottomConstraint: NSLayoutConstraint!
    
    /// Top space constraint between the footer label and the top of its superview.
    @IBOutlet private weak var footerLabelTopConstraint: NSLayoutConstraint!
    
    /// The button on the right side of the header.
    @IBOutlet weak var headerButton: UIButton!
    
    /// The container view at the top of the view controller.
    @IBOutlet private weak var headerContainerView: UIView!
    
    /// Width constraint for the headerContainerView.
    @IBOutlet private weak var headerContainerWidthConstraint: NSLayoutConstraint!
    
    /// TextField for entering the kid's last name.
    @IBOutlet weak var lastNameField: TextField!
    
    /// Background view in the lower part of the view controller.
    @IBOutlet private weak var lowerBackground: UIView!
    
    /// Container view most of the views below the headerContainerView.
    @IBOutlet private weak var lowerContainerView: UIView!
    
    /// TextField for entering the kid's phone number.
    @IBOutlet weak var mobilePhoneField: TextField!
    
    /// PersonButton for changing the kid's avatar image.
    @IBOutlet weak var profilePhotoButton: PersonButton!
    
    /// Upper background view.
    @IBOutlet private weak var upperBackground: UIView!
    
    // MARK: Init and Deinit Methods
    
    init() {
        super.init(nibName: "AddKidViewController", bundle: nil)
        
        title = NSLocalizedString("Add Kid", comment: "Add Kid view controller title")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private Methods
    
    /**
     Validates that the text in the firstNameField is valid.
     
     - returns: True if the firstNameField has been filled in with valid text.
     */
    private func validateFirstName() -> Bool {
        var textString = firstNameField.text!
        textString = textString.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch)
        
        return textString.characters.count > 0
    }
    
    /**
     Validates that the text in the lastNameField is valid.
     
     - returns: True if the lastNameField has been filled in with valid text.
     */
    private func validateLastName() -> Bool {
        var textString = lastNameField.text!
        textString = textString.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch)
        
        return textString.characters.count > 0
    }
    
    /**
     Validates that the text in the mobilePhoneField is valid.
     
     - returns: True if the mobilePhoneField has been filled in with valid text.
     */
    private func validatePhoneNumber() -> Bool {
        if mobilePhoneField.text?.characters.count == 0 {
            return true
        }
        
        return contactInfoFormatter.validatePhoneString(mobilePhoneField.text!)
    }
    
    /**
     Validates that all the text fields have been filled in with valid text.
     
     - returns: True if all the text fields have valid text.
     */
    func validateFields() -> Bool {
        var errorString: String?
        
        if validateFirstName() == false {
            errorString = "First name is a required field. Please enter a first name."
        } else if validateLastName() == false {
            errorString = "Last name is a required field. Please enter a last name."
        } else if validatePhoneNumber() == false {
            errorString = "Please enter a valid phone number."
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
    Called when the addFromContactsButton is tapped.
    
    - parameter sender The button that was tapped.
    */
    @IBAction func addFromContactsTapped(sender: UIButton) {
        presentViewController(addressBookPickerViewController, animated: true, completion: nil)
    }
    
    /**
     Called when the cancel button is tapped.
     */
    func cancelButtonTapped() {
        baseDelegate?.dismissViewController(self)
    }
    
    /**
     Called when the profilePhotoButton is tapped.
     */
    @objc private func profilePhotoTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == true {
            let takePhotoAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default) { [weak self] (action) -> Void in
                guard let imagePicker = self?.imagePicker else {
                    return
                }
                
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                self?.presentViewController(imagePicker, animated: true, completion: nil)
            }
            actionSheet.addAction(takePhotoAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) == true {
            let photoLibrary = UIAlertAction(title: "Select From Camera Roll", style: UIAlertActionStyle.Default) { [weak self] (action) -> Void in
                guard let imagePicker = self?.imagePicker else {
                    return
                }
                
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
     Called when the save button is tapped.
     */
    func saveButtonTapped() {
        if validateFields() {
            let riders = Riders()
            
            let uploadingVC = UploadingViewController()
            navigationController?.pushViewController(uploadingVC, animated: true)
            
            riders.createHouseholdRider(firstNameField.text!, lastName: lastNameField.text!, phoneNumber: mobilePhoneField.text, image: updatedImage, s3ImageURL: nil, localImageURL: nil) { [weak self] (person, error) -> Void in
                if error != nil {
                    uploadingVC.presentError("Error creating rider. Please try again.", completion: nil)
                } else {
                    if let unwrappedPerson = person {
                        uploadingVC.dismiss()

                        self?.addKidDelegate?.addedPerson(self!, addedPerson: unwrappedPerson)
                    }
                }
            }
        }
    }
    
    // MARK: UIViewController Methods
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerContainerWidthConstraint.constant = view.frame.size.width
        
        // Calculate the padding between the text fields and the instruction text to keep the text pinned to the bottom when space is available
        let verticalPadding = view.frame.height - footerLabelBottomConstraint.constant - footerLabel.frame.height - mobilePhoneField.frame.height - mobilePhoneField.frame.origin.y - headerContainerView.frame.height
        footerLabelTopConstraint.constant = max(16.0, verticalPadding)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dividerLine.backgroundColor = AppConfiguration.lightGray()
        footerLabel.textColor = AppConfiguration.mediumGray()
        headerContainerView.backgroundColor = AppConfiguration.white()
        lowerContainerView.backgroundColor = AppConfiguration.offWhite()
        lowerBackground.backgroundColor = lowerContainerView.backgroundColor
        upperBackground.backgroundColor = headerContainerView.backgroundColor
        
        addressBookPickerViewController.peoplePickerDelegate = self
        imagePicker.delegate = self
        
        profilePhotoButton.populateViewForType(PersonButtonType.AddPhoto)
        let tappedHandler: (PersonButton) -> Void = { [weak self] personButton in
            self?.profilePhotoTapped()
        }
        profilePhotoButton.tappedCompletion = tappedHandler
        
        addFromContactsLabel.textColor = AppConfiguration.darkGray()
        
        let leftButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        
        let rightButton = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
    }
}

// MARK: ABPeoplePickerNavigationControllerDelegate Methods

extension AddKidViewController: ABPeoplePickerNavigationControllerDelegate {
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
        if let firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty) {
            firstNameField.text = firstName.takeRetainedValue() as? String
        }
        
        if let lastName = ABRecordCopyValue(person, kABPersonLastNameProperty) {
            lastNameField.text = lastName.takeRetainedValue() as? String
        }
        
        
        if let unmanagedPhones = ABRecordCopyValue(person, kABPersonPhoneProperty) {
            let phones: ABMultiValueRef = Unmanaged.fromOpaque(unmanagedPhones.toOpaque()).takeUnretainedValue() as NSObject as ABMultiValueRef
            
            if ABMultiValueGetCount(phones) > 0 {
                let unmanagedPhone = ABMultiValueCopyValueAtIndex(phones, 0)
                let phoneString = Unmanaged.fromOpaque(unmanagedPhone.toOpaque()).takeUnretainedValue() as NSObject as! String
                let rawPhoneNumber = contactInfoFormatter.stringFromPhoneString(phoneString)
                let formattedPhoneNumber = contactInfoFormatter.phoneStringFromString(rawPhoneNumber)
                
                mobilePhoneField.text! = formattedPhoneNumber
            }
        }
        
        var image: UIImage?
        if let imageData = ABPersonCopyImageData(person) {
            image = UIImage(data: imageData.takeRetainedValue())
        }
        
        updatedImage = image
        profilePhotoButton.imgView.image = image
        profilePhotoButton.accessoryImgView.hidden = image != nil
    }
}

// MARK: UITextFieldDelegate Methods

extension AddKidViewController {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == mobilePhoneField {
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
                mobilePhoneField.text! = contactInfoFormatter.phoneStringFromString(textFieldText)
            }
            
            return false
        }
        
        return true
    }
}

// MARK: UIImagePickerControllerDelegate Methods

extension AddKidViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        updatedImage = image
        profilePhotoButton.imgView.image = image
        profilePhotoButton.accessoryImgView.hidden = true
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
