import UIKit

/**
 Represents a row in the ProfileViewController's table view.
 */
private enum ProfileTableViewRow: NSInteger {
    /// The about row.
    case About
    /// The feedback row.
    case Feedback
    /// The legal row.
    case Legal
    /// The total number of rows. Should always be the last case in this enum.
    case NumberOfRows
}

/// This view controller shows the current user's profile view.
class ProfileViewController: UIViewController {
    
    // MARK: Constants
    
    /// Title for the about row.
    private let aboutTitle = "About"
    
    /// Title for the feedback row.
    private let feedbackTitle = "Feedback"
    
    /// Title for the legal row.
    private let legalTitle = "Legal"
    
    /// Cell reuse identifier for the UITableViewCells.
    private let reuseID = "ProfileViewControllerCellReuseID"
    
    // MARK: Properties
    
    /// The current user.
    var person: Person?
    
    // MARK: IBOutlets
    
    /// Button for editing the user's account.
    @IBOutlet private weak var editAccountButton: UIButton!
    
    /// PersonButton showing the current user's avatar.
    @IBOutlet private weak var personButton: PersonButton!
    
    /// Table view showing menu options to select.
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: Init and deinit methods
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        title = NSLocalizedString("Profile", comment: "Profile tab title.")
        tabBarItem.image = UIImage(named: "tab-profile")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: IBActions
    
    /**
    Called when the editAccountButton is tapped.
    
    - parameter sender The button that was tapped.
    */
    @IBAction func editAccountTapped(sender: UIButton) {
        if let person = person {
            AnalyticsController().track("Clicked edit profile")
            
            let editVC = EditProfileViewController(aPerson: person)
            navigationController?.pushViewController(editVC, animated: true)
        }
    }
    
    // MARK: Private methods
    
    /**
    Fetches the current user and updates the UI.
    */
    private func updateCurrentUser() {
        Profiles.sharedInstance.getCurrentUserProfile() { [weak self] (currentUser, accountSetupComplete, error) -> Void in
            self?.person = currentUser
            self?.personButton.populateViewForPerson(self?.person)
            self?.personButton.nameLabel.textColor = AppConfiguration.black()
            self?.personButton.nameLabel.font = UIFont(name: Font.HelveticaNeueMedium, size: 12)
        }
    }
    
    // MARK: UIViewContoller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        personButton.firstLetterLabel.font = UIFont(name: Font.HelveticaNeueRegular, size: 28)
        
        title = NSLocalizedString("Profile", comment: "Profile tab title.")
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseID)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateCurrentUser()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsController().screen("Profile tab")
    }
}

// MARK: UITableViewDataSource methods

extension ProfileViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfileTableViewRow.NumberOfRows.rawValue
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let viewModel = MenuCellViewModel()
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath)
        cell.backgroundColor = viewModel.backgroundColor()
        cell.accessoryType = viewModel.accessoryType()
        cell.textLabel?.font = viewModel.font()
        cell.textLabel?.textColor = viewModel.textColor()
        
        if let profileTableViewRow = ProfileTableViewRow(rawValue: indexPath.row) {
            switch profileTableViewRow {
            case .About:
                cell.textLabel?.text = aboutTitle
            case ProfileTableViewRow.Feedback:
                cell.textLabel?.text = feedbackTitle
            case ProfileTableViewRow.Legal:
                cell.textLabel?.text = legalTitle
            default:
                fatalError("All cases should be handled by switch.")
            }
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate methods

extension ProfileViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let profileTableViewRow = ProfileTableViewRow(rawValue: indexPath.row) {
            let viewController: UIViewController
            
            switch profileTableViewRow {
            case .About:
                viewController = WebViewController(endpoint: StaticContentEndpoint.About, title: "About")
            case .Feedback:
                viewController = FeedbackViewController(nibName: "FeedbackViewController", bundle: nil)
            case .Legal:
                viewController = LegalViewController(nibName: "LegalViewController", bundle: nil)
            default:
                fatalError("All cases should be handled by switch.")
            }
            
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.setSelected(false, animated: true)
        }
    }
}

// MARK: UserDidSignInListener methods

extension ProfileViewController: UserDidSignInListener {
    func userDidSignIn() {
        let _ = view // this is to ensure the view is loaded from the xib before updating any of the outlets. Otherwise it will crash
        
        updateCurrentUser()
    }
}
