//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import Foundation
public import UniformTypeIdentifiers


extension Questionnaire {
    public struct Task: Hashable, Identifiable, Sendable { // Element? Item?
        public let id: String
        public let title: String
        public let subtitle: String
        public let footer: String
        public let kind: Kind
        public let isOptional: Bool
        public let enabledCondition: Condition
        
        public init(
            id: String,
            title: String,
            subtitle: String = "",
            footer: String = "",
            kind: Kind,
            isOptional: Bool = false,
            enabledCondition: Condition = .none
        ) {
            self.id = id
            self.title = title
            self.subtitle = subtitle
            self.footer = footer
            self.kind = kind
            self.isOptional = isOptional
            self.enabledCondition = enabledCondition
        }
    }
}


extension Questionnaire.Task {
    public enum Kind: Hashable, Sendable {
        case instructional(String)
        case boolean
        case singleChoice(options: [SCMCOption])
        case multipleChoice(options: [SCMCOption])
        case freeText
        case dateTime(DateTimeConfig)
        case numeric(NumericTaskConfig)
        case fileAttachment(FileAttachmentConfig)
        
        public struct DateTimeConfig: Hashable, Sendable {
            public enum Style: Hashable, Sendable {
                case dateOnly
                case timeOnly
                case dateAndTime
            }
            public let style: Style
            public let minDate: Date?
            public let maxDate: Date?
            
            public init(style: Style, minDate: Date?, maxDate: Date?) {
                self.style = style
                self.minDate = minDate
                self.maxDate = maxDate
            }
        }
        
        public struct NumericTaskConfig: Hashable, Sendable {
            public enum NumberKind: Hashable, Sendable {
                case integer, decimal
            }
            public enum InputMode: Hashable, Sendable {
                case numberPad(NumberKind)
                case slider(stepValue: Double)
            }
            public let inputMode: InputMode
            public let minimum: Double?
            public let maximum: Double?
            public let unit: String
            
            public init(inputMode: InputMode, minimum: Double?, maximum: Double?, unit: String) {
                self.inputMode = inputMode
                self.minimum = minimum
                self.maximum = maximum
                self.unit = unit
            }
        }
        
        public struct FileAttachmentConfig: Hashable, Sendable {
            /// The content types allowed for attachments.
            public let contentTypes: Set<UTType>
            public let maxSize: UInt64?
            public let allowsMultipleSelection: Bool
            
            public init(contentTypes: Set<UTType>, maxSize: UInt64?, allowsMultipleSelection: Bool) {
                self.contentTypes = contentTypes
                self.maxSize = maxSize
                self.allowsMultipleSelection = allowsMultipleSelection
            }
        }
    }
    
    public struct SCMCOption: Hashable, Identifiable, Sendable {
        public let id: String
        public let title: String
        public let subtitle: String
        
        public init(id: String, title: String, subtitle: String = "") {
            self.id = id
            self.title = title
            self.subtitle = subtitle
        }
    }
}





extension Questionnaire {
    /// TODO
    ///
    /// Conditions containing invalid ``ComponentPath``s always evaluate to `false`.
    public indirect enum Condition: Hashable, ExpressibleByNilLiteral, Sendable {
        /// A condition that always evaluates to `true`.
        case `true`
        /// A condition that always evaluates to `false`.
        case `false`
        /// A condition that is satisfied if `nested` is not satisfied.
        case not(_ nested: Condition)
        /// A condition that is satisfied if any of its contained conditions are satisfied..
        case any([Condition])
        /// A condition that is satisfied if all of its contained conditions are satisfied.
        case all([Condition])
        
        /// A condition that is satisfied if a response exists for the task at `taskPath`.
        ///
        /// This condition only checks whether a response exists; it does not take the task's optionality into account.
        /// (Use ``isMissingResponse(taskPath:)`` instead if you need that.)
        ///
        /// - parameter taskId: The id of a task within the questionnaire.
        case hasResponse(taskId: Task.ID)
        
        /// A condition that is satisfied if a response is currently missing for the  task at `taskPath`.
        ///
        /// - Note: This is not the opposite of ``hasResponse(taskPath:)``.
        ///     For an optional task that doesn't have a response, this would evaluate to `false` (because the task isn't required, the response isn't missing),
        ///     whereas ``hasResponse(taskPath:)`` would also evaluate to `false`, since it only checks for the existence of a response.
        case isMissingResponse(taskId: Task.ID)
        
//        /// - parameter optionPath: A ``ComponentPath`` pointing to the specific ``Questionnaire/Task/SCMCOption`` whose selection value this condition depends on.
//        case selectionValueEquals(_ optionPath: ComponentPath, _ value: Bool)
        
        case responseValueComparison(taskId: Task.ID, operator: ComparisonOperator, value: Value)
        
        
        /// Models https://hl7.org/fhir/valueset-questionnaire-enable-operator.html
        ///
        /// - Note: This enum intentionally does not implement the `exists` and `!=` operations.
        ///     Use ``Questionnaire/Condition/hasResponse(taskPath:)``, and ``Questionnaire/Condition/not(_:)`` in combination with ``equal`` instead.
        public enum ComparisonOperator: Hashable, Sendable {
            /// True if whether at least one answer has a value that is equal to the enableWhen answer
            case equal
            /// True if at least one answer has a value that is less than the enableWhen answer
            case lessThan
            /// True if at least one answer has a value that is greater than the enableWhen answer
            case greaterThan
            /// True if at least one answer has a value that is less or equal to the enableWhen answer
            case lessThanOrEqual
            /// True if at least one answer has a value that is greater or equal to the enableWhen answer
            case greaterThanOrEqual
        }
        
        public enum Value: Hashable, Sendable {
            case bool(Bool)
            case integer(Int)
            case decimal(Double)
            case string(String)
            case date(DateComponents)
            case SCMCOption(id: String)
        }
        
        /// The lack of a condition.
        ///
        /// Always evaluates to `true`.
        public static let none: Self = .true
        
        public init(nilLiteral: ()) {
            self = .none
        }
        
//        public static func selectionValueEquals
        
        public static func && (lhs: Self, rhs: Self) -> Self {
            .all([lhs, rhs])
        }
        public static func || (lhs: Self, rhs: Self) -> Self {
            .any([lhs, rhs])
        }
    }
}
