import UIKit

/// Defines methods for responding to events in the EditRiderViewController.
protocol EditRiderViewControllerDelegate: class {
    
    /**
     Called when a rider is deleted.
     
     - parameter viewController The EditRiderViewController sending the method.
     - parameter uploadingViewController The UploadingViewController that was shown during the upload
                                         to the server. Should be dismissed by the delegate.
     - parameter rider The rider that was deleted.
     */
    func editRiderViewControllerDidDeleteRider(viewController: EditRiderViewController, uploadingViewController: UploadingViewController, rider: Person)
    
    /**
     Called when a rider is edited.
     
     - parameter viewController The EditRiderViewController sending the method.
     - parameter rider The rider that was edited.
     */
    func editRiderViewControllerDidEditRider(viewController: EditRiderViewController, rider: Person)
}

/// View controller for editing the details of a rider.
class EditRiderViewController: AddKidViewController {
    
    // MARK: Properties
    
    /// Delegate for this class.
    weak var delegate: EditRiderViewControllerDelegate?

    // MARK: Private properties
    
    /// The rider being edited.
    var rider: Person
    
    // MARK: Init and deinit methods
    
    /**
    Creates a new instance of this class.
    
    - parameter rider The rider to be edited.
    
    - returns: Configured instance of this class.
    */
    required init(rider: Person) {
        self.rider = rider
        
        super.init()
        
        title = NSLocalizedString("Edit", comment: "Edit rider profile view title.")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    
    /**
    Called when the background is tapped.
    */
    @objc private func backgroundTapped() {
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        mobilePhoneField.resignFirstResponder()
    }
    
    /**
     Called when the cancel button is tapped.
     */
    override func cancelButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    /**
     Called when the delete button is tapped.
     
     - parameter sender The button that was tapped.
     */
    @objc private func deleteButtonTapped(sender: UIButton) {
        let alertController = UIAlertController(title: "Permanently delete?", message: "This person will be removed permanently. Any other family members and drivers who see this kid will also be affected.", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default) { [weak self] (action) -> Void in
            guard let strongSelf = self else {
                return
            }
            
            let uploadingVC = UploadingViewController()
            strongSelf.navigationController?.pushViewController(uploadingVC, animated: true)
            
            Riders().deleteHouseholdRider(strongSelf.rider.id, completion: { [weak self] (error) -> Void in
                if error != nil {
                    uploadingVC.presentError("There was an error deleting the rider. Please try again.", completion: nil)
                } else {
                    self?.delegate?.editRiderViewControllerDidDeleteRider(self!, uploadingViewController: uploadingVC, rider: self!.rider)
                }
            })
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     Called when the save button is tapped.
     */
    override func saveButtonTapped() {
        print("save rider's profile tapped")
        
        if super.validateFields() {
            rider.firstName = firstNameField.text!
            rider.lastName = lastNameField.text!
            rider.phoneNumber = mobilePhoneField.text
            
            let uploadingVC = UploadingViewController()
            navigationController?.pushViewController(uploadingVC, animated: true)
            
            Riders().updateHouseholdRider(rider, image: updatedImage, completion: { [weak self] (error) -> Void in
                if error != nil {
                    uploadingVC.presentError("There was an error updating the rider. Please try again.", completion: nil)
                } else {
                    uploadingVC.popTwoViewControllers()
                    
                    self?.delegate?.editRiderViewControllerDidEditRider(self!, rider: self!.rider)
                }
            })
        }
    }
    
    // MARK: UIViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftButton = UIBarButtonItem.barButtonForType(.Cancel, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        
        let rightButton = UIBarButtonItem.barButtonForType(.Save, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        profilePhotoButton.populateViewForPerson(rider)
        profilePhotoButton.nameLabel.text = "Change Photo"
        profilePhotoButton.nameLabel.textColor = AppConfiguration.blue()
        ImageController.sharedInstance.loadImageForPerson(rider) { [weak self] (image, error) -> Void in
            self?.profilePhotoButton.accessoryImgView.hidden = image != nil
            self?.profilePhotoButton.imgView.image = image
        }
        
        firstNameField.text = rider.firstName
        lastNameField.text = rider.lastName
        
        if let phoneString = rider.phoneNumber {
            mobilePhoneField.text = ContactInfoFormatter().phoneStringFromString(phoneString)
        }

        addFromContactsLabel.text = nil
        
        headerButton.setImage(UIImage(named: "trash"), forState: UIControlState.Normal)
        headerButton.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
        headerButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
    }
}
