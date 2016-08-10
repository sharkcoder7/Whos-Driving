import UIKit

/**
 Pages in the IntroViewController's collectionView.
 */
private enum IntroViewPage: NSInteger {
    /// The carpools list page.
    case CarpoolsList
    /// The carpoool details page.
    case CarpoolDetails
    /// The create carpool page.
    case CreateCarpool
    /// The add drivers and riders page.
    case AddDriversAndRiders
    /// Total number of pages. Should always be the last case in the enum.
    case PageCount
}

/// View controller shown the very first time the user opens the app.
class IntroViewController: UIViewController {
    
    // MARK: Constants
    
    /// The scale of the bottom container view to the total view size.
    static let bottomContainerScale: CGFloat = 0.42
    
    /// Key check to see if the user has previously viewed the IntroViewController.
    static let introViewDisplayedKey = "IntroViewDisplayed"
    
    // MARK: Properties
    
    /// This delegate gets passed to the SignInViewController when it's presented. 
    weak var signInDelegate: SignInViewControllerDelegate?
    
    // MARK: Private Properties
    
    /// Gradient layer in the bottomContainerView.
    private let gradientLayer = CAGradientLayer()

    // MARK: IBOutlets

    /// Height constraint for the bottom container view.
    @IBOutlet private weak var bottomContainerHeightConstraint: NSLayoutConstraint!
    
    /// The view at the bottom of view controller.
    @IBOutlet private weak var bottomContainerView: UIView!
    
    /// Collection view of the different pages of the intro.
    @IBOutlet private weak var collectionView: UICollectionView!
    
    /// Button to go to the app and get started.
    @IBOutlet private weak var getStartedButton: UIButton!
    
    /// The UIPageControl showing what page the user is currently on.
    @IBOutlet private weak var pageControl: UIPageControl!
    
    // MARK: Class Methods
    
    /**
     Creates a new instance of the view controller from the correct nib.
     
     - returns: a new instance of the view controller.
     */
    class func viewController() -> IntroViewController {
        let viewController = IntroViewController(nibName: "IntroViewController", bundle: nil)
        return viewController
    }
    
    // MARK: IBAction Methods
    
    /**
    Called when the getStartedButton is tapped.
    
    - parameter sender The button that was tapped.
    */
    @IBAction func getStartedTapped(sender: UIButton) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: IntroViewController.introViewDisplayedKey)
        
        let signInViewController = SignInViewController(nibName: "SignInViewController", bundle: nil)
        signInViewController.delegate = signInDelegate
        navigationController?.pushViewController(signInViewController, animated: true)
    }
    
    /**
     Called when the UIPageControl's page value changes.
     
     - parameter sender The UIPageControl that changed.
     */
    @IBAction func pageControlValueChanged(sender: UIPageControl) {
        let newPage = sender.currentPage
        let viewWidth = collectionView.frame.width
        
        let scrollPoint = CGPointMake(CGFloat(newPage) * viewWidth, collectionView.contentOffset.y)
        collectionView.setContentOffset(scrollPoint, animated: true)
        
        animateGetStartedButton()
    }
    
    // MARK: Private Methods
    
    /**
    Animates the getStartedButton to be showing.
    */
    func animateGetStartedButton() {
        let displayGetStarted = (pageControl.currentPage == IntroViewPage.PageCount.rawValue - 1)
        let getStartedAlpha = (displayGetStarted) ? 1.0 : 0.0
        let pageControlAlpha = (displayGetStarted) ? 0.0 : 1.0
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.getStartedButton.alpha = CGFloat(getStartedAlpha)
            self.pageControl.alpha = CGFloat(pageControlAlpha)
        }
    }

    // MARK: UIViewController Methods
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradientLayer.frame = bottomContainerView.bounds
        bottomContainerHeightConstraint.constant = view.frame.size.height * IntroViewController.bottomContainerScale
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AppConfiguration.lightBlue()
        bottomContainerView.backgroundColor = AppConfiguration.blue()
        
        let translucentBlack = UIColor(white: 0.0, alpha: 0.15)
        let colors = [translucentBlack.CGColor, UIColor.clearColor().CGColor]
        gradientLayer.colors = colors
        gradientLayer.endPoint = CGPointMake(0.5, 0.3)
        
        bottomContainerView.layer.addSublayer(gradientLayer)
        
        let cellNib = UINib(nibName: "IntroCell", bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: IntroCell.reuseIdentifier)
        
        pageControl.numberOfPages = IntroViewPage.PageCount.rawValue
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

// MARK: UICollectionViewDataSource methods

extension IntroViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(IntroCell.reuseIdentifier, forIndexPath: indexPath) as! IntroCell

        if let collectionViewItem = IntroViewPage(rawValue: indexPath.item) {
            switch collectionViewItem {
            case .CarpoolsList:
                cell.titleLabel.text = "List of carpools"
                cell.subTitleLabel.text = "See carpools relevant to you."
                cell.imageView.image = UIImage(named: "intro-step1")
                
            case .CarpoolDetails:
                cell.titleLabel.text = "Carpool details"
                cell.subTitleLabel.text = "See location, who's driving,\nwho's riding, and more!"
                cell.imageView.image = UIImage(named: "intro-step2")
                
            case .CreateCarpool:
                cell.titleLabel.text = "Create carpools"
                cell.subTitleLabel.text = "Easily create your own carpools and\nassign drivers and riders."
                cell.imageView.image = UIImage(named: "intro-step3")
                
            case .AddDriversAndRiders:
                cell.titleLabel.text = "Add drivers & riders"
                cell.subTitleLabel.text = "Manage your list of drivers and riders."
                cell.imageView.image = UIImage(named: "intro-step4")
                
            case .PageCount:
                fatalError("Page Count is not a valid page for display. The value should only be used to determine the total number of pages.")
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return IntroViewPage.PageCount.rawValue
    }
}

// MARK: UICollectionViewDelegateFlowLayout methods

extension IntroViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.frame.width, collectionView.frame.height)
    }
}

// MARK: UIScrollViewDelegate methods

extension IntroViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
        let viewWidth = scrollView.frame.width
        let pageOffset = contentOffsetX / viewWidth
        pageControl.currentPage = lroundf(Float(pageOffset))
        
        animateGetStartedButton()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
        let viewWidth = scrollView.frame.width
        let pageOffset = contentOffsetX / viewWidth
        
        let visibleCells = collectionView.visibleCells()
        
        for cell in visibleCells as! [IntroCell] {
            cell.setPageOffset(pageOffset)
        }
    }
}
