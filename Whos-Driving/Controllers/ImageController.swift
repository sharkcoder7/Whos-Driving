import UIKit

/// This class is responsible for uploading images to S3, caching local versions of uploaded images
/// and loading images to be displayed in the app.
class ImageController: NSObject {
    
    // MARK: Constants
    
    /// Threshold before an expiration date is considered expired. This is to prevent a request to be
    /// made using S3 credentials that are initially valid but expire during the request.
    private let ExpirationThreshold: NSTimeInterval = -60
    
    // MARK: Public properties
    
    /// Singleton for this class
    static let sharedInstance = ImageController()
    
    // MARK: Private Properties
    
    /// Local cache of images. The key is the ID of the user the image is for, and the value is an
    /// NSURL to the local file path for the image.
    private var localImageCache = [String : NSURL]()
    
    // MARK: Instance methods
    
    /**
    Load the image for a Person.
    
    - parameter person The person to load the image for.
    - parameter completion Closure with the loaded image, or an error if one was encountered. The 
                           image will be nil if the user doesn't have a user image or if there was 
                           an error.
    */
    func loadImageForPerson(person: Person?, completion: (image: UIImage?, error: NSError?) -> Void) {
        var imageUrl: NSURL?
        
        if let url = person?.imageURL {
            imageUrl = NSURL(string: url)
        }
        
        loadImageURL(imageUrl, userID: person?.id, completion: { (image, error) -> Void in
            completion(image: image, error: error)
        })
    }
    
    /**
    Load an image from a web URL, or load the local cached image for a particular user ID.
    
    - parameter imageURL Web URL to load the image from.
    - parameter userID User ID of the user this image is for. If this parameter is provided the
                       local image cache is checked first to see if there's a local image.
    - parameter completion Closure with the loaded image, or an error if one was encountered.
                           Image will be nil if no imageURL is provided and no local image exists.
    */
    func loadImageURL(imageURL: NSURL?, userID: String?, completion: (image: UIImage?, error: NSError?) -> Void) {
        // check if there's a local image
        if let unwrappedUserId = userID {
            if let localImageUrl = localImageCache[unwrappedUserId] {
                if let data = NSData(contentsOfURL: localImageUrl) {
                    let image = UIImage(data: data)
                    // found local image, returning early
                    dLog("Found local image at: \(localImageUrl)")
                    completion(image: image, error: nil)
                    return
                }
            }
        }
        
        // no local image, download the image
        if let unwrappedImageURL = imageURL {
            let manager = Manager.sharedInstance
            manager.request(.GET, unwrappedImageURL).response(completionHandler: { (request, response, data, error) -> Void in
                let error = error as NSError?
                
                if error != nil {
                    completion(image: nil, error: error)
                } else {
                    if let unwrappedData = data {
                        let image = UIImage(data: unwrappedData)
                        completion(image: image, error: error)
                    }
                }
            })
        } else {
            completion(image: nil, error: nil)
        }
    }
    
    /**
    Update the local image cache.
    
    - parameter userId The user ID associated with the image.
    - parameter localUrl The file path to the local image file.
    */
    func updateLocalImageCache(userId: String, localUrl: NSURL) {
        localImageCache.updateValue(localUrl, forKey: userId)
    }

    /**
    Upload an image to S3 and save a version locally to the device.
    
    - parameter image The image to upload.
    - parameter userId The user ID this image is associated with.
    - parameter completion Closure called when the operation finishes. The localURL is the local
                           file path the image was saved to. The s3URL is the relative web URL of
                           the image. Error object will contain an error if one was encountered.
    */
    func uploadImage(image: UIImage, userId: String?, completion: (localURL: NSURL?, s3URL: String?, error: NSError?) -> Void) {
        if let data = UIImageJPEGRepresentation(image, 0.3) {
            
            //Create a file in the temporary directory
            let randomUUID = NSUUID().UUIDString
            let localFileURL = NSURL.fileURLWithPath(NSTemporaryDirectory() + randomUUID)
            data.writeToURL(localFileURL, atomically: true)
            
            UploadResources().getUploadResource(fileExtension: nil, completion: { (resource, resourcePath, error) -> Void in
                if error != nil {
                    completion(localURL: nil, s3URL: nil, error: error)
                } else {
                    
                    guard let endpoint = resource else {
                        let error = localError("Error loading resource to upload to S3.")
                        completion(localURL: nil, s3URL: nil, error: error)
                        return
                    }
                    
                    guard let endpointPath = resourcePath else {
                        let error = localError("Error loading resource to upload to S3.")
                        completion(localURL: nil, s3URL: nil, error: error)
                        return
                    }
                    
                    let url = NSURL(string: endpoint)!
                    
                    let request = NSMutableURLRequest(URL: url)
                    request.HTTPBody = data
                    request.HTTPMethod = "PUT"
                    
                    NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                        if error != nil {
                            dLog("Error: \(error)")
                            completion(localURL: nil, s3URL: nil, error: error)
                        } else {
                            completion(localURL: localFileURL, s3URL: endpointPath, error: error)
                        }
                    }).resume()
                }
            })
        }
    }
}
