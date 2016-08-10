import UIKit

/**
 Represents one of the styles that can be used to configure the EmptyStateView.
 */
enum EmptyStateStyle {
    
    /// Empty state of the CarpoolsViewController when the user is setup and ready to create events.
    case CarpoolsDone
    /// Empty state of the CarpoolViewController when the user is almost done setting up.
    case CarpoolsAlmostDone
    /// Empty state of the DriversViewController.
    case Drivers
    /// Empty state of the DriversViewController after a driver invite was successfully sent.
    case DriversInviteSent
    /// Empty state of the KidsViewController for the "My Kids" tab.
    case MyKids
    /// Empty state of the KidsViewController for the "Other Kids" tab.
    case OtherKids
}

/// This view is a configurable empty state view. Use -configureForStyle: to configure the view.
class EmptyStateView: UIView {
    
    // MARK: Constants
    
    /// The default height of the view.
    private let DefaultViewHeight: CGFloat = 363.0
    
    // MARK: IBOutlets
    
    /// The image view centered in the view.
    @IBOutlet weak var imageView: UIImageView!
    
    /// Label below the upperDescriptionLabel.
    @IBOutlet weak var lowerDescriptionLabel: UILabel!
    
    /// Title label at the top of the view.
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Label below the image view.
    @IBOutlet weak var upperDescriptionLabel: UILabel!
    
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
    Configures the view with the text and images for the provided style.
    
    - parameter style The style to use to configure the view.
    */
    func configureForStyle(style: EmptyStateStyle) {
        let viewModel = EmptyStateViewModel(style: style)
        
        imageView.image = viewModel.image()
        imageView.tintColor = viewModel.imageViewTint()
        lowerDescriptionLabel.attributedText = viewModel.lowerDescriptionAttributedText()
        titleLabel.text = viewModel.titleText()
        titleLabel.textColor = viewModel.titleTextColor()
        upperDescriptionLabel.text = viewModel.upperDescriptionText()
    }
    
    // MARK: Private methods
    
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
        
        view.backgroundColor = UIColor.clearColor()
    }
    
    /**
    Loads the view from the nib.
    
    - returns: The view loaded from the nib.
    */
    private func loadViewFromNib() -> UIView {
        
        let nib = UINib(nibName: "EmptyStateView", bundle: nil)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    // MARK: UIView methods
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIViewNoIntrinsicMetric, DefaultViewHeight)
    }
}