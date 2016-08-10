import UIKit

/// Collection view cell with a PersonButton centered in the cell.
class PersonCollectionViewCell: UICollectionViewCell {
    
    // MARK: Constants
    
    /// The cells reuse identifier.
    static let reuseIdentifier = "PersonCollectionViewCellReuseIdentifier"
    
    override var selected: Bool {
        didSet {
            if checkMarkWhenSelected {
                personButton.chosen = selected
            }
        }
    }
    
    // MARK: Public properties
    
    /// If true, adds a check mark image when the cell is selected.
    var checkMarkWhenSelected = true
    
    /// The person represented by this cell.
    var person: Person?

    // MARK: IBOutlets
    
    /// PersonButton centered in the cell.
    @IBOutlet weak var personButton: PersonButton!
    
    // MARK: Instance Methods
    
    /**
    Configures the PersonButton in the cell for the person.
    
    - parameter person Person to configure the cell for.
    */
    func configureForPerson(person: Person, style: PersonButtonStyle = .Initials) {
        self.person = person
        personButton.populateViewForPerson(person, style: style)
    }
    
    /**
    Configures the PersonButton in the cell for the provided button type.
    
    - parameter buttonType The type of button to configure the cell for.
    */
    func configureForPersonButtonType(buttonType: PersonButtonType) {
        personButton.populateViewForType(buttonType)
    }
    
    // MARK: UICollectionViewCell methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        personButton.resetUI()
        personButton.userInteractionEnabled = true
    }
}
