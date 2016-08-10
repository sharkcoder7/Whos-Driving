import UIKit

/**
 Rows in the LegalViewController's table view.
 */
private enum LegalTableViewRow: NSInteger {
    /// Row for Terms & Conditions
    case Terms
    /// Row for Privacy Policy
    case Privacy
    /// Total number of rows. Always should be the last case in the enum.
    case NumberOfRows
}

/// View controller showing links to legal forms such as the Terms & Conditions.
class LegalViewController: UIViewController {

    // MARK: Constants 
    
    /// Title of the Privacy row.
    private let privacyTitle = "Privacy"
    
    /// Reuse identifier for the table view.
    private let reuseID = "LegalViewControllerCellReuseID"
    
    /// Title of the Terms row.
    private let termsTitle = "Terms & Conditions"
    
    // MARK: IBOutlets
    
    /// Table view showing the different links to view.
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: UIViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        title = NSLocalizedString("Legal", comment: "Legal view title.")
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseID)
        view.backgroundColor = AppConfiguration.offWhite()
    }
}

// MARK: UITableViewDataSource methods

extension LegalViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LegalTableViewRow.NumberOfRows.rawValue
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let viewModel = MenuCellViewModel()
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath) 
        cell.backgroundColor = viewModel.backgroundColor()
        cell.accessoryType = viewModel.accessoryType()
        cell.textLabel?.font = viewModel.font()
        cell.textLabel?.textColor = viewModel.textColor()
        
        if let profileTableViewRow = LegalTableViewRow(rawValue: indexPath.row) {
            switch profileTableViewRow {
            case .Terms:
                cell.textLabel?.text = termsTitle
            case .Privacy:
                cell.textLabel?.text = privacyTitle
            default:
                fatalError("All cases should be handled by switch.")
            }
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate methods

extension LegalViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let legalTableViewRow = LegalTableViewRow(rawValue: indexPath.row) {
            let viewController: UIViewController
            
            switch legalTableViewRow {
            case .Terms:
                viewController = WebViewController(endpoint: StaticContentEndpoint.Terms, title: "Terms and Conditions")
            case .Privacy:
                viewController = WebViewController(endpoint: StaticContentEndpoint.Privacy, title: "Privacy Policy")
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
