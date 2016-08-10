import UIKit

/**
This class is responsible for parsing responses from web services.
*/
class WebServiceResponseSerializer: NSObject {
    
    // MARK: Constants
    
    /// Domain used for server errors.
    static let ErrorDomain = "com.whosdriving.servererror"
    
    // MARK: Instance methods
    
    /**
    Parses the NSURLRequest, NSHTTPURLResponse, and Result returned from the server for the
    responseObject and any errors.
    
    - parameter urlRequest The NSURLRequest to parse.
    - parameter urlResponse The NSHTTPURLResponse to parse.
    - parameter result The Result object to parse.
    - parameter completion Completion block called when the call to the server completes.
    */
    func parseResponse(urlRequest: NSURLRequest?, urlResponse: NSHTTPURLResponse?, result: Result<AnyObject, NSError>, completion: (responseObject: AnyObject?, error: NSError?) -> Void) {
        var error: NSError?
        var responseObj: AnyObject?
        var userInfo: [String: AnyObject]?

        if urlResponse != nil {
            if urlResponse!.statusCode >= 400 && urlResponse!.statusCode <= 599 {
                // error handling
                
                switch result{
                case .Failure(_):
                    userInfo = [NSLocalizedFailureReasonErrorKey: NSHTTPURLResponse.localizedStringForStatusCode(urlResponse!.statusCode)]
                case .Success(let response):
                    responseObj = response
                    if let data = response[ServiceResponse.DataKey] as? [String: AnyObject] {
                        if let failureReason = data[ServiceResponse.MessageKey] as? String {
                            userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
                        }
                    }
                }
                
                error = NSError(domain: WebServiceResponseSerializer.ErrorDomain, code: urlResponse!.statusCode, userInfo: userInfo)
                dLog("Request: \(urlRequest) ERROR: \(error)")
            } else {
                // success handling
                switch result {
                case .Failure(_):
                    dLog("Success with no JSON object.")
                case .Success(let response):
                    responseObj = response
                }
            }
        } else {
            // no urlResponse
            
            switch result{
            case .Failure(let errorType):
                userInfo = [NSLocalizedFailureReasonErrorKey: userFriendlyStringFor(errorType)]
            case .Success(let response):
                responseObj = response
                if let data = response[ServiceResponse.DataKey] as? [String: AnyObject] {
                    if let failureReason = data[ServiceResponse.MessageKey] as? String {
                        userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
                    }
                }
            }
            
            error = NSError(domain: WebServiceResponseSerializer.ErrorDomain, code: 0, userInfo: userInfo)
            dLog("Request: \(urlRequest) ERROR: \(error)")
        }
        
        completion(responseObject: responseObj, error: error)
    }
    
    // MARK: Private Methods
    
    /**
     Parses an NSError object and returns a user friendly string describing what went wrong. This
     function only returns a specific user friendly message for errors where the user is able to do
     something to fix the error, otherwise, a default message is returned. This function currently 
     only handles `CFURLConnection`/`CFURLProtocol` errors. The definitions of the errors handled in 
     this function were found here: http://nshipster.com/nserror/.
     
     - parameter error: The error that needs to be parsed.
     
     - returns: A user friendly string describing what went wrong.
     */
    private func userFriendlyStringFor(error: NSError) -> String {
        switch error.code {
        case -1001:
            return NSLocalizedString("Oops, your request timed out. Please find a better network connection and try again.", comment: "Request Timed Out")
        case -1005:
            return NSLocalizedString("Oops, your request could not be completed at this time because we lost our network connection. Please verify your network connection and try again.", comment: "Network Connection Lost")
        case -1009:
            return NSLocalizedString("It looks like you're not connected to the internet. Please verify your internet connection and try again.", comment: "No Network Connection")
        case -1018:
            return NSLocalizedString("Oops, we couldn't complete your request because it appears international roaming is disabled on your device.", comment: "International Roaming Disabled")
        case -1019:
            return NSLocalizedString("Sorry, we're unable to process your request while you're on the phone. Please try agian when you're done.", comment: "Phone Call Active Error")
        case -1020:
            return NSLocalizedString("Oops, it looks like data has been disabled on your device. Please re-enable your data usage and try again.", comment: "Data Not Allowed")
        default:
            return NSLocalizedString("Oops. your request could not be completed at this time, please try again later.", comment: "Request Failed Default")
        }
    }
}
