import UIKit

@IBDesignable

/// Custom UITextField that allows some, or all of the corners to be rounded.
class TextField: UITextField {
    
    // MARK: Constants
    
    /// The distance the text is inset from the left and right edges.
    private let horizontalTextInset = 10.0 as CGFloat

    // MARK: Private Properties
    
    /// The layer used for the borders.
    private var borderLayer = CAShapeLayer()
    
    /// Set to true to round the bottom left corner.
    @IBInspectable var bottomLeftCorner: Bool = false {
        didSet {
            if bottomLeftCorner == true {
                roundedCorners = [roundedCorners, .BottomLeft]
            }
        }
    }
    
    /// Set to true to round the bottom right corner.
    @IBInspectable var bottomRightCorner: Bool = false {
        didSet {
            if bottomRightCorner == true {
                roundedCorners = [roundedCorners, .BottomRight]
            }
        }
    }
    
    /// The corners that are rounded.
    private var roundedCorners: UIRectCorner = UIRectCorner()
    
    /// Set to true to round the top left corner.
    @IBInspectable var topLeftCorner: Bool = false {
        didSet {
            if topLeftCorner == true {
                roundedCorners = [roundedCorners, .TopLeft]
            }
        }
    }
    
    /// Set to true to round the top right corner.
    @IBInspectable var topRightCorner: Bool = false {
        didSet {
            if topRightCorner == true {
                roundedCorners = [roundedCorners, .TopRight]
            }
        }
    }
    
    // MARK: Init and deinit methods
    
    /**
    This method is called when any other init method is called. Sets up the defaults properties and
    views.
    */
    func commonInit() {
        borderStyle = UITextBorderStyle.None
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
    
    // MARK: Private methods
    
    /**
    Returns the CGRect used for the editingRect and the textRect.
    
    - parameter bounds The bounds to base the textInset on.

    - returns: The CGRect used for the editingRect and the textRect.
    */
    private func textInset(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, horizontalTextInset, 0)
    }
    
    // MARK: UITextField methods
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return textInset(bounds)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        let roundedCornerPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundedCorners, cornerRadii: CGSizeMake(2.0, 2.0))
        
        let roundedCornerLayer = CAShapeLayer()
        roundedCornerLayer.frame = bounds
        roundedCornerLayer.path = roundedCornerPath.CGPath
        layer.mask = roundedCornerLayer
        
        borderLayer.frame = bounds
        borderLayer.path = roundedCornerPath.CGPath
        borderLayer.strokeColor = AppConfiguration.lightGray().CGColor
        borderLayer.lineWidth = 1
        borderLayer.fillColor = nil
        
        if borderLayer.superlayer == nil {
            layer.addSublayer(borderLayer)
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        backgroundColor = AppConfiguration.white()
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return textInset(bounds)
    }
}
