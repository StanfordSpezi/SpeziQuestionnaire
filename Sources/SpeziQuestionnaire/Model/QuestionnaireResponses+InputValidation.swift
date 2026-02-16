//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

private import Foundation


extension QuestionnaireResponses {
    public enum ResponseValidationResult: Sendable {
        /// The response provided for the task is ok.
        case ok
        /// The response provided for the task is invalid.
        case invalid(message: String) // TODO LocalizedStringResource!
    }
    
    public func validateResponse(for taskId: Questionnaire.Task.ID) -> ResponseValidationResult {
        guard let task = questionnaire.task(withId: taskId) else {
            // should never happen, at least for calls coming from the `QuestionnaireSheet`
            return .invalid(message: "Unknown Task")
        }
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
        case .singleChoice(let options), .multipleChoice(let options):
            // TODO when we support an `"other" with custom string entry" option, we'll need to validate that the string isn't empty.
            // not a problem for now
            return .ok
        case .freeText(let config):
            guard let response = self[freeTextResponseFor: taskId] else {
                return .ok
            }
            if let minLength = config.minLength, response.count < minLength {
                return .invalid(message: "Too short: must be at least \(minLength) character\(minLength == 1 ? "" : "s")")
            }
            if let maxLength = config.maxLength, response.count > maxLength {
                return .invalid(message: "Too long: can be at most \(maxLength) character\(maxLength == 1 ? "" : "s")")
            }
            let responseNSString = response as NSString
            let wholeStringRange = NSRange(location: 0, length: responseNSString.length)
            if let regex = config.regex, regex.rangeOfFirstMatch(in: response, range: wholeStringRange) != wholeStringRange {
                return .invalid(message: "Invalid Input")
            }
            return .ok
        case .dateTime(let config):
            guard let response = self[dateTimeResponseFor: taskId] else {
                return .ok
            }
            switch config.style {
            case .timeOnly, .dateOnly:
                guard let responseDate = Calendar.current.date(from: response) else {
                    fatalError("WTF")
                }
                fatalError("TODO")
            case .dateAndTime:
                guard let responseDate = Calendar.current.date(from: response) else {
                    fatalError("WTF")
                }
                if let minDate = config.minDate, responseDate < minDate {
                    return .invalid(message: "Must be after \(minDate.formatted(.dateTime))")
                }
                if let maxDate = config.maxDate, responseDate > maxDate {
                    return .invalid(message: "Must be before \(maxDate.formatted(.dateTime))")
                }
                return .ok
            }
        case .numeric(let config):
            guard let response = self[numericResponseFor: taskId] else {
                return .ok
            }
            if let minimum = config.minimum, response < minimum {
                return .invalid(message: "Must be at least \(minimum)")
            }
            if let maximum = config.maximum, response > maximum {
                return .invalid(message: "Must be at most \(maximum)")
            }
            if let maxDecimalPlaces = config.maxDecimalPlaces {
                let fmtNormal = response.formatted(.number)
                let fmtLimit = response.formatted(.number.precision(.fractionLength(Int(maxDecimalPlaces))))
                return fmtNormal == fmtLimit
                    ? .ok
                    : .invalid(message: "Limited to \(maxDecimalPlaces) decimal place\(maxDecimalPlaces == 1 ? "" : "s")")
            }
            return .ok
        case .fileAttachment:
            return .ok
        }
    }
}
