//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order file_length

private import Algorithms
private import Foundation
public import ModelsR4
public import SpeziQuestionnaire
private import struct SwiftUI.Color
private import UniformTypeIdentifiers


private struct FHIRConversionError: LocalizedError {
    let message: String
    
    var errorDescription: String? {
        message
    }
    
    init(_ message: String) {
        self.message = message
    }
}


extension SpeziQuestionnaire.Questionnaire {
    /// Creates a Spezi `Questionnaire` from a FHIR R4 `Questionnaire`.
    ///
    /// - parameter other: A FHIR R4 Questionnaire
    /// - parameter additionalTaskDefinitions: Additional task definition types that should be taken into account when parsing nonstandard FHIR questions.
    public init(
        _ other: ModelsR4.Questionnaire,
        additionalTaskDefinitions: [any QuestionKindDefinition.Type] = []
    ) throws {
        guard let id = other.url?.value?.url.absoluteString ?? other.id?.value?.string else {
            throw FHIRConversionError("Missing both 'url' and 'id' fields. At least one must be present.")
        }
        let metadata = Metadata(
            id: id,
            url: other.url?.value?.url,
            title: other.title?.value?.string ?? "",
            explainer: other.description_fhir?.value?.string ?? ""
        )
        self.init(
            metadata: metadata,
            sections: try other.toSections(
                additionalTaskDefinitions: additionalTaskDefinitions + [AnnotateImageQuestionKind.self]
            )
        )
    }
}


private struct ConversionContext {
    /// The FHIR questionnaire being converted
    let questionnaire: ModelsR4.Questionnaire
    /// The "is enabled" condition of the parent item.
    let parentItemCondition: SpeziQuestionnaire.Questionnaire.Condition
    /// All task definition types that should be taken into account when parsing nonstandard FHIR questions.
    let additionalTaskDefinitions: [any QuestionKindDefinition.Type]
}


extension ModelsR4.Questionnaire {
    fileprivate func toSections(
        additionalTaskDefinitions: [any QuestionKindDefinition.Type]
    ) throws -> [SpeziQuestionnaire.Questionnaire.Section] {
        guard let items = item, !items.isEmpty else {
            throw FHIRConversionError("Input questionnaire is empty")
        }
        let topLevelItems = try { () throws -> [ModelsR4.QuestionnaireItem] in
            var topLevelItems: [ModelsR4.QuestionnaireItem] = []
            var itemsIterator = items.makeIterator()
            var nextGroupIdx = 0
            l1: while let item = itemsIterator.next() {
                guard let itemType = item.type.value else {
                    throw FHIRConversionError("QuestionnaireItem is missing 'type'")
                }
                if itemType == .group {
                    topLevelItems.append(item)
                } else {
                    let group = ModelsR4.QuestionnaireItem(
                        linkId: "___\(nextGroupIdx)".asFHIRStringPrimitive(),
                        type: .init(.group)
                    )
                    nextGroupIdx += 1
                    topLevelItems.append(group)
                    group.item = [item]
                    while let item = itemsIterator.next() {
                        // gobble up all following non-group items, until we reach the next group
                        guard let itemType = item.type.value else {
                            throw FHIRConversionError("QuestionnaireItem is missing 'type'")
                        }
                        if itemType == .group {
                            topLevelItems.append(item)
                            continue l1
                        } else {
                            // SAFETY: we just set this to a non-nil value a couple lines earlier
                            group.item!.append(item) // swiftlint:disable:this force_unwrapping
                        }
                    }
                }
            }
            return topLevelItems
        }()
        return try topLevelItems.map { item in
            guard let itemType = item.type.value else {
                throw FHIRConversionError("QuestionnaireItem is missing 'type'")
            }
            guard itemType == .group else {
                fatalError("Preprocessing failed")
            }
            let context = ConversionContext(
                questionnaire: self,
                parentItemCondition: .none,
                additionalTaskDefinitions: additionalTaskDefinitions
            )
            return try item.toSection(using: context)
        }
    }
}


extension ModelsR4.QuestionnaireItem {
    /// - invariant: the item must be a top-level `group` item.
    fileprivate func toSection(using context: ConversionContext) throws -> SpeziQuestionnaire.Questionnaire.Section {
        guard type.value == .group else {
            throw FHIRConversionError("Not a group item!")
        }
        let linkId = try getLinkId()
        guard let nestedItems = item, !nestedItems.isEmpty else {
            // do we want to allow this? be a little more lenient here?
            throw FHIRConversionError("Empty top-level group!")
        }
        let groupCondition = try SpeziQuestionnaire.Questionnaire.Condition(self, using: context)
        let itemContext = ConversionContext(
            questionnaire: context.questionnaire,
            parentItemCondition: groupCondition,
            additionalTaskDefinitions: context.additionalTaskDefinitions
        )
        return .init(
            id: linkId,
            tasks: try nestedItems.flatMap { item in
                try item.toTasks(using: itemContext)
            }
        )
    }
    
    /// Converts a FHIR QuestionnaireItem into a Task (within a Section) within a Spezi Questionnaire.
    ///
    /// - invariant: If this `QuestionnaireItem` is a `group`, is must not be a top-level item (in that case, ``toSection(using:)`` must be used instead).
    fileprivate func toTasks(using context: ConversionContext) throws -> [SpeziQuestionnaire.Questionnaire.Task] {
        guard let itemType = type.value else {
            throw FHIRConversionError("QuestionnaireItem is missing 'type'")
        }
        switch itemType {
        case .group:
            guard let nestedItems = self.item, !nestedItems.isEmpty else {
                return []
            }
            let groupCondition = try SpeziQuestionnaire.Questionnaire.Condition(self, using: context)
            // non-top-level groups are flattened into a series of tasks; the group's title is ignored but its condition is inherited by the tasks
            let itemContext = ConversionContext(
                questionnaire: context.questionnaire,
                parentItemCondition: context.parentItemCondition && groupCondition,
                additionalTaskDefinitions: context.additionalTaskDefinitions
            )
            return try nestedItems.flatMap { item in
                try item.toTasks(using: itemContext)
            }
        // swiftlint:disable:next line_length
        case .display, .boolean, .decimal, .integer, .date, .dateTime, .time, .string, .text, .url, .choice, .openChoice, .attachment, .reference, .quantity, .question:
            let task = SpeziQuestionnaire.Questionnaire.Task(
                id: try self.getLinkId(),
                title: self.text?.value?.string ?? "",
                kind: try toTaskKind(using: context),
                isOptional: !(self.required?.value?.bool ?? true), // if the `required` field is not set, we assume it to be true.
                enabledCondition: try context.parentItemCondition && .init(self, using: context)
            )
            if itemType != .display, let nestedItems = item, !nestedItems.isEmpty {
                let itemContext = ConversionContext(
                    questionnaire: context.questionnaire,
                    parentItemCondition: context.parentItemCondition && task.enabledCondition,
                    additionalTaskDefinitions: context.additionalTaskDefinitions
                )
                let nestedTasks = try nestedItems.flatMap { item in
                    try item.toTasks(using: itemContext)
                }
                return [task] + nestedTasks
            } else {
                return [task]
            }
        }
    }
    
    fileprivate func toTaskKind( // swiftlint:disable:this cyclomatic_complexity function_body_length
        using context: ConversionContext
    ) throws -> SpeziQuestionnaire.Questionnaire.Task.Kind {
        guard let itemType = type.value else {
            throw FHIRConversionError("QuestionnaireItem is missing 'type'")
        }
        guard itemControl != "http://spezi.stanford.edu/fhir/StructureDefinition/custom-task" else {
            return try toCustomTaskKind(using: context)
        }
        switch itemType {
        case .group:
            throw FHIRConversionError("Attempted to request '\(SpeziQuestionnaire.Questionnaire.Task.Kind.self)' for questionnaire item of type '\(itemType)'")
        case .display:
            guard let text = text?.value?.string else {
                throw FHIRConversionError("QuestionnaireItem of type display is missing 'text'")
            }
            switch itemControl {
            case .none:
                return .instructional(text)
            case .some:
                return try toCustomTaskKind(using: context)
            }
        case .question:
            // is this what we'd need to parse/support for custom question kinds??
            throw FHIRConversionError("Not-yet-supported question type 'question'")
        case .boolean:
            switch itemControl {
            case .none:
                return .boolean
            case .some:
                return try toCustomTaskKind(using: context)
            }
        case .decimal, .integer, .quantity:
            let inputMode: SpeziQuestionnaire.Questionnaire.Task.Kind.NumericTaskConfig.InputMode
            switch itemControl {
            case "slider":
                inputMode = if let sliderStepValue {
                    .slider(stepValue: sliderStepValue.doubleValue)
                } else {
                    .numberPad(itemType == .integer ? .integer : .decimal)
                }
            case .none:
                inputMode = .numberPad(itemType == .integer ? .integer : .decimal)
            case .some:
                return try toCustomTaskKind(using: context)
            }
            return .numeric(.init(
                inputMode: inputMode,
                minimum: minValue?.doubleValue,
                maximum: maxValue?.doubleValue,
                maxDecimalPlaces: self.maximumDecimalPlaces?.uintValue,
                unit: unit ?? ""
            ))
        case .date, .time, .dateTime:
            switch itemControl {
            case .some:
                return try toCustomTaskKind(using: context)
            case .none:
                break
            }
            return .dateTime(.init(
                style: {
                    switch itemType {
                    case .date:
                        return .dateOnly
                    case .time:
                        return .timeOnly
                    case .dateTime:
                        return .dateAndTime
                    default:
                        fatalError("unreachable")
                    }
                }(),
                minValue: minDateValue,
                maxValue: maxDateValue
            ))
        case .string, .text, .url:
            switch itemControl {
            case .some:
                return try toCustomTaskKind(using: context)
            case .none:
                break
            }
            return .freeText(.init(
                minLength: self.extensions(for: "http://hl7.org/fhir/StructureDefinition/minLength").first?.value?.intValue,
                maxLength: { () -> Int? in
                    if let value = self.maxLength?.value?.integer {
                        Int(value)
                    } else {
                        self.extensions(for: "http://hl7.org/fhir/StructureDefinition/maxLength").first?.value?.intValue
                    }
                }(),
                regex: self.validationRegularExpression,
                disableAutocorrection: itemType == .url
            ))
        case .choice, .openChoice:
            switch itemControl {
            case .some:
                return try toCustomTaskKind(using: context)
            case .none:
                break
            }
            let valueSets = context.questionnaire.getContainedValueSets()
            var options: [SpeziQuestionnaire.Questionnaire.Task.Kind.ChoiceConfig.Option] = []
            // If the `QuestionnaireItem` has an `answerValueSet` defined which is a reference to a contained `ValueSet`,
            // search the available `ValueSets`and, if a match is found, convert the options to `ORKTextChoice`
            if let answerValueSetURL = answerValueSet?.value?.url.absoluteString,
               answerValueSetURL.starts(with: "#") {
                let valueSet = valueSets.first { valueSet in
                    if let valueSetID = valueSet.id?.value?.string {
                        return "#\(valueSetID)" == answerValueSetURL
                    }
                    return false
                }
                // should we look at more than just the first here?
                guard let answerOptions = valueSet?.compose?.include.first?.concept else {
                    throw FHIRConversionError("Unable to find answer options")
                }
                
                for option in answerOptions {
                    guard let display = option.display?.value?.string,
                          let code = option.code.value?.string,
                          let system = valueSet?.compose?.include.first?.system?.value?.url else {
                        throw FHIRConversionError("Invalid Concept in answer option")
                    }
                    options.append(.init(
                        id: code,
                        title: display,
                        subtitle: "", // could supply this via an extension
                        fhirCoding: .init(system: system, code: code)
                    ))
                }
            } else {
                // If the `QuestionnaireItem` has `answerOptions` defined instead, extract these options
                // and convert them to `ORKTextChoice`
                guard let answerOptions = answerOption else {
                    throw FHIRConversionError("Missing answerOption")
                }
                for option in answerOptions {
                    switch option.value {
                    case .coding(let coding):
                        guard let display = coding.display?.value?.string,
                              let code = coding.code?.value?.string,
                              let system = coding.system?.value?.url else {
                            throw FHIRConversionError("Invalid coding value for answer option")
                        }
                        options.append(.init(
                            id: code,
                            title: display,
                            subtitle: "", // could supply this via an extension
                            fhirCoding: .init(system: system, code: code)
                        ))
                    case .date, .integer, .reference, .string, .time:
                        throw FHIRConversionError("Unsupported chocie option value: \(option.value). Currently, only coding values are supported.")
                    }
                }
            }
            return .choice(.init(
                options: options,
                hasFreeTextOtherOption: itemType == .openChoice,
                allowsMultipleSelection: repeats == true
            ))
        case .attachment:
            switch itemControl {
            case "annotate-image":
                let inputImageExts = self.extensions(for: "http://spezi.stanford.edu/fhir/StructureDefinition/custom-task/annotate-image/inputImage")
                guard let inputImageExt = inputImageExts.first, inputImageExts.count == 1 else {
                    throw FHIRConversionError("Must specify exactly one inputImage config")
                }
                let inputImage: AnnotateImageConfig.InputImage
                if let inputImageName = inputImageExt.value?.stringValue {
                    inputImage = .namedInMainBundle(filename: inputImageName)
                } else {
                    throw FHIRConversionError("Invalid inputImage config")
                }
                let regionExts = self.extensions(for: "http://spezi.stanford.edu/fhir/StructureDefinition/custom-task/annotate-image/region")
                return .annotateImage(.init(
                    inputImage: inputImage,
                    regions: try regionExts.map { ext in
                        guard let stringValue = ext.value?.stringValue else {
                            throw FHIRConversionError("Invalid region value")
                        }
                        guard let idx = stringValue.lastIndex(of: ":") else {
                            throw FHIRConversionError("Invalid region value")
                        }
                        let colorMapping: [String: Color] = [
                            "red": .red,
                            "orange": .orange,
                            "yellow": .yellow,
                            "green": .green,
                            "mint": .mint,
                            "teal": .teal,
                            "cyan": .cyan,
                            "blue": .blue,
                            "indigo": .indigo,
                            "purple": .purple,
                            "pink": .pink,
                            "brown": .brown,
                            "white": .white,
                            "gray": .gray,
                            "black": .black,
                            "clear": .clear,
                            "primary": .primary,
                            "secondary": .secondary
                        ]
                        let colorName = String(stringValue[idx...].dropFirst())
                        guard let color = colorMapping[colorName] else {
                            throw FHIRConversionError("Invalid color '\(colorName)'")
                        }
                        return .init(name: String(stringValue[..<idx]), color: color)
                    }
                ))
            case .some:
                return try toCustomTaskKind(using: context)
            default:
                return .fileAttachment(.init(
                    contentTypes: self.extensions(for: "http://hl7.org/fhir/StructureDefinition/mimeType").compactMapIntoSet { ext in
                        ext.value?.stringValue.flatMap { UTType(mimeType: $0) }
                    },
                    maxSize: { () -> UInt64? in
                        if let value = self.extensions(for: "http://hl7.org/fhir/StructureDefinition/maxSize").first?.value?.intValue {
                            UInt64(exactly: value)
                        } else {
                            nil
                        }
                    }(),
                    // ISSUE this will likely lead to effectively all such questions NOT allowing multiple selection,
                    // since the `repeats` field is typically not used, and eg the phoenix builder only offers it when you know where to look...
                    allowsMultipleSelection: repeats == true
                ))
            }
        case .reference:
            throw FHIRConversionError("Unsupported question type '\(itemType)'")
        }
    }
    
    
    private func toCustomTaskKind(
        using context: ConversionContext
    ) throws -> SpeziQuestionnaire.Questionnaire.Task.Kind {
        // http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl
//        guard itemControl == "http://spezi.stanford.edu/fhir/StructureDefinition/custom-task" else {
//            throw FHIRConversionError("Invalid item-control for custom task kind")
//        }
        for definition in context.additionalTaskDefinitions {
            guard let definition = definition as? any QuestionKindDefinitionWithFHIRSupport.Type else {
                continue
            }
            if let config = try definition.parse(self) {
                return ._custom(questionKind: definition, config: config)
            }
        }
        throw FHIRConversionError(
            """
            Unable to parse questionnaire item for task '\(try self.getLinkId())'.
            No matching task definition.
            """
        )
    }
}


extension ModelsR4.Extension.ValueX {
    var stringValue: String? {
        switch self {
        case .string(let value):
            value.value?.string
        default:
            nil
        }
    }
    
    var intValue: Int? {
        switch self {
        case .integer(let value):
            (value.value?.integer).map { Int($0) }
        default:
            nil
        }
    }
}


extension ModelsR4.QuestionnaireItem {
    fileprivate func getLinkId() throws -> String {
        guard let linkId = self.linkId.value?.string else {
            throw FHIRConversionError("QuestionnaireItem is missing 'linkId'")
        }
        return linkId
    }
}


extension SpeziQuestionnaire.Questionnaire.Condition {
    fileprivate init(_ item: ModelsR4.QuestionnaireItem, using context: ConversionContext) throws {
        guard let enableWhen = item.enableWhen, !enableWhen.isEmpty else {
            self = .none
            return
        }
        let behaviour = item.enableBehavior?.value ?? .all
        let elements = try enableWhen.map { try Self($0, using: context) }
        switch behaviour {
        case .all:
            self = .all(elements)
        case .any:
            self = .any(elements)
        }
    }
    
    fileprivate init( // swiftlint:disable:this cyclomatic_complexity
        _ enableWhen: ModelsR4.QuestionnaireItemEnableWhen,
        using context: ConversionContext
    ) throws {
        guard let questionLinkId = enableWhen.question.value?.string else {
            throw FHIRConversionError("EnableWhen is missing question linkId")
        }
        guard let enableWhenOperator = enableWhen.operator.value else {
            throw FHIRConversionError("EnableWhen is missing operator")
        }
        switch enableWhenOperator {
        case .exists:
            switch enableWhen.answer {
            case .boolean(let value):
                guard let value = value.value?.bool else {
                    throw FHIRConversionError("EnableWhen is boolean value")
                }
                if value {
                    self = .hasResponse(taskId: questionLinkId)
                } else {
                    self = .not(.hasResponse(taskId: questionLinkId))
                }
            default:
                throw FHIRConversionError("EnableWhen with exists operation must have boolean value")
            }
        case .equal:
            self = .responseValueComparison(taskId: questionLinkId, operator: .equal, value: try enableWhen.answer.toConditionValue())
        case .notEqual:
            self = .not(.responseValueComparison(taskId: questionLinkId, operator: .equal, value: try enableWhen.answer.toConditionValue()))
        case .greaterThan:
            self = .responseValueComparison(taskId: questionLinkId, operator: .greaterThan, value: try enableWhen.answer.toConditionValue())
        case .lessThan:
            self = .responseValueComparison(taskId: questionLinkId, operator: .lessThan, value: try enableWhen.answer.toConditionValue())
        case .greaterThanOrEqual:
            self = .responseValueComparison(taskId: questionLinkId, operator: .greaterThanOrEqual, value: try enableWhen.answer.toConditionValue())
        case .lessThanOrEqual:
            self = .responseValueComparison(taskId: questionLinkId, operator: .lessThanOrEqual, value: try enableWhen.answer.toConditionValue())
        }
    }
}


extension ModelsR4.QuestionnaireItemEnableWhen.AnswerX {
    fileprivate func toConditionValue() throws -> SpeziQuestionnaire.Questionnaire.Condition.Value {
        func unwrap<T>(_ value: T?) throws -> T {
            if let value {
                return value
            } else {
                throw FHIRConversionError("\(Self.self) is missing value")
            }
        }
        switch self {
        case .boolean(let value):
            return .bool(try unwrap(value.value?.bool))
        case .coding(let value):
            let code = try unwrap(value.code?.value?.string)
            return .SCMCOption(id: code)
        case .date(let value):
            let date = try unwrap(value.value)
            return .date(DateComponents(
                year: date.year,
                month: date.month.map(numericCast),
                day: date.day.map(numericCast)
            ))
        case .time(let value):
            let time = try unwrap(value.value)
            return .date(DateComponents(
                hour: numericCast(time.hour),
                minute: numericCast(time.minute),
                second: Int(time.second.doubleValue)
            ))
        case .dateTime(let value):
            let value = try unwrap(value.value)
            return .date(DateComponents(
                year: value.date.year,
                month: value.date.month.map(numericCast),
                day: (value.date.day).map(numericCast),
                hour: (value.time?.hour).map(numericCast),
                minute: (value.time?.minute).map(numericCast),
                second: (value.time?.second.doubleValue).map(Int.init)
            ))
        case .decimal(let value):
            return .decimal(try unwrap(value.value?.decimal.doubleValue))
        case .integer(let value):
            return .integer(Int(try unwrap(value.value?.integer)))
        case .quantity:
            // ISSUE: we might need to convert units here? (if the condition uses a different unit than the question
            throw FHIRConversionError("Quantity values are not yet supported in comparisons")
        case .reference(let value):
            throw FHIRConversionError("Unsupported comparison value '\(value)'")
        case .string(let value):
            return .string(try unwrap(value.value?.string))
        }
    }
}
