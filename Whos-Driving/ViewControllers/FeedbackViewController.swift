import UIKit

/// View controller for sending feedback to the owner's of the app.
class FeedbackViewController: UIViewController {

    // MARK: IBOutlets
    
    /// View for entering feedback to send.
    @IBOutlet private weak var textView: TextView!
    
    // Private methods
    
    /**
    Called when the send button is tapped.
    */
    @objc private func sendTapped() {
        if validateFields() {
            let uploadingVC = UploadingViewController(title: title)
            navigationController?.pushViewController(uploadingVC, animated: true)
            
            Feedback().sendFeedback(textView.text!) { (error) -> Void in
                if error != nil {
                    uploadingVC.presentError("Error sending feedback. Please try again.", completion: nil)
                } else {
                    uploadingVC.popTwoViewControllers()
                }
            }
        }
    }
    
    /**
     Validates the text entered is valid.
     
     - returns: True if the text entered is valid. If false, shows an alert view.
     */
    private func validateFields() -> Bool {
        let trimmedText = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if trimmedText.characters.count > 0 {
            return true
        }
        
        let alertController = defaultAlertController("Please enter some feedback!")
        presentViewController(alertController, animated: true, completion: nil)
        
        return false
    }
    
    // MARK: UIViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Feedback"
        
        let sendButton = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(sendTapped))
        navigationItem.rightBarButtonItem = sendButton
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
    }
}
