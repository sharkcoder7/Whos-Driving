import UIKit

/// A cell in the intro view shown to the user when they open the app for the first time.
class IntroCell: UICollectionViewCell {
    
    // MARK: Constants
    
    /// The number of degrees to rotate the cell as it's swiped left/right.
    private let degreesToRotate = 15.0

    /// The cell's reuse identifier.
    static let reuseIdentifier = "IntroCellReuseId"
    
    /// The factor to shift the view down by as it's swiped left/right.
    private let shiftDownFactor = 0.2
    
    // MARK: Private Properties
    
    /// The distance to shift the view.
    private var distanceToShift: NSNumber?
    
    /// Gradient layer at the bottom of the cell.
    private let gradientLayer = CAGradientLayer()
    
    /// The page number of the cell.
    private var pageNumber: NSNumber?
    
    // MARK: IBOutlets
    
    /// Height constraint of the bottomContainer.
    @IBOutlet private weak var bottomContainerHeightConstraint: NSLayoutConstraint!
    
    /// The container view at the bottom of the cell.
    @IBOutlet private weak var bottomContainer: UIView!
    
    /// The image view showing the intro image.
    @IBOutlet weak var imageView: UIImageView!
    
    /// The vertical spacing between the image view and the top of the cell.
    @IBOutlet private weak var imageViewTopConstraint: NSLayoutConstraint!
    
    /// The label showing the details of the cell.
    @IBOutlet weak var subTitleLabel: UILabel!
    
    /// The label showing the title of the cell.
    @IBOutlet weak var titleLabel: UILabel!

    // MARK: Instance Methods
    
    /**
    Updates the UI for the provided offset from the center of the screen. As the user swipes the
    view left/right this value is updated and the views in the cell are adjusted to create the tilt
    and shift animation.
    
    - parameter offset The offset from the center of the screen.
    */
    func setPageOffset(offset: CGFloat) {
        if pageNumber == nil {
            let width = frame.width
            let originX = frame.origin.x
            pageNumber = originX / width
        }
        
        if distanceToShift == nil {
            let height = imageView.frame.height
            distanceToShift = height * CGFloat(shiftDownFactor)
        }
        
        // adjusted offset determines distance of the cell from being centered in the screen,
        // 0 being center, -1 being one page to the left, 1 being one page to the right, etc
        let adjustedOffset = CGFloat(pageNumber!.floatValue) - offset
        // absolute value is used for setting the alpha
        let absoluteAdjustedOffset = fabs(adjustedOffset)
        
        let radians = (adjustedOffset * CGFloat(degreesToRotate)) / 180.0 * CGFloat(M_PI)
        let rotate = CGAffineTransformMakeRotation(radians)
        let shiftDown = CGAffineTransformMakeTranslation(0.0, absoluteAdjustedOffset * CGFloat(distanceToShift!.floatValue))
        let concat = CGAffineTransformConcat(rotate, shiftDown)
        
        imageView.transform = concat
        
        let alpha = 1.0 - absoluteAdjustedOffset
        subTitleLabel.alpha = alpha
        titleLabel.alpha = alpha
    }
    
    // MARK: UICollectionViewCell Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bottomContainer.backgroundColor = AppConfiguration.blue()
        
        let translucentBlack = UIColor(white: 0.0, alpha: 0.15)
        let colors = [translucentBlack.CGColor, UIColor.clearColor().CGColor]
        gradientLayer.colors = colors
        gradientLayer.endPoint = CGPointMake(0.5, 0.3)
        
        bottomContainer.layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bottomContainer.bounds
        bottomContainerHeightConstraint.constant = frame.size.height * IntroViewController.bottomContainerScale
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        pageNumber = nil
    }

}
