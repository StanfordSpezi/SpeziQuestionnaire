//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension QuestionnaireResponses {
    enum ResponseValidationResult: Sendable {
        /// The response provided for the task is ok.
        case ok
        /// The response provided for the task is invalid.
        case invalid(message: LocalizedStringResource)
        
        /// Creates a ``invalid(message:)`` localized to the specified bundle.
        ///
        /// - Important: Use this function when creating `invalid` results within the package, to ensure that the localization is picked up correctly.
        static func invalid(message: String.LocalizationValue, bundle: Bundle) -> Self {
            .invalid(message: LocalizedStringResource(message, bundle: bundle))
        }
        
        var isOk: Bool {
            switch self {
            case .ok:
                true
            case .invalid:
                false
            }
        }
        
        var isInvalid: Bool {
            switch self {
            case .ok:
                false
            case .invalid:
                true
            }
        }
    }
    
    
    func validateResponse( // swiftlint:disable:this function_body_length cyclomatic_complexity
        for task: Questionnaire.Task
    ) -> ResponseValidationResult {
        guard hasResponse(for: task) else {
            // if no response exists, there is nothing that could be invalid.
            // were we to report this as being invalid, every questionnaire would,
            // the instant it's opened, turn bright red bc every question would complain about an invalid response
            return .ok
        }
        switch task.kind {
        case .instructional:
            // instructional tasks never can have a response, so they're always ok
            return .ok
        case .boolean:
            // the user cannot provide an invalid response for boolean tasks
            return .ok
        case .choice(let config):
            // when we support an `"other" with custom string entry" option, we'll need to validate that the string isn't empty.
            // not a problem for now
            if config.hasFreeTextOtherOption {
                guard let response = responses[task.id].value.choiceValue.freeTextOtherResponse else {
                    // this option isn't selected, so we're good
                    return .ok
                }
                guard !response.isEmpty else {
                    return .invalid(message: "Missing response text for \"Other\" option", bundle: .module)
                }
                return .ok
            } else {
                // NOTE that we intentionally don't validate nested responses here.
                // it should only be possible to leave the nested response answering sheet,
                // if either all responses there are valid, or by canceling, in which case the responses there are discarded.
                return .ok
            }
        case .freeText(let config):
            guard let response = responses[task.id].value.stringValue else {
                return .ok
            }
            if let minLength = config.minLength, response.count < minLength {
                return .invalid(message: "Too short: must be at least \(minLength) characters", bundle: .module)
            }
            if let maxLength = config.maxLength, response.count > maxLength {
                return .invalid(message: "Too long: can be at most \(maxLength) characters", bundle: .module)
            }
            let responseNSString = response as NSString
            let wholeStringRange = NSRange(location: 0, length: responseNSString.length)
            if let regex = config.regex, regex.rangeOfFirstMatch(in: response, range: wholeStringRange) != wholeStringRange {
                return .invalid(message: "Invalid Input", bundle: .module)
            }
            return .ok
        case .dateTime(let config):
            let cal = Calendar.current
            guard let response = responses[task.id].value.dateValue else {
                return .ok
            }
            switch config.style {
            case .timeOnly:
                let response = (response.hour ?? 0, response.minute ?? 0, response.second ?? 0)
                if let minValue = config.minValue.map({ ($0.hour ?? 0, $0.minute ?? 0, $0.second ?? 0) }), !(response >= minValue) {
                    let minValueDesc = cal
                        .date(
                            bySettingHour: minValue.0,
                            minute: minValue.1,
                            second: minValue.2,
                            of: .now
                        )?
                        .formatted(date: .omitted, time: .shortened)
                    return .invalid(
                        message: "Must be after \(minValueDesc ?? (config.minValue ?? .init()).description)", // will never be nil.
                        bundle: .module
                    )
                }
                if let maxValue = config.maxValue.map({ ($0.hour ?? 0, $0.minute ?? 0, $0.second ?? 0) }), !(response <= maxValue) {
                    let maxValueDesc = cal
                        .date(
                            bySettingHour: maxValue.0,
                            minute: maxValue.1,
                            second: maxValue.2,
                            of: .now
                        )?
                        .formatted(date: .omitted, time: .shortened)
                    return .invalid(
                        message: "Must be before \(maxValueDesc ?? (config.maxValue ?? .init()).description)", // will never be nil.
                        bundle: .module
                    )
                }
                return .ok
            case .dateOnly, .dateAndTime:
                guard let responseDate = cal.date(from: response) else {
                    // very likely unreachable
                    return .invalid(message: "Invalid Input", bundle: .module)
                }
                if let minDate = config.minValue.flatMap({ cal.date(from: $0) }), responseDate < minDate {
                    return .invalid(message: "Must be after \(minDate.formatted(.dateTime))", bundle: .module)
                }
                if let maxDate = config.maxValue.flatMap({ cal.date(from: $0) }), responseDate > maxDate {
                    return .invalid(message: "Must be before \(maxDate.formatted(.dateTime))", bundle: .module)
                }
                return .ok
            }
        case .numeric(let config):
            guard let response = responses[task.id].value.numberValue else {
                return .ok
            }
            if let minimum = config.minimum, response < minimum {
                return .invalid(message: "Must be at least \(minimum)", bundle: .module)
            }
            if let maximum = config.maximum, response > maximum {
                return .invalid(message: "Must be at most \(maximum)", bundle: .module)
            }
            if let maxDecimalPlaces = config.maxDecimalPlaces {
                let fmtNormal = response.formatted(.number)
                let fmtLimit = response.formatted(.number.precision(.fractionLength(Int(maxDecimalPlaces))))
                return fmtNormal == fmtLimit
                    ? .ok
                    : .invalid(message: "Limited to \(maxDecimalPlaces) decimal places", bundle: .module)
            }
            return .ok
        case .fileAttachment, .annotateImage:
            return .ok
        }
    }
}
