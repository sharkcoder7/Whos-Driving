import Foundation
import UIKit

#if DEBUG
    func dLog(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
        print("[\((filename as NSString).lastPathComponent):\(line)] \(function) - \(message)")
    }
#else
    func dLog(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
    }
#endif

/**
Creates the default UIAlertController with the provided message. The title will be "Error" and the
cancel button will read "OK".

- parameter message The message to display in the alert controller.

- returns: The default UIAlertController with the provided message.
*/
func defaultAlertController(message: String) -> UIAlertController {
    let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
    return alertController
}

/**
Convenience method to easily create a dispatch_time_t.

- parameter timeInterval Time interval since now to use for the dispatch_time_t.

- returns: A dispatch_time_t using the timeInterval relative to now.
*/
func dispatchTimeSinceNow(timeInterval: Double) -> dispatch_time_t {
    return dispatch_time(DISPATCH_TIME_NOW, Int64(timeInterval * Double(NSEC_PER_SEC)))
}

/**
 Creates a local error with status code 0 and the provided localized failure reason.
 
 - parameter errorMessage The message to use for the localized failure reason.
 
 - returns: Local error.
 */
func localError(errorMessage: String) -> NSError {
    return NSError(domain: "com.whosdriving.localerror", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey : errorMessage])
}

/**
Helper method for sending objects to the server. If an object is not nil, returns the object as is.
If it's nil, returns NSNull.

Additionally, in the case of String objects, the String will be trimmed of leading/trailing 
whitespace characters. If after being trimmed it is an empty string, NSNull will be returned instead.

- parameter object The object to evaluate.

- returns: The object, or NSNull.
*/
func objOrNull(object: AnyObject?) -> AnyObject {
    var objOrNull = object
    
    if let string = objOrNull as? String {
        objOrNull = string.trimmedStringOrNil()
    }
    
    if objOrNull != nil {
        return objOrNull!
    }
    else {
        return NSNull()
    }
}