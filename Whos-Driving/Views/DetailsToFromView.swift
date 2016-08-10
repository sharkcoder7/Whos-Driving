import UIKit

/// This protocol has methods for responding to events in the view.
protocol DetailsToFromViewDelegate: class {
    
    /**
     Called when the edit button is tapped.
     
     - parameter detailsView The DetailsToFromView sending this method.
     */
    func DetailsToFromViewEditButtonTapped(detailsView: DetailsToFromView)
}

/// View showing the details of either TO or FROM for an event.
class DetailsToFromView: DetailsBaseView {
    
    // MARK: Constants
    
    /// Height of the cells in the tableView.
    let riderCellHeight: CGFloat = 40.0
    
    /// Margin used to the vertical space constraint's for the note label margins.
    private let noteLabelMarginSize = 10.0 as CGFloat
    
    // MARK: Private Properties
    
    /// The delegate of this class.
    weak var detailsToFromViewDelegate: DetailsToFromViewDelegate?
    
    /// True if the view is showing the details of the TO leg of the event, false if it's showing FROM.
    var drivingTo: Bool = false
    
    /// The event being shown in this view.
    var event: Event?
    
    /// The view model for this class.
    private var viewModel: DetailsToFromViewModel?
    
    /// Array of riders for the event.
    private var riders: NSArray = NSArray()
    
    // MARK: Outlets
    
    /// Container view for the views showing who is driving and riding.
    @IBOutlet private weak var bodyView: UIView!
    
    /// Height constraint for the footer divider line.
    @IBOutlet private weak var footerDividerHeightConstraint: NSLayoutConstraint!
    
    /// The footer divider line.
    @IBOutlet private weak var footerDividerView: UIView!
    
    /// Height constraint for the header divider line.
    @IBOutlet private weak var headerDividerHeightConstraint: NSLayoutConstraint!
    
    /// The header divider line.
    @IBOutlet private weak var headerDividerView: UIView!
    
    /// The label showing the note for the leg of the event.
    @IBOutlet private weak var noteLabel: UILabel!
    
    /// Vertical space constraint for the bottom margin of the note label.
    @IBOutlet private weak var noteLabelBottomMargin: NSLayoutConstraint!
    
    /// Vertical space constraint for the top margin of the note label.
    @IBOutlet private weak var noteLabelTopMargin: NSLayoutConstraint!
    
    /// The PersonButton showing who is driving.
    @IBOutlet private weak var personButton: PersonButton!
    
    /// The table view showing the list of riders.
    @IBOutlet private weak var tableView: UITableView!
    
    /// The height constraint for the table view.
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    /// The title label.
    @IBOutlet private weak var titleLabel: UILabel!
    
    /// Label that says "Who's Driving?".
    @IBOutlet private weak var whosDrivingLabel: UILabel!
    
    /// Label that says "Who's Riding?".
    @IBOutlet private weak var whosRidingLabel: UILabel!
    
    // MARK: Instance Methods
    
    /**
    Configures the UI for the provided event.
    
    - parameter event The event to show the details of.
    - parameter isDrivingTo True to show the details of the TO leg of the event, false to show FROM.
    */
    func populateViewFor(event: Event, isDrivingTo: Bool) {
        drivingTo = isDrivingTo
        viewModel = DetailsToFromViewModel(event: event)
        self.event = event
        if let notes = viewModel?.attributedNotesString(isDrivingTo) {
            noteLabel.attributedText = notes
            noteLabelBottomMargin.constant = noteLabelMarginSize
            noteLabelTopMargin.constant = noteLabelMarginSize
            footerDividerHeightConstraint.constant = coloredEdgeView.borderWidth
        } else {
            footerDividerHeightConstraint.constant = 0
            noteLabel.text = nil
            noteLabelBottomMargin.constant = 0
            noteLabelTopMargin.constant = 0
        }
        
        coloredEdgeView.edgeColor = viewModel!.coloredEdgeViewColor(isDrivingTo)
        
        titleLabel.attributedText = viewModel?.attributedTitleString(isDrivingTo)
        
        if let driver = isDrivingTo ? event.driverTo : event.driverFrom {
            personButton.populateViewForPerson(driver, style: PersonButtonStyle.Colored)
            personButton.tappedCompletion = PersonButton.defaultTappedHandler
        } else {
            personButton.populateViewForPerson(nil, style: PersonButtonStyle.Colored)
            let tappedHandler: (PersonButton) -> Void = { [weak self] personButton in
                self?.editButtonTapped(self!.personButton)
            }
            personButton.tappedCompletion = tappedHandler
        }
        
        if let ridersArray = isDrivingTo ? event.ridersTo : event.ridersFrom {
            riders = ridersArray
            
            tableViewHeightConstraint.constant = riderCellHeight * CGFloat(riders.count)
            tableView.reloadData()
        }
    }
    
    // MARK: IBAction Methods
    
    /**
    Called when the edit button is tapped.
    
    - parameter sender The view that was tapped.
    */
    @IBAction private func editButtonTapped(sender: UIView) {
        detailsToFromViewDelegate?.DetailsToFromViewEditButtonTapped(self)
    }
        
    // MARK: DetailsBaseView Methods
    
    override func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: "DetailsToFromView", bundle: nil)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    // MARK: UIView Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let dividerColor = AppConfiguration.lightGray()
        let dividerLineWidth = coloredEdgeView.borderWidth
        footerDividerView.backgroundColor = dividerColor
        footerDividerHeightConstraint.constant = dividerLineWidth
        headerDividerView.backgroundColor = dividerColor
        headerDividerHeightConstraint.constant = dividerLineWidth
        
        let nib = UINib(nibName: "RiderCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: RiderCell.reuseID)
    }
}

// MARK: UITableViewDataSource methods

extension DetailsToFromView: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RiderCellReuseID", forIndexPath: indexPath) as! RiderCell
        let rider = riders[indexPath.row] as! Person
        cell.personButton.populateViewForPerson(rider)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return riders.count
    }
}
