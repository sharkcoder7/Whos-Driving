import UIKit

/// Section header with labels for the day, month, and day of the week.
class CarpoolsHeader: UITableViewHeaderFooterView {
    
    // MARK: Constants
    
    /// The height of the header.
    static let headerHeight = 65.0 as CGFloat
    
    /// Reuse Identifier.
    static let headerReuseId = "CarpoolsHeaderReuseId"
    
    // MARK: Private Properties
    
    /// The date formatter for the dayLabel.
    let dayFormatter = NSDateFormatter()
    
    /// The date formatter for the dayOfTheWeekLabel.
    let dayOfTheWeekFormatter = NSDateFormatter()
    
    /// The date formatter for the monthLabel.
    let monthFormatter = NSDateFormatter()
    
    // MARK: IBOutlets
    
    /// The label showing the numerical day of the week for the event.
    @IBOutlet private weak var dayLabel: UILabel!
    
    /// The label showing the day of the week of the event in shorthand (i.e. MON, TUE).
    @IBOutlet private weak var dayOfTheWeekLabel: UILabel!
    
    /// The label showing the month of the event.
    @IBOutlet private weak var monthLabel: UILabel!
    
    // MARK: Instance Methods
    
    /**
    Updates the UI for the provided date.
    
    - parameter date The date used to update the UI.
    */
    func setDate(date: NSDate) {
        let dayString = dayFormatter.stringFromDate(date)
        let dayOfTheWeekString = dayOfTheWeekFormatter.stringFromDate(date)
        let monthString = monthFormatter.stringFromDate(date)
        
        dayLabel.text = dayString
        dayOfTheWeekLabel.text = dayOfTheWeekString
        monthLabel.text = monthString
    }

    // MARK: UIView Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dayFormatter.dateFormat = "dd"
        dayOfTheWeekFormatter.dateFormat = "EEE"
        monthFormatter.dateFormat = "MMM"
        
        dayLabel.textColor = AppConfiguration.black()
        dayOfTheWeekLabel.textColor = AppConfiguration.black()
        monthLabel.textColor = AppConfiguration.black()
    }
}
