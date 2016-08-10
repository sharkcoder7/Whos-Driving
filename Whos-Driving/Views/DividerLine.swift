import UIKit

/// Thin, light gray view used as a divider line. The intrinsicContentSize of the view is set to 
/// <= 1 (depending on screen scale) for both height and width. The superview should override either
/// the height or width (depending on if it's a horizontal or vertical divider line) using autolayout.
class DividerLine: UIView {

    // MARK: Init and deinit methods
    
    private func commonInit() {
        backgroundColor = AppConfiguration.lightGray()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    // MARK: UIView methods
    
    override func intrinsicContentSize() -> CGSize {
        let thickness = AppConfiguration.borderWidth()

        return CGSizeMake(thickness, thickness)
    }
}
