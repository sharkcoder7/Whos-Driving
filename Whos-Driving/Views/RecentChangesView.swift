import UIKit

/// Classes that conform to this protocol will receive messages concerning events that occur in the
/// RecentChangesView such as buttons being tapped.
protocol RecentChangesViewDelegate: class {
    
    /**
     Called when the "dismiss" button is tapped.
     
     - parameter view The sender.
     */
    func recentChangesViewDismissButtonTapped(view: RecentChangesView)
}

/// This view shows a list of changes in a table view to
class RecentChangesView: UIView {
    
    // MARK: Constants
    
    /// The height above and below the tableview. This is used to determine the proper height of 
    /// this view, along with the content size of the tableView.
    private let viewPadding: CGFloat = 102.0
    
    // MARK: Properties
    
    /// Delegate of this class. See RecentChangesViewDelegate.
    weak var delegate: RecentChangesViewDelegate?
    
    /// Array of EventHistoryItems that make up the list of recent changes shown in this view. This
    /// is the datasource for the tableView.
    var historyItems = [EventHistoryItem]()
    
    // MARK: Outlets
    
    /// Container view for all the other views in this class.
    @IBOutlet private weak var contentView: UIView!
    
    /// The table view showing the list of EventHistoryItems.
    @IBOutlet private weak var tableView: UITableView!
    
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
    Configures the view for the provided array of EventHistoryItems. After loading the data into
    the tableView, the total height of the view is returned based on top/bottom padding and the
    content size of the tableView.
    
    - parameter items The items to display. This property is assigned to historyItems.
    
    - returns: The total height of this view based on the content size of the tableView and the 
               top/bottom padding. Returns 0 if items is empty.
    */
    func configureForHistoryItems(items: [EventHistoryItem]) -> CGFloat {
        historyItems = items
        
        tableView.reloadData()
        tableView.layoutIfNeeded()
        
        let contentHeight = tableView.contentSize.height
        
        if contentHeight == 0 {
            return 0
        } else {
            return contentHeight + viewPadding
        }
    }
    
    // MARK: Actions

    @IBAction private func dismissButtonTapped(sender: AnyObject) {
        delegate?.recentChangesViewDismissButtonTapped(self)
    }
    
    // MARK: Private methods
    
    /**
    Loads the view from the nib.
    
    - returns The view loaded from the nib.
    */
    private func loadViewFromNib() -> UIView {
        
        let nib = UINib(nibName: "RecentChangesView", bundle: nil)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
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
        
        backgroundColor = UIColor.clearColor()
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = AppConfiguration.lightGray().CGColor
        
        let carpoolHistoryCellNib = UINib(nibName: "CarpoolHistoryCell", bundle: nil)
        tableView.registerNib(carpoolHistoryCellNib, forCellReuseIdentifier: CarpoolHistoryCell.reuseId)
    }
}

// MARK: UITableViewDataSource methods

extension RecentChangesView: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CarpoolHistoryCell.reuseId) as! CarpoolHistoryCell
        
        let item = historyItems[indexPath.row]
        cell.configureForItem(item)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyItems.count
    }
}

extension RecentChangesView: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Calculate the height of the cell based on the text that will be in it, with a minimum cell height.
        let item = historyItems[indexPath.row]
        let viewModel = CarpoolHistoryCellViewModel(item: item)
        let text = viewModel.messageAttributedText()
        
        let widthPadding = 56.0 as CGFloat
        let heightPadding = 31.0 as CGFloat
        let minimumCellHeight = 46.0 as CGFloat
        
        let size = CGSizeMake(tableView.frame.width - widthPadding, CGFloat.max)
        let textHeight = text.boundingRectWithSize(size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil).height
        let cellHeight = textHeight + heightPadding
        
        return max(minimumCellHeight, cellHeight)
    }
}