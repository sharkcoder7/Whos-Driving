import UIKit

/// This class manages resources for uploading to Amazon S3.
class UploadResources: NSObject {
    
    /**
     Fetches a presigned URL ready for an image to be uploaded to S3. Also returns the paired down
     path of where the image will be uploaded to. The presigned URL only is valid for 15 minutes.
     
     - parameter fileExtension The file extension of the file that's being uploaded to S3. If 
                               if unspecified, the server assumes JPG.
     - parameter completion Completion block called when the request finishes. Contains the resource
                            (presigned URL), the resourcePath (the path of where the image will be
                            on S3), and any errors encountered.
     */
    func getUploadResource(fileExtension fileExtension: String?, completion:(resource: String?, resourcePath: String?, error: NSError?) -> Void) {
        let endpoint = ServiceEndpoint.UploadResources
        
        WebServiceController.sharedInstance.post(endpoint, parameters: nil) { (responseObject, error) -> Void in
            if error != nil {
                completion(resource: nil, resourcePath: nil, error: error)
            } else {
                let responseDictionary = responseObject as? NSDictionary
                if let resourceDict = responseDictionary?[ServiceResponse.DataKey] as? NSDictionary {
                    let resourcePath = resourceDict[ServiceResponse.ResourcePathKey] as? String
                    let resource = resourceDict[ServiceResponse.ResourceKey] as? String
                    
                    completion(resource: resource, resourcePath: resourcePath, error: nil)
                }
            }
        }
    }
}
