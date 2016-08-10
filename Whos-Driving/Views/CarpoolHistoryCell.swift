import UIKit

/// Subclass of UITableViewCell used for displaying an EventHistoryItem.
class CarpoolHistoryCell: UITableViewCell {
    
    // MARK: Constants
    
    /// The cell resuse identifier.
    static let reuseId = "CarpoolHistoryCellReuseId"

    // MARK: Outlets

    /// Label displaying the date of the history item.
    @IBOutlet weak var dateLabel: UILabel!
    
    /// Label displaying the description of the history item.
    @IBOutlet weak var messageLabel: UILabel!
    
    /// PersonButton showing the avatar of the author of the history item.
    @IBOutlet weak var personButton: PersonButton!
    
    // MARK: Instance methods
    
    /**
    Configures the UI for the provided EventHistoryItem.
    
    - parameter item The item used to configure the UI in the view.
    */
    func configureForItem(item: EventHistoryItem) {
        let viewModel = CarpoolHistoryCellViewModel(item: item)
        
        dateLabel.text = viewModel.dateLabelText()
        messageLabel.attributedText = viewModel.messageAttributedText()
        personButton.firstLetterLabel.text = viewModel.firstLetterText()
        
        if let urlString = item.authorImageUrl {
            let url = NSURL(string: urlString)
            ImageController.sharedInstance.loadImageURL(url, userID: item.authorId, completion: { [weak self] (image, error) -> Void in
                self?.personButton.imgView.image = image
            })
        }
    }
    
    // MARK: UIView methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dateLabel.textColor = AppConfiguration.darkGray()
    }
}
