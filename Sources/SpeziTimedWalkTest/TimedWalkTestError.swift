//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CoreMotion
import Foundation


/// Error that might occur during a timed walk test.
public enum TimedWalkTestError: LocalizedError, Codable {
    /// Could not retrieve pedometer access, please ask the user to provide access in the settings app.
    case unauthorized
    /// Could not retrieve valid date from the pedometer.
    case invalidData
    /// Unknown error that occured during the execution.
    case unknown
    
    
    private var errorDescriptionValue: String.LocalizationValue {
        switch self {
        case .unauthorized:
            return "Unauthorized Error"
        case .invalidData:
            return "Invalid Data Error"
        case .unknown:
            return "Unknown Error"
        }
    }
    
    
    private var failureReasonDescriptionValue: String.LocalizationValue {
        switch self {
        case .unauthorized:
            return "Pedometer access is not authorized"
        case .invalidData:
            return "Pedometer data is invalid"
        case .unknown:
            return "Unknown"
        }
    }

    
    public var errorDescription: String? {
        .init(localized: errorDescriptionValue, bundle: .module)
    }
    
    public var failureReason: String? {
        .init(localized: failureReasonDescriptionValue, bundle: .module)
    }
    
    
    init(errorCode: Int) {
        switch errorCode {
        case Int(CMErrorNilData.rawValue), Int(CMErrorSize.rawValue), Int(CMErrorDeviceRequiresMovement.rawValue),
            Int(CMErrorInvalidAction.rawValue), Int(CMErrorInvalidParameter.rawValue):
            self = .invalidData
        case Int(CMErrorUnknown.rawValue), Int(CMErrorNULL.rawValue):
            self = .unknown
        default:
            self = .unauthorized
        }
    }
}
