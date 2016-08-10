import UIKit

/**
 *  This delegate is responsible for responding to events in the DetailHeaderView such as button taps.
 */
protocol DetailHeaderViewDelegate: class {
    
    /**
     Called when the label at the top of the view is tapped.
     
     - parameter detailHeaderView The sender of this method.
     */
    func detailHeaderViewHeaderLabelTapped(detailHeaderView: DetailHeaderView)
    
    /**
     Called when the submit button is tapped.
     
     - parameter detailHeaderView The sender of this method.
     - parameter driverStatus The DriverStatus selected by the user to be submitted to the server.
     */
    func detailHeaderViewSubmitButtonTapped(detailHeaderView: DetailHeaderView, driverStatus: DriverStatus)
}

/// This view is a header at the top of the carpools detail view. It can be set to be a small banner
/// just showing a label, or expanded to show a table view of options for submitting a response to
/// a notification. This is controlled by calling -configureForStatus.
class DetailHeaderView: UIView {
    
    // MARK: Constants
    
    private let CellIdentifier = "DetailHeaderViewCellIdentifier"

    // MARK: Public properties
    
    /// The delegate of this class.
    weak var delegate: DetailHeaderViewDelegate?
    
    /// True if a driver status is being submitted to the server. Setting this to true causes the UI
    /// to change to disable user interaction on the table view and the submit button. Defaults to
    /// false.
    var submitting: Bool = false {
        didSet {
            submitButton.enabled = !submitting
            tableView.userInteractionEnabled = !submitting
            var buttonTitle: String
            
            if submitting {
                activityIndicator.startAnimating()
                buttonTitle = "Submitting..."
            } else {
                activityIndicator.stopAnimating()
                buttonTitle = "Submit Response"
            }
            
            submitButton.setTitle(buttonTitle, forState: UIControlState.Normal)
        }
    }
    
    // MARK: Private properties
    
    /// Array of DriverStatus objects used to determine how the table view should be configured.
    private var responses = [DriverStatus]()
    
    /// The view model for this object.
    private var viewModel: DetailHeaderViewModel?
    
    // MARK: IBOutlets
    
    /// Activity indicator shown when a response is being sent to the server.
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /// Title label at the top of the header.
    @IBOutlet weak var headerLabel: UILabel!
    
    /// Container view of the headerLabel.
    @IBOutlet weak var headerLabelContainer: UIView!
    
    /// When pressed, submits the selected response to the server.
    @IBOutlet weak var submitButton: UIButton!
    
    /// Table view showing possible responses to send to the server.
    @IBOutlet weak var tableView: UITableView!
    
    /// Height constraint for the table view.
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
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
    Primary way of updating the UI of this view. Pass in an EventDriverStatus, the list of 
    DriverStatus options to show to the user, and whether the response view should be shown or not.
    
    - parameter driverStatus The EventDriverStatus of the event this header is representing.
    - parameter shouldShowResponseView True if the response view should be shown.
    */
    func configureForStatus(driverStatus: EventDriverStatus, responses: [DriverStatus], shouldShowResponseView: Bool) {
        let viewModel = DetailHeaderViewModel(driverStatus: driverStatus, responses: responses, shouldShowResponseView: shouldShowResponseView)
        self.viewModel = viewModel
        self.responses = responses
        
        tableViewHeightConstraint.constant = viewModel.tableViewHeight()
        backgroundColor = viewModel.backgroundColor()
        headerLabel.attributedText = viewModel.headerLabelAttributedText()
        tableView.reloadData()
        updateSubmitButton()
        activityIndicator.color = UIColor.whiteColor()
    }
    
    /**
     The natural height of this view based on its current state and width.
     
     - returns: The natural height of this view.
     */
    func preferredHeight() -> CGFloat {
        var height: CGFloat = 0.0
        
        if let headerHeight = viewModel?.headerHeightForLabelWidth(headerLabel.frame.size.width) {
            height = headerHeight
        }
        
        return height
    }
    
    // MARK: Actions
    
    /**
    Called when the header label is tapped.
    */
    @objc private func headerLabelTapped() {
        delegate?.detailHeaderViewHeaderLabelTapped(self)
    }
    
    /**
     Called when the submit button is tapped.
     
     - parameter sender The view that was tapped.
     */
    @IBAction func submitResponseTapped(sender: UIButton) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            let status = responses[selectedIndexPath.row]
            
            delegate?.detailHeaderViewSubmitButtonTapped(self, driverStatus: status)
        }
    }
    
    // MARK: Private methods
    
    /**
    Loads the view from the nib.
    
    - returns: The view loaded from the nib.
    */
    private func loadViewFromNib() -> UIView {
        
        let nib = UINib(nibName: "DetailHeaderView", bundle: nil)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    /**
     Updates the submit button to be enabled or disabled based on the current state of the table
     view.
     */
    private func updateSubmitButton() {
        if tableView.indexPathForSelectedRow == nil {
            submitButton.enabled = false
        } else {
            submitButton.enabled = true
        }
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
        
        let blueColorImage = UIImage.imageWithColor(AppConfiguration.blue())
        submitButton.setBackgroundImage(blueColorImage, forState: UIControlState.Normal)
        submitButton.setTitleColor(AppConfiguration.white(), forState: UIControlState.Normal)
        
        let grayColorImage = UIImage.imageWithColor(AppConfiguration.black(0.2))
        submitButton.setBackgroundImage(grayColorImage, forState: UIControlState.Disabled)
        submitButton.setTitleColor(AppConfiguration.white(0.5), forState: UIControlState.Disabled)

        submitButton.layer.cornerRadius = 3.0
        updateSubmitButton()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        tableView.layoutMargins = UIEdgeInsetsZero
        
        layer.borderWidth = 0.5
        layer.borderColor = AppConfiguration.lightGray().CGColor
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerLabelTapped))
        headerLabelContainer.addGestureRecognizer(tapRecognizer)
    }
}

// MARK: UITableViewDataSource methods

extension DetailHeaderView : UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath)
        if let unwrappedViewModel = viewModel {
            let response = responses[indexPath.row]
            let attributedText = unwrappedViewModel.attributedTextForResponse(response)
            cell.textLabel?.attributedText = attributedText
        }
        
        cell.layoutMargins = UIEdgeInsetsZero
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        cell.accessoryType = cell.selected ? .Checkmark : .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responses.count
    }
}

// MARK: UITableViewDelegate methods

extension DetailHeaderView : UITableViewDelegate {
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.None
        
        updateSubmitButton()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        
        updateSubmitButton()
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.selected {
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
                cell.accessoryType = UITableViewCellAccessoryType.None
                updateSubmitButton()
                return nil
            }
        }
        
        return indexPath
    }
}