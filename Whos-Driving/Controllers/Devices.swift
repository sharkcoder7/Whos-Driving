import UIKit

/// Controller for registering devices with the server for push notifications.
class Devices: NSObject {
    
    // MARK: Private properties
    
    private let AppVersionKey = "app_version"
    private let DeviceIdentifierKey = "device_identifier"
    private let DeviceTokenKey = "device_token"
    private let ModelKey = "model"
    private let OSVersionKey = "os_version"
    private let PlatformKey = "platform"

    // MARK: Instance methods
    
    /**
    Registers the device with the server for push notifications. The token data should be the token
    received from -application:didRegisterForPushNotificationsWithDeviceToken:
    
    Note: This method will in very rare circumstances fail if the device identifier is not available. 
    See the docs for UIDevice identifierForVendor.
    
    - parameter tokenData  The token received from the apple push notification server when registering.
    - parameter completion Completion block called after attempting to register with the server.
    */
    func registerDevice(tokenData: NSData, completion: (error: NSError?) -> Void) {
        var token = tokenData.description
        let characterSet = NSCharacterSet(charactersInString: "<>")
        token = token.stringByTrimmingCharactersInSet(characterSet)
        token = token.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        if var parameters = createDeviceParameters() {
            parameters.updateValue(token, forKey: DeviceTokenKey)
            
            WebServiceController.sharedInstance.post(ServiceEndpoint.Devices, parameters: parameters) { (responseObject, error) -> Void in
                
                completion(error: error)
            }
        } else {
            let error = localError("Failed because UIDevice identifierForVendor was nil")
            completion(error: error)
        }
    }
    
    // MARK: Private methods
    
    /**
    Creates a dictionary of device parameters to send to the server when registering a device.
    In rare cases, this can return nil if UIDevice -identiferForVendor is nil. See docs for details.
    
    - returns: A dictionary of device parameters to send to the server.
    */
    private func createDeviceParameters() -> [String : AnyObject]? {
        var parameters: [String : AnyObject]?
        let device = UIDevice.currentDevice()
        
        // device ID might be nil in very rare circumstances (see docs).
        if let deviceId = device.identifierForVendor {
            let appVersion = kVERSION
            let version = "iOS \(device.systemVersion)"
            let modelId = device.modelIdentifier
            
            parameters = [
                DeviceIdentifierKey : deviceId.UUIDString,
                PlatformKey : "ios",
                AppVersionKey : appVersion,
                ModelKey : modelId,
                OSVersionKey : version,
            ]
        }
        
        return parameters
    }
}
