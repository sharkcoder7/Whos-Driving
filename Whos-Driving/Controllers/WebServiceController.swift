import UIKit

/**
 *  This delegate is responsible for handling certain important errors.
 */
protocol WebServiceControllerErrorDelegate: class {
    
    /**
     The WebServiceController encountered an authentication issue when communicating with the server.
     The user should be logged out and prompted to log back in.
     
     - parameter webServiceController The sender of this method.
     */
    func webServiceControllerEncounteredAuthError(webServiceController: WebServiceController)
    
    /**
     The WebServiceController encountered a kill switch when communicating with the server. The user
     should be informed that they need to upgrade to the latest version of the app.
     
     - parameter webServiceController The sender of this method.
     - parameter message              The message to display to the user.
     */
    func webServiceControllerEncounteredKillSwitch(webServiceController: WebServiceController, message: String)
}

/// Controller that handles communicating with the web.
class WebServiceController: NSObject {
    
    // MARK: Constants
    
    /// This version number can be used in place of the actual version number in the user agent 
    /// string to test "kill switch" functionality.
    private static let KillSwitchVersion = "99.99.99"
    
    /// Shared singleton of this class.
    static let sharedInstance = WebServiceController()
    
    // MARK: Public properties
    
    /// The error delegate of this class responsible for handling special error codes.
    weak var errorDelegate: WebServiceControllerErrorDelegate?
    
    /// True if an authentication has been added to the HTTP headers.
    var hasAuthenticationToken = false
    
    // MARK: Private properties
    
    /// The URL for the server.
    private let baseURLString = kBASE_URL
    
    /// The configured Manager object.
    private var manager = Manager(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    /// The current version of the Who's Driving api to use.
    private let urlVersionString = "api/v1/"
    
    // MARK: Init and deinit methods
    
    override init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
        manager = Manager(configuration: configuration)
        super.init()
        
        // Check if an auth token is saved in the keychain. If so, add it to the HTTP Headers.
        if let tokenData = Keychain.load(Keychain.authTokenKey) {
            if let token = NSString(data: tokenData, encoding: NSUTF8StringEncoding) as String? {
                addAuthenticationToken(token)
                
                dLog("Loaded saved auth token")
            }
        }
        
        let userAgent = userAgentString()
        let headersDictionary = [
            RequestHeaders.AcceptHeaderKey : RequestHeaders.ApplicationJSON,
            RequestHeaders.ContentTypeKey : RequestHeaders.ApplicationJSON,
            RequestHeaders.UserAgentKey : userAgent,
        ]
        addHTTPHeaders(headersDictionary)
    }
    
    // MARK: Instance Methods
    
    /**
    Add the provided authentication token to the HTTP headers.
    
    - parameter token The authentication token received from the server to use for further communication.
    */
    func addAuthenticationToken(token: String) {
        if let tokenData = token.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            Keychain.save(Keychain.authTokenKey, data: tokenData)
        }
        
        let formattedToken: String = "Token token=\"" + token + "\""
        let headersDictionary = [RequestHeaders.AuthorizationKey : formattedToken]
        addHTTPHeaders(headersDictionary)
        hasAuthenticationToken = true
    }
    
    /**
     Perform a DELETE request with the provided endpoint and parameters.
     
     - parameter endpoint The endpoint to send the request to.
     - parameter parameters The parameters to send to the endpoint.
     - parameter completion Completion block called when the call to the server completes.
     */
    func delete(endpoint: String, parameters: [String : AnyObject]?, completion: ((responseObject: AnyObject?, error: NSError?) -> Void)?) {
        performRequest(.DELETE, endpoint: endpoint, parameters: parameters, completion: completion)
    }
    
    /**
     Perform a GET request with the provided endpoint and parameters.
     
     - parameter endpoint The endpoint to send the request to.
     - parameter parameters The parameters to send to the endpoint.
     - parameter completion Completion block called when the call to the server completes.
     */
    func get(endpoint: String, parameters: [String : AnyObject]?, completion: ((responseObject: AnyObject?, error: NSError?) -> Void)?) {
        performRequest(.GET, endpoint: endpoint, parameters: parameters, completion: completion)
    }
    
    /**
     Perform a POST request with the provided endpoint and parameters.
     
     - parameter endpoint The endpoint to send the request to.
     - parameter parameters The parameters to send to the endpoint.
     - parameter completion Completion block called when the call to the server completes.
     */
    func post(endpoint: String, parameters: [String : AnyObject]?, completion: ((responseObject: AnyObject?, error: NSError?) -> Void)?) {
        performRequest(.POST, endpoint: endpoint, parameters: parameters, encoding: ParameterEncoding.JSON, completion: completion)
    }
    
    /**
     Perform a PUT request with the provided endpoint and parameters.
     
     - parameter endpoint The endpoint to send the request to.
     - parameter parameters The parameters to send to the endpoint.
     - parameter completion Completion block called when the call to the server completes.
     */
    func put(endpoint: String, parameters: [String : AnyObject]?, completion: ((responseObject: AnyObject?, error: NSError?) -> Void)?) {
        performRequest(.PUT, endpoint: endpoint, parameters: parameters, encoding: ParameterEncoding.JSON, completion: completion)
    }
    
    /**
     Remove the current authentication token.
     */
    func removeAuthenticationToken() {
        Keychain.delete(Keychain.authTokenKey)
        Keychain.delete(Keychain.currentUserIdKey)
        AnalyticsController().reset()
        let headersDictionary = [RequestHeaders.AuthorizationKey : ""]
        addHTTPHeaders(headersDictionary)
        hasAuthenticationToken = false
        
        dLog("Removed auth token")
    }
    
    // MARK: Private methods
    
    /**
    Add a dictionary of HTTP headers to the manager.
    
    - parameter headersDictionary Dictionary of HTTP headers.
    */
    private func addHTTPHeaders(headersDictionary: [NSObject : AnyObject]) {
        
        var mutableHTTPHeaders = manager.session.configuration.HTTPAdditionalHeaders
        mutableHTTPHeaders?.update(headersDictionary)
        let config = manager.session.configuration
        config.HTTPAdditionalHeaders = mutableHTTPHeaders
        
        manager = Manager(configuration: config)
    }
    
    /**
     Perform the provided request type with the endpoint and parameters.
     
     - parameter method The type of HTTP request to use.
     - parameter endpoint The endpoint to send the request to.
     - parameter parameters The parameters to send to the endpoint.
     - parameter encoding The encoding to use. Defaults to URL.
     - parameter completion Completion block called when the call to the server completes.
     */
    private func performRequest(method: Method, endpoint: String, parameters: [String : AnyObject]?, encoding: ParameterEncoding = ParameterEncoding.URL, completion: ((responseObject: AnyObject?, error: NSError?) -> Void)?) {
        let url = urlWithEndpoint(endpoint)
        
        manager.request(method, url, parameters: parameters, encoding: encoding)
            .responseJSON {
                response in
                WebServiceResponseSerializer().parseResponse(response.request, urlResponse: response.response, result: response.result, completion: { [weak self] (responseObject, error) -> Void in
                    // check error for special error codes
                    if let unwrappedError = error {
                        if unwrappedError.code == ErrorCodes.AuthErrorCode {
                            dLog("Encountered auth error, removing auth token")
                            self?.removeAuthenticationToken()
                            self?.errorDelegate?.webServiceControllerEncounteredAuthError(self!)
                        } else if unwrappedError.code == ErrorCodes.KillSwitchErrorCode {
                            dLog("Encountered kill switch")
                            self?.errorDelegate?.webServiceControllerEncounteredKillSwitch(self!, message: unwrappedError.localizedDescription)
                        }
                    }
                    
                    completion!(responseObject: responseObject, error: error)
                })
        }
    }
    
    /**
     Creates the user agent string to use for the current device.
     
     - returns: The user agent string.
     */
    private func userAgentString() -> String {
        let appVersion = kVERSION
        let device = UIDevice.currentDevice()
        let system = device.systemName
        let version = device.systemVersion
        let identifier = device.modelIdentifier
        let userAgent = "WhosDriving/\(appVersion) (iOS; \(system) \(version); \(identifier))"
        return userAgent
    }
    
    /**
     Returns a full formed URL by combining the server base URL, the api version, and the provided
     endpoint.
     
     - parameter endpoint The endpoint on the server.
     
     - returns: Full URL for the server for the provided endpoint.
     */
    private func urlWithEndpoint(endpoint: String?) -> NSURL {
        let apiBaseURLString = baseURLString.stringByAppendingString(urlVersionString)
        let baseURL = NSURL(string: apiBaseURLString)
        
        if  endpoint == nil {
            return baseURL!
        }
        
        let url = NSURL(string: endpoint!, relativeToURL: baseURL)
        
        return url!
    }
}