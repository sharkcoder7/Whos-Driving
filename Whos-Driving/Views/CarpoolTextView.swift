import UIKit

/// Custom view with an icon, title, and UITextField.
class CarpoolTextView: UIView {
    
    // MARK: Propreties
    
    /// The image used in the imageView.
    @IBInspectable var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    /// The text for the titleLabel.
    @IBInspectable var title: String = "Title" {
        didSet {
            titleLabel.text = title
        }
    }
    
    /// The text for the placeholder in the textField.
    @IBInspectable var placeholder: String = "Placeholder"{
        didSet {
            textField.placeholder = placeholder
        }
    }
    
    // MARK: IBOutlets
    
    /// Image view showing the icon for the view.
    @IBOutlet weak var imageView: UIImageView!
    
    /// The label showing the title.
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Text field for entering text.
    @IBOutlet weak var textField: UITextField!
    
    // MARK: Init and deinit methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
    }
    
    // MARK: Private methods
    
    /**
    Loads the view from the nib. This is done this way to enable @IBDesignable.
    
    - returns: The view loaded from the nib.
    */
    private func loadViewFromNib() -> UIView {
        
        let nib = UINib(nibName: "CarpoolTextView", bundle: nil)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    @objc private func tapped(gestureRecognizer: UITapGestureRecognizer) {
        textField.becomeFirstResponder()
    }
    
    /**
    Loads the view from the nib and adds it to the main view. This is done this way to enable
    @IBDesignable.
    */
    private func xibSetup() {
        let view = loadViewFromNib()
        
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view": view]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["view": view]))
        
        backgroundColor = UIColor.clearColor()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        addGestureRecognizer(tapRecognizer)
    }
}
