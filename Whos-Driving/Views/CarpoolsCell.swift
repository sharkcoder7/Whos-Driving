import UIKit

/**
 Style used to configure a CarpoolsCell.
 */
enum CarpoolsCellStyle {
    /// Use standard colors and UI.
    case Standard
    /// Use the grayed out colors and UI.
    case Gray
}

/// UITableViewCell used to show carpool events in the main feed.
class CarpoolsCell: UITableViewCell {
    
    // MARK: Constants
    
    /// Reuse identifier.
    static let CarpoolsCellReuseId = "CarpoolsCellReuseId"
    
    // MARK: Private Properties
    
    /// The date formatter used for the start time and end time.
    private let dateFormatter = NSDateFormatter()
    
    // MARK: IBOutlets
    
    /// View on the left side of the cell showing the status of the event.
    @IBOutlet private weak var coloredEdgeView: ColoredEdgeView!
    
    /// The PersonButton representing the person driving from the event.
    @IBOutlet weak var driverFromView: PersonButton!
    
    /// The PersonButton representing the person driving to the event.
    @IBOutlet weak var driverToView: PersonButton!
    
    /// Label that says "Driving From".
    @IBOutlet private weak var drivingFromLabel: UILabel!
    
    /// Label that says "Driving To".
    @IBOutlet private weak var drivingToLabel: UILabel!
    
    /// Label showing the time of the event.
    @IBOutlet private weak var timeLabel: UILabel!
    
    /// Label showing the title of the event.
    @IBOutlet private weak var titleLabel: UILabel!
    
    /// Label in the corner of the cell showing the status of the event. (i.e. "new", "updated")
    @IBOutlet private weak var updatedLabel: UILabel!
    
    /// Container view for the updatedLabel. Is hidden if there isn't a status to show.
    @IBOutlet private weak var updatedLabelContainer: UIView!
    
    // MARK: Instance methods
    
    /**
    Sets up the views and labels with the proper UI for the provided event.
    
    - parameter event The event to setup the cell for.
    - parameter style The CarpoolsCellStyle to use for the cell. Defaults to Standard.
    */
    func populateFromEvent(event: Event, style: CarpoolsCellStyle = .Standard) {
        titleLabel.text = event.name
        
        let startTimeString = dateFormatter.stringFromDate(event.startTime).lowercaseString
        let endTimeString = dateFormatter.stringFromDate(event.endTime).lowercaseString
        timeLabel.text = startTimeString + " - " + endTimeString
        
        let buttonStyle = style == .Gray ? PersonButtonStyle.Gray : PersonButtonStyle.Colored
        
        driverFromView.populateViewForPerson(event.driverFrom, style: buttonStyle)
        driverToView.populateViewForPerson(event.driverTo, style: buttonStyle)
        
        if style == .Gray {
            coloredEdgeView.edgeColor = AppConfiguration.lightGray()
            timeLabel.textColor = AppConfiguration.lightGray()
            titleLabel.textColor = AppConfiguration.lightGray()
            userInteractionEnabled = false
            updatedLabelContainer.hidden = true
            updatedLabel.text = nil
        } else {
            timeLabel.textColor = AppConfiguration.black()
            titleLabel.textColor = AppConfiguration.black()
            coloredEdgeView.driverStatus = event.driverStatus
            userInteractionEnabled = true
            updatedLabelContainer.hidden = event.updatedStatus == .Current
            updatedLabel.text = event.updatedStatus.rawValue
        }
    }
    
    // MARK: UITableViewCell Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = AppConfiguration.offWhite()
        
        timeLabel.textColor = AppConfiguration.black()
        titleLabel.textColor = AppConfiguration.black()
        drivingToLabel.textColor = AppConfiguration.lightGray()
        drivingFromLabel.textColor = AppConfiguration.lightGray()
        
        updatedLabelContainer.backgroundColor = AppConfiguration.updatedLightBlue()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let color = highlighted ? AppConfiguration.lightGray(0.2) : UIColor.clearColor()
        
        coloredEdgeView.backgroundColor = color
    }
}
