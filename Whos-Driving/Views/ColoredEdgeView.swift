import UIKit

@IBDesignable

/// Custom view a view on the left edge showing the color associated with the assigned EventDriverStatus.
class ColoredEdgeView: UIView {
    
    // MARK: Public properties
    
    /// The width of the gray borders.
    var borderWidth:CGFloat = 1.0
    
    /// The EventDriverStatus used to set the edge color. Updating this property will automatically
    /// update the edge color.
    var driverStatus: EventDriverStatus = EventDriverStatus.NoDriverFrom {
        didSet {
            switch (driverStatus) {
            case .BothDrivers:
                edgeColor = AppConfiguration.green()
            case .NoDrivers:
                edgeColor = AppConfiguration.red()
            case .NoDriverFrom,
                 .NoDriverTo:
                edgeColor = AppConfiguration.yellow()
            }
        }
    }
    
    /// The color for the coloredEdgeView.
    var edgeColor: UIColor = AppConfiguration.yellow() {
        didSet {
            coloredEdgeView.backgroundColor = edgeColor
        }
    }
    
    // MARK: Private properties
    
    /// Bottom border view.
    private let bottomBorder = DividerLine()
    
    /// The colored view on the left side representing the EventDriverStatus.
    private let coloredEdgeView = UIView()
    
    /// The width of the coloredEdgeView.
    private let coloredEdgeWidth: CGFloat = 2.0
    
    /// Right border view.
    private let rightBorder = DividerLine()
    
    /// Top border view.
    private let topBorder = DividerLine()
    
    // MARK: Init and deinit methods
    
    /**
    This method is called when any other init method is called. Sets up the defaults properties and
    views.
    */
    private func commonInit() {
        borderWidth = AppConfiguration.borderWidth()
        
        coloredEdgeView.backgroundColor = AppConfiguration.yellow()
        coloredEdgeView.frame = CGRectMake(0, 0, coloredEdgeWidth, frame.size.height)
        coloredEdgeView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        insertSubview(coloredEdgeView, atIndex: 0)
        
        bottomBorder.frame = CGRectMake(0, frame.size.height - borderWidth, frame.size.width, borderWidth)
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(bottomBorder, aboveSubview: coloredEdgeView)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view": bottomBorder]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view": bottomBorder]))
        
        rightBorder.frame = CGRectMake(frame.size.width - borderWidth, 0, borderWidth, frame.size.height)
        rightBorder.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(rightBorder, aboveSubview: coloredEdgeView)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view": rightBorder]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view": rightBorder]))
        
        topBorder.frame = CGRectMake(0, 0, frame.size.width, borderWidth)
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(topBorder, aboveSubview: coloredEdgeView)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view": topBorder]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view": topBorder]))
        
        backgroundColor = AppConfiguration.white()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    // MARK: UIView methods
    
    override func addSubview(view: UIView) {
        // All subviews should be added above the topBorder. topBorder was the last of the borders 
        // to be added so all other views will be over the borders.
        insertSubview(view, aboveSubview: topBorder)
    }
}
