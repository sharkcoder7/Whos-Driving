import UIKit

/// This view is for showing a full screen, semi transparent, overlay view with a UIActivityIndicator
/// centered in it.
class LoadingView: UIView {
    
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
    Adds the LoadingView to the provided view. The LoadingView will be the same size as the view it's
    adding itself to.
    
    - parameter view The view to add the LoadingView to.
    */
    func addToView(view: UIView) {
        frame = view.bounds
        translatesAutoresizingMaskIntoConstraints = false
        alpha = 1.0

        view.addSubview(self)

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view": self]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view": self]))
        
    }
    
    /**
     Animates the LoadingView to alpha 0.0 and then removes itself from its superview.
     */
    func remove() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.alpha = 0.0
            }) { (finished) -> Void in
                self.removeFromSuperview()
        }

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
    }
    
    /**
    Loads the view from the nib.
    
    - returns: The view loaded from the nib.
    */
    private func loadViewFromNib() -> UIView {
        
        let nib = UINib(nibName: "LoadingView", bundle: nil)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
}
