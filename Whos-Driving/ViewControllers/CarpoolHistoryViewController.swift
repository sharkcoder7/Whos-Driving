import UIKit

/// This view shows the full history of changes to a carpool event.
class CarpoolHistoryViewController: UIViewController {
    
    // MARK: Private properties
    
    /// The event being shown.
    private var event: Event
    
    // Loading view to display while event details are being loaded.
    private let loadingView = LoadingView()
    
    // MARK: Outlets
    
    /// Container view for the content in the view controller. Is inset from the edges of the 
    /// superview.
    @IBOutlet weak var contentView: UIView!
    
    /// Table view showing the list of changes.
    @IBOutlet weak var tableView: UITableView!
    
    /// The title label.
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: Init and deinit methods
    
    /**
     Initializes a CarpoolHistoryViewController to show the provided eventName and list of 
     EventHistoryItems.
     
     - parameter eventName The name of the event to display to the user.
     - parameter historyItems The EventHistoryItems to show.
     
     - returns: Configured instanace of this class.
     */
    init(event: Event) {
        self.event = event
        
        super.init(nibName: "CarpoolHistoryViewController", bundle: nil)
        
        title = "Carpool History"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Instance methods
    
    /**
    Reloads the current event and displays the updated list of CarpoolHistoryItems.
    */
    func reloadEvent() {
        loadingView.addToView(view)
        
        Events().getEventById(event.id) { [weak self] (event, error) -> Void in
            if let event = event {
                self?.event = event
                
                self?.tableView.reloadData()
            }
            
            self?.loadingView.remove()
        }
    }
    
    // MARK: UIViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AppConfiguration.offWhite()
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = AppConfiguration.lightGray().CGColor
        
        titleLabel.text = event.name
        
        let carpoolHistoryCellNib = UINib(nibName: "CarpoolHistoryCell", bundle: nil)
        tableView.registerNib(carpoolHistoryCellNib, forCellReuseIdentifier: CarpoolHistoryCell.reuseId)
        tableView.estimatedRowHeight = 46.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadEvent()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsController().screen("Carpool history")
    }
}

// MARK: UITableViewDataSource methods

extension CarpoolHistoryViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CarpoolHistoryCell.reuseId) as! CarpoolHistoryCell
        
        let item = event.eventHistory[indexPath.row]
        cell.configureForItem(item)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event.eventHistory.count
    }
}
