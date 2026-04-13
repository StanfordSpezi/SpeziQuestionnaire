//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable nesting

public import Foundation
private import SpeziFoundation
public import UniformTypeIdentifiers


extension Questionnaire.Task {
    /// Question Kind.
    ///
    /// Each ``Questionnaire/Task`` has a kind, which defines what the task does.
    ///
    /// ## Topics
    /// ### Instructional Tasks
    /// - ``instructional(_:)``
    ///
    /// ### Boolean Questions
    /// - ``boolean``
    ///
    /// ### Choice Questions
    /// - ``choice(_:)``
    /// - ``ChoiceConfig``
    ///
    /// ### Numeric Questions
    /// - ``numeric(_:)``
    /// - ``NumericTaskConfig``
    ///
    /// ### Free-Text Questions
    /// - ``freeText(_:)``
    /// - ``FreeTextConfig``
    ///
    /// ### Date/Time Questions
    /// - ``dateTime(_:)``
    /// - ``DateTimeConfig``
    ///
    /// ### File Questions
    /// - ``fileAttachment(_:)``
    /// - ``FileAttachmentConfig``
    ///
    /// ### Image Annotation Questions
    /// - ``annotateImage(_:)``
    /// - ``AnnotateImageConfig``
    ///
    /// ### Custom Questions
    /// - ``custom(_:config:)``
    public struct Kind: Hashable, Sendable {
        /// The task's internal variant.
        ///
        /// - Important: This type is part of the public API, but no guarantees are made as for its stability.
        /// Enum cases might be added or removed in any new release of the package.
        public enum Variant: Sendable {
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
            
            /// A custom question kind
            ///
            /// - parameter questionKind
            /// - parameter config
            ///
            /// - invariant: `type(of: config) == QuestionKind.Config.self`
            case custom(
                questionKind: any QuestionKindDefinition.Type,
                config: any QuestionKindConfig
            )
        }
        
        /// The task's internal variant.
        ///
        /// - Important: This property is part of the public API, but no guarantees are made as for its stability.
        public let variant: Variant
        
        package init(variant: Variant) {
            self.variant = variant
        }
    }
}


extension Questionnaire.Task.Kind {
    /// A task that collects a boolean Yes/No response from the user.
    public static var boolean: Self {
        .init(variant: .boolean)
    }
    
    /// A task that displays instructional text to the user.
    public static func instructional(_ text: String) -> Self {
        .init(variant: .instructional(text))
    }
    
    /// A task that asks the user to make a single or multiple choice selection, from a list of specified options.
    ///
    /// - parameter config: The definition of the choice the user is asked to make.
    public static func choice(_ config: ChoiceConfig) -> Self {
        .init(variant: .choice(config))
    }
    
    /// A task that collects a text response from the user.
    public static func freeText(_ config: FreeTextConfig) -> Self {
        .init(variant: .freeText(config))
    }
    
    /// A task that asks the user to select a date and/or time.
    public static func dateTime(_ config: DateTimeConfig) -> Self {
        .init(variant: .dateTime(config))
    }
    
    /// A task that asks the user for a number.
    public static func numeric(_ config: NumericTaskConfig) -> Self {
        .init(variant: .numeric(config))
    }
    
    /// A task that lets the user select photos and other files.
    public static func fileAttachment(_ config: FileAttachmentConfig) -> Self {
        .init(variant: .fileAttachment(config))
    }
    
    /// A custom question type, with an associated configuration.
    public static func custom<K: QuestionKindDefinition>(_ questionKind: K.Type, config: K.Config) -> Self {
        .init(variant: .custom(questionKind: questionKind, config: config))
    }
}


extension Questionnaire.Task.Kind {
    /// Checks whether the task kind matches the specified question kind definition.
    public func `is`<D: QuestionKindDefinition>(_ definition: D.Type) -> Bool {
        switch variant {
        case .custom(let questionKind, config: _):
            questionKind == definition
        case .instructional, .boolean, .choice, .freeText, .dateTime, .numeric, .fileAttachment:
            false
        }
    }
    
    /// Extracts the task kind's config, if it matches the specified type.
    public func config<D: QuestionKindDefinition>(for _: D.Type) -> D.Config? {
        config(as: D.Config.self)
    }
    
    /// Extracts the task kind's config, if it matches the specified type.
    public func config<C>(as _: C.Type) -> C? {
        switch variant {
        case .instructional(let config):
            config as? C
        case .boolean:
            nil
        case .choice(let config):
            config as? C
        case .freeText(let config):
            config as? C
        case .dateTime(let config):
            config as? C
        case .numeric(let config):
            config as? C
        case .fileAttachment(let config):
            config as? C
        case .custom(questionKind: _, config: let config):
            config as? C
        }
    }
}


extension Questionnaire.Task.Kind.Variant: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.instructional(lhs), .instructional(rhs)):
            lhs == rhs
        case (.boolean, .boolean):
            true
        case let (.choice(lhs), .choice(rhs)):
            lhs == rhs
        case let (.freeText(lhs), .freeText(rhs)):
            lhs == rhs
        case let (.dateTime(lhs), .dateTime(rhs)):
            lhs == rhs
        case let (.numeric(lhs), .numeric(rhs)):
            lhs == rhs
        case let (.fileAttachment(lhs), .fileAttachment(rhs)):
            lhs == rhs
        case let (.custom(lhsTy, lhsConfig), .custom(rhsTy, rhsConfig)):
            lhsTy == rhsTy && lhsConfig.isEqual(to: rhsConfig)
        default:
            false
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .instructional(let text):
            hasher.combine(0)
            hasher.combine(text)
        case .boolean:
            hasher.combine(1)
        case .choice(let config):
            hasher.combine(2)
            hasher.combine(config)
        case .freeText(let config):
            hasher.combine(3)
            hasher.combine(config)
        case .dateTime(let config):
            hasher.combine(4)
            hasher.combine(config)
        case .numeric(let config):
            hasher.combine(5)
            hasher.combine(config)
        case .fileAttachment(let config):
            hasher.combine(6)
            hasher.combine(config)
        case let .custom(type, config):
            hasher.combine(7)
            hasher.combine(ObjectIdentifier(type))
            config.hash(into: &hasher)
        }
    }
}


// MARK: Question Kind Configs

extension Questionnaire.Task.Kind {
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
        
        /// The options the user can select from.
        ///
        /// - Important: The options, as identified by their ``Option/id``s must be distinct.
        ///     If a `ChoiceConfig` contains multiple options with identical identifiers, the behaviour is undefined.
        public var options: [Option]
        /// Whether the user should be offered an "Other" option where they can enter arbitrary text.
        public var hasFreeTextOtherOption: Bool
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


extension Questionnaire.Task.Kind {
    /// The task's follow-up tasks.
    package var followUpTasks: [Questionnaire.Task] {
        switch variant {
        case .choice(let config):
            config.followUpTasks
        case .instructional, .boolean, .freeText, .dateTime, .numeric, .fileAttachment:
            []
        case .custom(_, let config):
            config.followUpTasks
        }
    }
}
