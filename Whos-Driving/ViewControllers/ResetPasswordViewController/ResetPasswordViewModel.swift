import Foundation
import UIKit

/**
 An enumeration of the different states of the ResetPasswordViewController.
 
 - AcceptingUserInput:       The view controller is ready to accept users input.
 - PerformingNetworkRequest: A network request is being executed.
 - ResetComplete:            The network request completed.
 */
enum ResetPasswordState {
    case AcceptingUserInput
    case PerformingNetworkRequest
    case ResetComplete
}

/**
 *  An instance of ResetPasswordViewModel models the view of an instance of 
 *  ResetPasswordViewController.
 */
struct ResetPasswordViewModel {
    // MARK: Properties
    
    /// The alpha of the activity indicator view.
    var activityIndicatorViewAlpha: CGFloat = 0.0
    
    /// The alpha of the cancel button.
    var cancelButtonAlpha: CGFloat = 0.0
    
    /// The text displayed by the email address text field.s
    var emailAddressText: String?
    
    /// The alpha of the email address label.
    var emailLabelAlpha: CGFloat = 0.0
    
    /// The alpha of the log-in button.
    var loginButtonAlpha: CGFloat = 0.0
    
    /// The alpha of the prompt label.
    var promptLabelAlpha: CGFloat = 0.0
    
    /// The text displayed by the prompt label.
    var promptLabelText: String?
    
    /// The state that should be reflected by the view controller.
    var state: ResetPasswordState = .PerformingNetworkRequest {
        didSet {
            switch state {
            case .AcceptingUserInput:
                configureForAcceptingUserInput()
            case .PerformingNetworkRequest:
                configureForExecutingNetworkRequest()
            case .ResetComplete:
                configureForResetComplete()
            }
        }
    }
    
    /// The alpha of the user input view.
    var userInputViewAlpha: CGFloat = 0.0
    
    // MARK: Private Methods
    
    /**
     Updates the view model to reflect the state of accepting user input.
     */
    private mutating func configureForAcceptingUserInput() {
        activityIndicatorViewAlpha = 0.0
        cancelButtonAlpha = 1.0
        emailLabelAlpha = 1.0
        loginButtonAlpha = 0.0
        promptLabelAlpha = 1.0
        promptLabelText = "Reset your password for"
        userInputViewAlpha = 1.0
    }
    
    /**
     Updates the view model to reflect the state of executing a network request.
     */
    private mutating func configureForExecutingNetworkRequest() {
        activityIndicatorViewAlpha = 1.0
        cancelButtonAlpha = 0.0
        emailLabelAlpha = 0.0
        loginButtonAlpha = 0.0
        promptLabelAlpha = 0.0
        userInputViewAlpha = 0.0
    }
    
    /**
     Updates the view model to reflect the state of a completed network request.
     */
    private mutating func configureForResetComplete() {
        activityIndicatorViewAlpha = 0.0
        cancelButtonAlpha = 0.0
        emailLabelAlpha = 0.0
        loginButtonAlpha = 1.0
        promptLabelAlpha = 1.0
        promptLabelText = "Success!"
        userInputViewAlpha = 0.0
    }
}
