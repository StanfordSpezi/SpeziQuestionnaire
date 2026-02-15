//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


private import Algorithms
private import Foundation
public import ModelsR4
public import SpeziQuestionnaire
private import UniformTypeIdentifiers


// ???
//private typealias Section = SpeziQuestionnaire.Questionnaire.Section
//private typealias Task = SpeziQuestionnaire.Questionnaire.Task


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
    /// Creates a ``Questionnaire`` from a FHIR R4 `Questionnaire`.
    public init(_ other: ModelsR4.Questionnaire) throws {
        guard let id = other.url?.value?.url.absoluteString ?? other.id?.value?.string else {
            throw FHIRConversionError("Missing both 'url' and 'id' fields. At least one must be present.")
        }
        let metadata = Metadata(
            id: id,
            title: other.title?.value?.string ?? "",
            explainer: other.description_fhir?.value?.string ?? ""
        )
        self.init(
            metadata: metadata,
            sections: try other.toSections()
        )
    }
}





private struct ConversionContext {
    /// The FHIR questionnaire being converted
    let questionnaire: ModelsR4.Questionnaire
    /// The "is enabled" condition of the parent item.
    let parentItemCondition: SpeziQuestionnaire.Questionnaire.Condition
}


extension ModelsR4.Questionnaire {
    fileprivate func toSections() throws -> [SpeziQuestionnaire.Questionnaire.Section] {
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
                            group.item!.append(item)
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
                parentItemCondition: .none
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
            // TODO do we want to allow this? be a little more lenient here?
            throw FHIRConversionError("Empty top-level group!")
        }
        let groupCondition = try SpeziQuestionnaire.Questionnaire.Condition(self, using: context)
        let itemContext = ConversionContext(
            questionnaire: context.questionnaire,
            parentItemCondition: groupCondition
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
                parentItemCondition: context.parentItemCondition && groupCondition
            )
            return try nestedItems.flatMap { item in
                try item.toTasks(using: itemContext)
            }
        case .question:
            // is this what we'd need to parse/support for custom question kinds??
            fatalError() // TODO does this ever appear? how should we handle it?
        case .display, .boolean, .decimal, .integer, .date, .dateTime, .time, .string, .text, .url, .choice, .openChoice, .attachment, .reference, .quantity:
            let task = SpeziQuestionnaire.Questionnaire.Task(
                id: try self.getLinkId(),
                title: self.text?.value?.string ?? "",
                kind: try toTaskKind(using: context),
                isOptional: self.required?.value?.bool ?? true, // TODO do we want to default this to true or false?
                enabledCondition: try context.parentItemCondition && .init(self, using: context)
            )
            if itemType != .display, let nestedItems = item, !nestedItems.isEmpty {
                let itemContext = ConversionContext(
                    questionnaire: context.questionnaire,
                    parentItemCondition: context.parentItemCondition && task.enabledCondition
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
    
    
    fileprivate func toTaskKind(using context: ConversionContext) throws -> SpeziQuestionnaire.Questionnaire.Task.Kind {
        guard let itemType = type.value else {
            throw FHIRConversionError("QuestionnaireItem is missing 'type'")
        }
        switch itemType {
        case .group:
            throw FHIRConversionError("Attempted to request '\(SpeziQuestionnaire.Questionnaire.Task.Kind.self)' for questionnaire item of type '\(itemType)'")
        case .display:
            guard let text = text?.value?.string else {
                throw FHIRConversionError("QuestionnaireItem of type display is missing 'text'")
            }
            return .instructional(text)
        case .question:
            // is this what we'd need to parse/support for custom question kinds??
            fatalError() // TODO does this ever appear? how should we handle it?
        case .boolean:
            return .boolean
        case .decimal, .integer, .quantity:
            // TODO should we validate that, for integer questions, the min/max/step values are whole numbers?
            // (no, not the right place here)
            return .numeric(.init(
                inputMode: {
                    switch self.itemControl {
                    case "slider":
                        guard let sliderStepValue else {
                            return .numberPad(itemType == .integer ? .integer : .decimal)
                        }
                        return .slider(stepValue: sliderStepValue.doubleValue)
                    default:
                        return .numberPad(itemType == .integer ? .integer : .decimal)
                    }
                }(),
                minimum: minValue?.doubleValue,
                maximum: maxValue?.doubleValue,
                unit: unit ?? ""
            ))
        case .date, .time, .dateTime:
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
                minDate: minDateValue,
                maxDate: maxDateValue
            ))
        case .string, .text, .url:
            // TODO pass along the context here!!!
            return .freeText
        case .choice, .openChoice:
            var options: [SpeziQuestionnaire.Questionnaire.Task.SCMCOption] = []
            let valueSets = context.questionnaire.getContainedValueSets()
            
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
                
                guard let answerOptions = valueSet?.compose?.include.first?.concept else {
                    // TODO why the early return here?
//                    return choices
                    fatalError()
                }
                
                for option in answerOptions {
                    guard let display = option.display?.value?.string,
                          let code = option.code.value?.string,
                          let system = valueSet?.compose?.include.first?.system?.value?.url.absoluteString else {
                        fatalError() // TODO does this happen?
                        continue
                    }
                    options.append(.init(
                        id: "\(system):\(code)", // TODO is this correct?
                        title: display,
                        subtitle: "" // could supply this via an extension
                    ))
                }
            } else {
                // If the `QuestionnaireItem` has `answerOptions` defined instead, extract these options
                // and convert them to `ORKTextChoice`
                guard let answerOptions = answerOption else {
                    // TODO why the early return here?
                    //                    return choices
                                        fatalError()
                }
                
                for option in answerOptions {
                    guard case let .coding(coding) = option.value,
                          let display = coding.display?.value?.string,
                          let code = coding.code?.value?.string,
                          let system = coding.system?.value?.url.absoluteString else {
                        fatalError() // TODO does this happen?
                        continue
                    }
                    options.append(.init(
                        id: "\(system):\(code)", // TODO is this correct?
                        title: display,
                        subtitle: "" // could supply this via an extension
                    ))
                }
                
                if itemType == .openChoice {
                    // TODO
//                    throw FHIRConversionError("openChoice questions not yet supported")
//                    // If the `QuestionnaireItemType` is `open-choice`, allow user to enter in their own free-text answer.
//                    let otherChoiceText = NSLocalizedString("Other", comment: "")
//                    let otherChoice = ORKTextChoiceOther.choice(
//                        withText: otherChoiceText,
//                        detailText: nil,
//                        value: otherChoiceText as NSSecureCoding & NSCopying & NSObjectProtocol,
//                        exclusive: true,
//                        textViewPlaceholderText: ""
//                    )
//                    choices.append(otherChoice)
                }
            }
            
            
            return (repeats?.value?.bool ?? false) ? .multipleChoice(options: options) : .singleChoice(options: options)
        case .attachment:
            return .fileAttachment(.init(
                uti: { () -> UTType in
                    if let mimeType = self.extensions(for: "http://hl7.org/fhir/StructureDefinition/mimeType").first?.value?.stringValue {
                        UTType(mimeType: mimeType, conformingTo: .data) ?? .data
                    } else {
                        // accept anything if no mime type is specified
                        .data
                    }
                }(),
                maxSize: { () -> UInt64? in
                    if let value = self.extensions(for: "http://hl7.org/fhir/StructureDefinition/maxSize").first?.value?.intValue {
                        UInt64(exactly: value)
                    } else {
                        nil
                    }
                }()
            ))
        case .reference:
            throw FHIRConversionError("Unsupported question type '\(itemType)'")
        }
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
    
    var intValue: Int32? {
        switch self {
        case .integer(let value):
            value.value?.integer
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
    
    fileprivate init(_ enableWhen: ModelsR4.QuestionnaireItemEnableWhen, using context: ConversionContext) throws {
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
            let system = try unwrap(value.system?.value?.url).absoluteString
            let code = try unwrap(value.code?.value?.string)
            return .SCMCOption(id: "\(system):\(code)")
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
        case .quantity(let value):
            fatalError()
        case .reference(let value):
            throw FHIRConversionError("Unsupported comparison value '\(value)'")
        case .string(let value):
            return .string(try unwrap(value.value?.string))
        }
    }
}


extension Decimal {
    fileprivate var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}
