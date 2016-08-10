import UIKit

/// Cell showing a rider in a carpool.
class RiderCell: UITableViewCell {
    
    // MARK: Constants
    
    /// The cell's reuse identifier.
    static let reuseID = "RiderCellReuseID"
    
    // MARK: Outlets
    
    /// The PersonButton showing the rider.
    @IBOutlet weak var personButton: PersonButton!
}
