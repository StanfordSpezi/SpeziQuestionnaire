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
public import struct SwiftUI.Color
public import class UIKit.UIImage
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
        /// A task that asks the user to annotate an image
        case annotateImage(_ config: AnnotateImageConfig)
        
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
        
        public struct AnnotateImageConfig: Hashable, Sendable {
            public enum InputImage: Hashable, Sendable {
                case namedInMainBundle(filename: String)
                
                public func image() -> UIImage? {
                    switch self {
                    case .namedInMainBundle(let filename):
                        guard let url = Bundle.main.url(forResource: filename, withExtension: nil),
                              let data = try? Data(contentsOf: url) else {
                            return nil
                        }
                        return UIImage(data: data)
                    }
                }
            }
            
            public struct Region: Hashable, Identifiable, Sendable {
                public let name: String
                public let color: Color
                
                public var id: some Hashable {
                    name
                }
                
                public init(name: String, color: Color) {
                    self.name = name
                    self.color = color
                }
            }
            
            public let inputImage: InputImage
            public let regions: [Region]
            
            public init(inputImage: InputImage, regions: [Region]) {
                self.inputImage = inputImage
                self.regions = regions
            }
        }
    }
}


extension Questionnaire.Task.Kind {
    package var followUpTasks: [Questionnaire.Task] {
        switch self {
        case .choice(let config):
            config.followUpTasks
        case .instructional, .boolean, .freeText, .dateTime, .numeric, .fileAttachment, .annotateImage:
            []
        }
    }
    
    package var choiceOptions: [ChoiceConfig.Option] {
        switch self {
        case .choice(let config):
            config.options
        case .instructional, .boolean, .freeText, .dateTime, .numeric, .fileAttachment, .annotateImage:
            []
        }
    }
}
