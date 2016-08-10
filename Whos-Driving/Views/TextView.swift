import UIKit

@IBDesignable

/// Custom UITextView that adds a placeholder.
class TextView: UITextView {
    
    // MARK: Constants
    
    /// Distance to inset the textContainer from the top, left, right, and bottom.
    private let textInset = 4.0 as CGFloat
    
    // MARK: Public properties
    
    /// The placeholder text shown when there is no text in the UITextView.
    @IBInspectable var placeholder: String = "" {
        didSet {
            placeHolderLabel.text = placeholder
            textDidChange()
        }
    }
    
    // MARK: Private Properties
    
    /// Label used for the placeholder text.
    private var placeHolderLabel = UILabel()
    
    // MARK: Init and deinit methods
    
    /**
    This method is called when any other init method is called. Sets up the defaults properties and
    views.
    */
    func commonInit() {
        backgroundColor = AppConfiguration.white()

        layer.borderColor = AppConfiguration.lightGray().CGColor
        layer.borderWidth = AppConfiguration.borderWidth()
        layer.cornerRadius = 2
        
        textContainerInset = UIEdgeInsetsMake(textInset, textInset, textInset, textInset)
        
        let caretRect = caretRectForPosition(beginningOfDocument)
        let frameX = caretRect.origin.x
        let frameY = caretRect.origin.y
        let placeHolderFrame = CGRectMake(frameX, frameY, frame.size.width - frameX, frame.size.height - frameY)
        placeHolderLabel = UILabel(frame: placeHolderFrame)
        placeHolderLabel.numberOfLines = 0
        placeHolderLabel.font = font
        placeHolderLabel.textColor = AppConfiguration.mediumGray()
        placeHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeHolderLabel)

        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(textDidChange), name:UITextViewTextDidChangeNotification, object: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    required override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        commonInit()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Instance Methods
    
    /**
    Called when the text changes.
    */
    func textDidChange() {
        if text.characters.count > 0 {
            placeHolderLabel.hidden = true
        }
        else {
            placeHolderLabel.hidden = false
        }
    }
    
    // MARK: UIView methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let caretRect = caretRectForPosition(beginningOfDocument)
        let frameX = caretRect.origin.x
        let frameY = caretRect.origin.y
        let sizeThatFits = placeHolderLabel.sizeThatFits(CGSizeMake(frame.size.width - (frameX * 2), CGFloat.max))
        placeHolderLabel.frame = CGRectMake(frameX, frameY, sizeThatFits.width, sizeThatFits.height)
    }
}
