import UIKit

/**
 *  Delegate for the ResponseConfirmationView, responsible for responding to certain events.
 */
protocol ResponseConfirmationViewDelegate: class {
    
    /**
     Called when the dismiss button is tapped.
     
     - parameter responseConfirmationView The sender of this method.
     */
    func responseConfirmationViewDismissButtonTapped(responseConfirmationView: ResponseConfirmationView)
}

/// This class shows an image and text showing details of the response from the server after a user
/// submits a driver status.
class ResponseConfirmationView: UIView {
    
    // MARK: Properties
    
    /// The delegate of this class.
    weak var delegate: ResponseConfirmationViewDelegate?
    
    // MARK: IBOutlets
    
    /// Image view centered in the view.
    @IBOutlet weak var imageView: UIImageView!
    
    /// Label showing the details of the response from the server.
    @IBOutlet weak var textLabel: UILabel!
    
    /// Label showing the title of the response from the server.
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: Init and deinit methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
    }
    
    // MARK: Instance methods
    
    /**
    Update the UI for the provided ResponseConfirmation.
    
    - parameter responeConfirmation The ResponseConfirmation to use for determining the UI.
    */
    func configureForResponse(responeConfirmation : ResponseConfirmation) {
        let viewModel = ResponseConfirmationViewModel(response: responeConfirmation)
        
        imageView.image = viewModel.image()
        textLabel.attributedText = viewModel.attributedText()
        titleLabel.text = viewModel.title()
        backgroundColor = viewModel.backgroundColor()
    }

    // MARK: IBActions
    
    @IBAction func dismissButtonTapped(sender: AnyObject) {
        delegate?.responseConfirmationViewDismissButtonTapped(self)
    }
    
    // MARK: Private methods
    
    /**
    Loads the view from the nib.
    
    - returns: The view loaded from the nib.
    */
    private func loadViewFromNib() -> UIView {
        
        let nib = UINib(nibName: "ResponseConfirmationView", bundle: nil)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    /**
     Loads the view from the nib and adds it to the main view.
     */
    private func xibSetup() {
        let view = loadViewFromNib()
        
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view": view]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view": view]))
        
        backgroundColor = AppConfiguration.yellow()
    }
}
