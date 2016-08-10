import UIKit

/// This view controller provides a full screen webview. Pass in the URL to display and the url will 
/// be loaded and displayed.
class WebViewController: UIViewController {
    
    // MARK: Private Properties
    
    /// The URL to display in the web view.
    private let url: NSURL?
    
    // MARK: IBOutlets
    
    /// Loading spinner shown while the web view loads.
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    /// The full screen web view.
    @IBOutlet private weak var webView: UIWebView!
    
    // MARK: Init Methods
    
    /**
    Creates a new instance of this class.
    
    - parameter endpoint The endpoint to append to the BASE_URL. This URL is then shown in the web 
                         view.
    - parameter viewTitle The title of the view controller.
    
    - returns: Configured instance of this class.
    */
    required init(endpoint: String, title viewTitle: String) {
        let fullURLString = kBASE_URL.stringByAppendingString(endpoint)
        url = NSURL(string: fullURLString);
        
        super.init(nibName: "WebViewController", bundle: nil)
        
        title = viewTitle
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        if let viewURL = url {
            let urlRequest = NSURLRequest(URL: viewURL)
            webView.loadRequest(urlRequest)
        }
    }
}

// MARK: UIWebViewDelegate Methods

extension WebViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.startAnimating()
    }
}