import UIKit

/**
 The current status of the upload to the server.
 */
enum UploadingState {
    /// Upload failed.
    case Failed
    /// Upload was successful.
    case Success
    /// Currently uploading.
    case Uploading
}

/// This protocol has methods for responding to events within the view.
protocol UploadingViewDelegate: class {
    
    /**
     This method is called when the UploadingView is tapped.
     
     - parameter view The view that was tapped.
     */
    func uploadingViewTapped(view: UploadingView)
}

/// View shown when a carpool is uploading. It has different UI to represent that the carpool is
/// uploading, successfully uploaded, and failed to upload.
class UploadingView: UIView {
    
    // MARK: Constants
    
    /// Duration of the flip animation.
    let FlipAnimationDuration: NSTimeInterval = 0.5
    
    // MARK: Properties
    
    /// The delegate for this class.
    weak var delegate: UploadingViewDelegate?
    
    /// The current state of the upload to the server. Updating this property will update the UI
    /// accordingly.
    var uploadingState: UploadingState = .Uploading {
        didSet {
            UIView.transitionWithView(contentView, duration: FlipAnimationDuration, options: UIViewAnimationOptions.TransitionFlipFromTop, animations: { () -> Void in
                switch self.uploadingState {
                case .Uploading:
                    self.uploadingView.hidden = false
                    self.successView.hidden = true
                    self.uploadFailedView.hidden = true
                case .Success:
                    self.uploadingView.hidden = true
                    self.successView.hidden = false
                    self.uploadFailedView.hidden = true
                case .Failed:
                    self.uploadingView.hidden = true
                    self.successView.hidden = true
                    self.uploadFailedView.hidden = false
                }
                }, completion: nil)
        }
    }

    // MARK: IBOutlets
    
    /// Activity indicator showing that an upload is in progress.
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /// Container view for all the other views.
    @IBOutlet weak var contentView: UIView!
    
    /// View shown for the Success state.
    @IBOutlet weak var successView: UIView!
    
    /// View shown for the Failed state.
    @IBOutlet weak var uploadFailedView: UIView!
    
    /// View shown for the Uploading state.
    @IBOutlet weak var uploadingView: UIView!
    
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
    Called when the background is tapped.
    */
    @objc private func backgroundTapped() {
        delegate?.uploadingViewTapped(self)
    }
    
    /**
    Loads the view from the nib.
    
    - returns: The view loaded from the nib.
    */
    private func loadViewFromNib() -> UIView {
        
        let nib = UINib(nibName: "UploadingView", bundle: nil)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        backgroundColor = UIColor.clearColor()
        activityIndicator.color = UIColor.whiteColor()
        uploadingView.backgroundColor = AppConfiguration.blue()
        successView.backgroundColor = AppConfiguration.green()
        uploadFailedView.backgroundColor = AppConfiguration.red()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        contentView.addGestureRecognizer(tapRecognizer)
        
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
    }
}
