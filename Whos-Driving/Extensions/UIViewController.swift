import Foundation
import UIKit

extension UIViewController {
    /**
     Shows/hides a view either animated or not.
     
     - parameter view:     the view to be shown/hidden.
     - parameter show:     a boolean indicating if the view is being shown or hidden. True to show
     the view, else false.
     - parameter animated: a boolean indicating if the view should be animated on to/off the screen.
     */
    func show(view: UIView, show: Bool, animated: Bool) {
        let animations: () -> () = {
            view.alpha = show ? 1.0 : 0.0
        }
        
        let duration = animated ? 0.3 : 0.0
        
        UIView.animateWithDuration(duration, animations: animations)
    }
}
