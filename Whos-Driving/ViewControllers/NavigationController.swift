import UIKit

/// Custom UINavigationController that sets some initial properties by default.
class NavigationController: UINavigationController {
    
    // MARK: Init Methods
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        navigationBar.barTintColor = AppConfiguration.blue()
        navigationBar.tintColor = AppConfiguration.white()
        navigationBar.titleTextAttributes = self.titleTextAttributes()
        navigationBar.translucent = false
        navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationBar.shadowImage = UIImage()
    }
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private Methods
    
    /**
    Text attributes to use for the navigationBar.
    
    - returns: Dictionary of titleTextAttributes for the navigationBar.
    */
    private func titleTextAttributes() -> Dictionary<String, AnyObject>? {
        return [NSForegroundColorAttributeName : AppConfiguration.white(), NSFontAttributeName : UIFont(name: Font.HelveticaNeueMedium, size: 17)!]
    }
}
