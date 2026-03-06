//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable nesting function_default_parameter_at_end

public import Foundation
private import SpeziFoundation
public import UniformTypeIdentifiers


extension Questionnaire {
    /// A unit of work the participant is asked to perform as part of the questionnaire (typically a question being asked)
    public struct Task: Hashable, Identifiable, Sendable {
        /// The task's unique identifier.
        ///
        /// - Important: Task identifiers must be unique across all tasks in all sections of the questionnaire.
        public var id: String
        /// The task's user-displayed title.
        public var title: String
        /// The task's user-displayed subtitle.
        ///
        /// Set this property to an empty string in order to omit the subtitle.
        public var subtitle: String
        /// A footer text displayed below the task.
        public var footer: String
        /// The task's kind
        public var kind: Kind
        /// Whether the user is allowed to skip this task.
        public var isOptional: Bool
        /// Controls when the task is enabled.
        ///
        /// Use ``Questionnaire/Condition/none`` to specify that the task does not have a condition and should always be enabled.
        ///
        /// A task's `enabledCondition` can reference other tasks, provided they precede this one in the questionnaire.
        /// If this is a nested task, the condition is first evaluated in the current nesting scope (i.e., the preceding nested questions, and their responses);
        /// if it does not evaluate to `true` in this scope, it is evaluated again in the parent scope (where it can access the responses to all preceding tasks as well),
        /// and if necessary in that scope's parent scope, and so on.
        public var enabledCondition: Condition
        
        /// Creates a new task.
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
    /// A ``Questionnaire/Task``'s kind, i.e. the definition of what the task actually does.
    public enum Kind: Hashable, Sendable {
        /// A task that displays instructional text to the user.
        case instructional(String)
        /// A task that collects a boolean Yes/No response from the user.
        case boolean
        /// A task that asks the user to make a single or multiple choice selection, from a list of specified options.
        ///
        /// - parameter config: The definition of the choice the user is asked to make.
        case choice(_ config: ChoiceConfig)
        /// A task that collects a text response from the user.
        case freeText(_ config: FreeTextConfig)
        /// A task that asks the user to select a date and/or time.
        case dateTime(_ config: DateTimeConfig)
        /// A task that asks the user for a number.
        case numeric(_ config: NumericTaskConfig)
        /// A task that lets the user select photos and other files.
        case fileAttachment(_ config: FileAttachmentConfig)
        
        /// Configuration of a free-text question.
        public struct FreeTextConfig: Hashable, Sendable {
            /// The minimum allowed response length.
            public let minLength: Int?
            /// The maximum allowed response length.
            public let maxLength: Int?
            /// Response validation regular expression.
            public let regex: NSRegularExpression?
            /// Controls the response text field's autocorrection mode.
            public let disableAutocorrection: Bool
            
            public init(minLength: Int? = nil, maxLength: Int? = nil, regex: NSRegularExpression? = nil, disableAutocorrection: Bool = false) {
                self.minLength = minLength
                self.maxLength = maxLength
                self.regex = regex
                self.disableAutocorrection = disableAutocorrection
            }
        }
        
        /// Configuration of a date/time question.
        public struct DateTimeConfig: Hashable, Sendable {
            public enum Style: Hashable, Sendable {
                case dateOnly
                case timeOnly
                case dateAndTime
            }
            /// The date picker's style
            public let style: Style
            /// The minimum allowed response value.
            public let minValue: DateComponents?
            /// The maximum allowed response value.
            public let maxValue: DateComponents?
            
            public init(style: Style, minValue: DateComponents? = nil, maxValue: DateComponents? = nil) {
                self.style = style
                self.minValue = minValue
                self.maxValue = maxValue
            }
        }
        
        /// Configuration of a number input question.
        public struct NumericTaskConfig: Hashable, Sendable {
            public enum NumberKind: Hashable, Sendable {
                case integer, decimal
            }
            public enum InputMode: Hashable, Sendable {
                case numberPad(NumberKind)
                case slider(stepValue: Double)
            }
            /// The preferred input mode.
            public let inputMode: InputMode
            /// The minimum allowed response value.
            public let minimum: Double?
            /// The maximum allowed response value.
            public let maximum: Double?
            /// The maximum allowed number of decimal places.
            public let maxDecimalPlaces: UInt?
            /// The unit of the quantity being asked for.
            public let unit: String
            
            public init(inputMode: InputMode, minimum: Double? = nil, maximum: Double? = nil, maxDecimalPlaces: UInt? = nil, unit: String = "") {
                self.inputMode = inputMode
                self.minimum = minimum
                self.maximum = maximum
                self.maxDecimalPlaces = maxDecimalPlaces
                self.unit = unit
            }
        }
        
        /// Configuration of a file selection question.
        public struct FileAttachmentConfig: Hashable, Sendable {
            /// The content types allowed for attachments.
            public let contentTypes: Set<UTType>
            /// The maximum file size allowed per attachment.
            public let maxSize: UInt64?
            /// Whether the user may select multiple attachments.
            public let allowsMultipleSelection: Bool
            
            public init(contentTypes: Set<UTType>, maxSize: UInt64? = nil, allowsMultipleSelection: Bool) {
                self.contentTypes = contentTypes
                self.maxSize = maxSize
                self.allowsMultipleSelection = allowsMultipleSelection
            }
        }
        
        /// Configuration of a single/multiple choice question.
        public struct ChoiceConfig: Hashable, Sendable {
            public struct Option: Hashable, Identifiable, Sendable {
                public struct FHIRCoding: Hashable, Sendable {
                    public let system: URL
                    public let code: String
                    
                    public init(system: URL, code: String) {
                        self.system = system
                        self.code = code
                    }
                }
                
                /// The option's identifier.
                ///
                /// Option identifiers must be unique within a single task.
                public let id: String
                public let title: String
                public let subtitle: String
                /// The option's FHIR coding, if it was created from one.
                public let fhirCoding: FHIRCoding?
                
                public init(id: String, title: String, subtitle: String = "", fhirCoding: FHIRCoding? = nil) {
                    self.id = id
                    self.title = title
                    self.subtitle = subtitle
                    self.fhirCoding = fhirCoding
                }
            }
            
            /// The options the user can select from
            public var options: [Option]
            /// Whether the user should be offered an "Other" option where they can enter arbitrary text.
            public var hasFreeTextOtherOption: Bool
//            /// The maximum number of items that may be selected.
//            ///
//            /// Set this value to `1` to enable single-selection; set it to `nil` to enable unlimited multiple selection.
//            public let selectionLimit: Int?
            /// Whether the user is allowed to make multiple choices.
            public var allowsMultipleSelection: Bool
            /// A list of follow-up tasks.
            ///
            /// For every selected option in the choice question, the user will be asked to respond to all of the question's follow-up tasks.
            /// If the user deselects an option, its associated follow-up task responses will be discarded.
            public var followUpTasks: [Questionnaire.Task]
            
            public init(
                options: [Option],
                hasFreeTextOtherOption: Bool = false,
                allowsMultipleSelection: Bool,
                followUpTasks: [Questionnaire.Task] = []
            ) {
                self.options = options
                self.hasFreeTextOtherOption = hasFreeTextOtherOption
                self.allowsMultipleSelection = allowsMultipleSelection
                self.followUpTasks = followUpTasks
            }
        }
    }
}


extension Questionnaire.Task.Kind {
    package var followUpTasks: [Questionnaire.Task] {
        switch self {
        case .choice(let config):
            config.followUpTasks
        case .instructional, .boolean, .freeText, .dateTime, .numeric, .fileAttachment:
            []
        }
    }
    
    package var choiceOptions: [ChoiceConfig.Option] {
        switch self {
        case .choice(let config):
            config.options
        case .instructional, .boolean, .freeText, .dateTime, .numeric, .fileAttachment:
            []
        }
    }
}


extension Questionnaire {
    /// Controls when a task should be enabled.
    ///
    /// Conditions allow establishing dependencies between ``Task``s within a ``Questionnaire``,
    /// and can be used to conditionally ask additional questions, based on e.g. a user's response to some previous task.
    ///
    /// A condition belonging to a task may only reference other tasks that precede that task within the questionnaire.
    /// If a condition references a task that appears after the task to which it belongs, it always evaluates to `false`.
    ///
    /// Conditions referencing invalid ``Task``s always evaluate to `false`.
    ///
    /// Conditions are evaluated
    ///
    /// ## Topics
    ///
    /// ### Conditions
    /// - ``not(_:)``
    /// - ``any(_:)``
    /// - ``all(_:)``
    /// - ``true``
    /// - ``false``
    /// - ``hasResponse(taskId:)``
    /// - ``isMissingResponse(taskId:)``
    /// - ``responseValueComparison(taskId:operator:value:)``
    ///
    /// ### Supporting Types
    /// - ``ComparisonOperator``
    /// - ``Value``
    public indirect enum Condition: Hashable, ExpressibleByBooleanLiteral, Sendable {
        /// A condition that is satisfied if `nested` is not satisfied.
        case not(_ nested: Condition)
        
        /// A condition that is satisfied if any of its contained conditions are satisfied..
        ///
        /// If there are no nested conditions, `any` evaluates to `false`.
        case any([Condition])
        
        /// A condition that is satisfied if all of its contained conditions are satisfied.
        ///
        /// If there are no nested conditions, `all` evaluates to `true`.
        case all([Condition])
        
        /// A condition that is satisfied if a response exists for the task at `taskPath`.
        ///
        /// This condition only checks whether a response exists; it does not take the task's optionality into account.
        /// (Use ``isMissingResponse(taskId:)`` instead if you need that.)
        ///
        /// - parameter taskId: The id of a task within the questionnaire.
        case hasResponse(taskId: Task.ID)
        
        /// A condition that is satisfied if a response is currently missing for the  task at `taskPath`.
        ///
        /// - Note: This is not the opposite of ``hasResponse(taskId:)``.
        ///     For an optional task that doesn't have a response, this would evaluate to `false` (because the task isn't required, the response isn't missing),
        ///     whereas ``hasResponse(taskId:)`` would also evaluate to `false`, since it only checks for the existence of a response.
        case isMissingResponse(taskId: Task.ID)
        
        /// A condition that compares a task's response to some value.
        ///
        /// - Note: Not all comparisons make sense for all question types.
        ///     If a response is compared against a value of a different type, or if the operator isn't applicable for the type, the condition evaluates to `false`.
        ///
        /// - parameter taskId: The id of the task whose response should be inspected.
        /// - parameter operator: The comparison operation
        /// - parameter value: The value against which the task's response should be compared
        case responseValueComparison(taskId: Task.ID, operator: ComparisonOperator, value: Value)
        
        
        /// Models https://hl7.org/fhir/valueset-questionnaire-enable-operator.html
        ///
        /// - Note: This enum intentionally does not implement the `exists` and `!=` operations.
        ///     Use ``Questionnaire/Condition/hasResponse(taskId:)``, and ``Questionnaire/Condition/not(_:)`` in combination with ``equal`` instead.
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
        
        /// Value used in comparison conditions.
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
        public static var none: Self {
            true
        }
        
        /// Creates a ``Condition`` that always evaluates to the specified boolean value.
        public init(booleanLiteral value: Bool) {
            self = value ? .all([]) : .any([])
        }
        
        /// Constructs a condition that is true iff two other conditions are true.
        public static func && (lhs: Self, rhs: Self) -> Self {
            .all([lhs, rhs])
        }
        
        /// Constructs a condition that is true iff either of other conditions is true.
        public static func || (lhs: Self, rhs: Self) -> Self {
            .any([lhs, rhs])
        }
        
        /// Negates a condition
        public static prefix func ! (rhs: Self) -> Self {
            .not(rhs)
        }
    }
}


extension Questionnaire.Condition {
    mutating func simplify() {
        self = self.simplified()
    }
    
    func simplified() -> Self {
        switch self {
        case .not(let inner):
            switch inner.simplified() {
            case .not(let inner):
                return inner
            case true:
                return false
            case false:
                return true
            case let inner:
                return .not(inner)
            }
        case .any(let inner):
            let inner = inner.mapIntoSet { $0.simplified() }
            if inner.isEmpty {
                return false
            } else if inner.contains(true) {
                return true
            } else {
                return .any(Array(inner))
            }
        case .all(let inner):
            let inner = inner.mapIntoSet { $0.simplified() }
            if inner.isEmpty {
                return true
            } else if inner.contains(false) {
                return false
            } else if inner == [true] {
                return true
            } else {
                return .all(Array(inner))
            }
        case .hasResponse, .isMissingResponse, .responseValueComparison:
            return self
        }
    }
}
