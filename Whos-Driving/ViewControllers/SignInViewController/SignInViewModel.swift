import Foundation
import UIKit

enum SignInState {
    case Default
    case SigningIn
    case SignInComplete
}

struct SignInViewModel {
    
    // MARK: Properties
    
    var activityIndicatorAlpha: CGFloat {
        get {
            switch state {
            case .Default:
                return 0.0
            case .SigningIn:
                return 1.0
            case .SignInComplete:
                return 0.0
            }
        }
    }
    
    var credentialContainerAlpha: CGFloat {
        get {
            switch state {
            case .Default:
                return 1.0
            case .SigningIn:
                return 0.0
            case .SignInComplete:
                return 0.0
            }
        }
    }
    
    var emailSignInEnabled: Bool {
        get {
            let fieldIsValid: (FieldValidator?) -> (Bool) = { return $0?.isNotEmpty() ?? false }
            return fieldIsValid(emailValidator) && fieldIsValid(passwordValidator)
        }
    }
    
    var logoViewAlpha: CGFloat {
        get {
            switch state {
            case .Default:
                return 1.0
            case .SigningIn:
                return 1.0
            case .SignInComplete:
                return 0.0
            }
        }
    }
    
    var separatorViewAlpha: CGFloat {
        get {
            switch state {
            case .Default:
                return 1.0
            case .SigningIn:
                return 0.0
            case .SignInComplete:
                return 0.0
            }
        }
    }
    
    var signInButtonAlpha: CGFloat {
        get {
            switch state {
            case .Default:
                return 1.0
            case .SigningIn:
                return 0.0
            case .SignInComplete:
                return 0.0
            }
        }
    }
    
    var state: SignInState = .Default
    
    // MARK: Private Properties
    
    var emailValidator: EmailFieldValidator?
    
    var passwordValidator: PasswordFieldValidator?
}
