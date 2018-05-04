//
//  TouchIDAuthentication.swift
//  FlashBack
//
//  Created by Vishnu V Ram on 5/3/18.
//  Copyright © 2018 Shannthini. All rights reserved.
//

import Foundation
import LocalAuthentication

enum BiometricType {
    case none
    case touchID
    case faceID
}

class BiometricIDAuth {
    
    let context = LAContext()
    var loginReason = "Logging in with Touch ID"

    
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    
    func  biometricType() -> BiometricType {
        
            if (context.biometryType == LABiometryType.typeFaceID) {
                // Device support Face ID
                return .faceID
            } else if context.biometryType == LABiometryType.typeTouchID {
                // Device supports Touch ID
                return .touchID
            } else {
                // Device has no biometric support
                return .none
            }
    }
    
    func authenticateUser(completion: @escaping (String?) -> Void) {
        
        //to check if the device is capable of biometric authentication
        guard canEvaluatePolicy() else {
            completion("Touch ID not available")
            return
        }
        
        // prompt the user for biometric ID authentication
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,localizedReason: loginReason)
            { (success, evaluateError) in
            // Handling success
            if success {DispatchQueue.main.async {
                // User authenticated successful, take appropriate action
                completion(nil)
            }
            } else {
                let message: String
                
                // error cases
                switch evaluateError {
                
                case LAError.biometryLockout?:
                    message = "Authentication was not successful, because there were too many failed Touch ID attempts and Touch ID is now locked. Passcode is required to unlock Touch ID"
                    
                case LAError.biometryNotAvailable?:
                    message = "Authentication could not start, because Touch ID is not available on the device"
                    
                case LAError.biometryNotEnrolled?:
                    message = "Authentication could not start, because Touch ID is not enrolled on the device"
                
                case LAError.authenticationFailed?:
                    message = "Authentication was not successful, because user failed to provide valid credentials"
                    
                case LAError.appCancel?:
                    message = "Authentication was canceled by application"
                    
                case LAError.invalidContext?:
                    message = "LAContext passed to this call has been previously invalidated"
                    
                case LAError.notInteractive?:
                    message = "Authentication failed, because it would require showing UI which has been forbidden by using interactionNotAllowed property"
                    
                case LAError.passcodeNotSet?:
                    message = "Authentication could not start, because passcode is not set on the device"
                    
                case LAError.systemCancel?:
                    message = "Authentication was canceled by system"
                    
                case LAError.userCancel?:
                    message = "Authentication was canceled by user"
                    
                case LAError.userFallback?:
                    message = "Authentication was canceled, because the user tapped the fallback button"
                    
                case LAError.biometryNotAvailable?:
                    message = "Authentication could not start, because biometry is not available on the device"
                    
                case LAError.biometryLockout?:
                    message = "Authentication was not successful, because there were too many failed biometry attempts and                          biometry is now locked"
                    
                case LAError.biometryNotEnrolled?:
                    message = "Authentication could not start, because biometric authentication is not enrolled"
                    
                default:
                    message = "Face ID/Touch ID may not be configured"
                    
                    
                    
                    
                    
                    
                /*case LAError.authenticationFailed?:
                    message = "There was a problem verifying your identity."
                case LAError.userCancel?:
                    message = "You pressed cancel."
                case LAError.userFallback?:
                    message = "You pressed password."
                case LAError.biometryNotAvailable?:
                    message = "Face ID/Touch ID is not available."
                case LAError.biometryNotEnrolled?:
                    message = "Face ID/Touch ID is not set up."
                case LAError.biometryLockout?:
                    message = "Face ID/Touch ID is locked."
                default:
                    message = "Face ID/Touch ID may not be configured" */
                }
                completion(message)
            }
        }
    }
    
    
    
    
}
