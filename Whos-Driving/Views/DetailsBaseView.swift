import UIKit

/// Protocol for any detail view to request that its superview re-layout the views.
protocol DetailsViewDelegate: class {
    
    /**
     Called when the DetailsBaseView (or one of its subclasses) needs to be re-laid out.
     
     - parameter detailsView The view requesting the layout.
     - parameter duration The duration to animate the layout.
     */
    func detailsViewRequestsLayout(detailsView: DetailsBaseView, duration: Double)
}

@IBDesignable

/// Base class for views used in the detail view. Provides common setup for subclasses. This class 
/// isn't meant to be used as is in UI.
class DetailsBaseView: UIView {

    // MARK: Public properties
    
    /// Delegate of this class.
    weak var delegate: DetailsViewDelegate?
    
    // MARK: IBOutlets
    
    /// The colored edge view showing the status of this part of the details.
    @IBOutlet weak var coloredEdgeView: ColoredEdgeView!
    
    /// Button for editing.
    @IBOutlet weak var editButton: UIButton!
    
    // MARK: Init and deinit methods
    
    /**
    This method is called when any other init method is called. Sets up the defaults properties and
    views.
    */
    func commonInit() {
        backgroundColor = AppConfiguration.offWhite()
        
        let view = loadViewFromNib()
        view.translatesAutoresizingMaskIntoConstraints = false

        addSubview(view)
        
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view": view]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view": view]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    // MARK: Instance methods
    
    /**
    Loads the view from the nib. This is done this way to enable @IBDesignable. Subclasses MUST
    override this method otherwise an exception will be thrown.
    
    - returns: The view loaded from the nib.
    */
    func loadViewFromNib() -> UIView {
        fatalError("subclass must override this")
    }
    
    // MARK: UIView Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        editButton.setTitleColor(AppConfiguration.lightGray(), forState: UIControlState.Normal)
        editButton.titleLabel?.font = UIFont(name: Font.HelveticaNeueLight, size: 14)
    }
}
