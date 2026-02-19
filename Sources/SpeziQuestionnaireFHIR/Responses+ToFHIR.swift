//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// TODO do we need to place responses to tasks contained in a FHIR group in an empty QuestionnaireResponseItem? is it ok if we don't? how does RKoF currently handle this?

private import CryptoKit
private import Foundation
public import ModelsR4
public import SpeziQuestionnaire


private struct FHIRConversionError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
}


extension ModelsR4.QuestionnaireResponse {
    /// Creates a FHIR R4 `QuestionnaireResponse` from a ``QuestionnaireResponses``.
    public convenience init( // swiftlint:disable:this function_body_length cyclomatic_complexity
        _ other: SpeziQuestionnaire.QuestionnaireResponses
    ) throws {
        self.init(status: .init(.completed))
        let id = UUID().uuidString
        self.id = id.asFHIRStringPrimitive()
        self.identifier = Identifier(value: id.asFHIRStringPrimitive())
        self.authored = try FHIRPrimitive(DateTime(date: .now))
        if let url = other.questionnaire.metadata.url {
            self.questionnaire = FHIRPrimitive(Canonical(url))
        }
        self.item = try other.responses.toFHIR(using: .init(
            allTasks: other.questionnaire.sections.flatMap(\.tasks)
        ))
    }
}


extension QuestionnaireResponses.Responses {
    fileprivate struct FHIRConversionContext {
        /// All tasks in the questionnaire, in the current context.
        ///
        /// For non-nested tasks, this simply contains all root-level tasks in the questionnaire.
        /// For nested tasks, this contains all nested tasks for the nested task's parent task.
        let allTasks: [SpeziQuestionnaire.Questionnaire.Task]
    }
    
    fileprivate func toFHIR(using context: FHIRConversionContext) throws -> [QuestionnaireResponseItem] {
        let items = try self.compactMap { taskId, response in
            guard let task = context.allTasks.first(where: { $0.id == taskId }) else {
                throw FHIRConversionError("Unable to find task '\(taskId)'")
            }
            return try response.toFHIR(using: .init(task: task))
        }
        // sort the items by task
        let tasksIdsByOverallPosition: [String: Int] = context.allTasks
            .enumerated()
            .reduce(into: [:]) { $0[$1.element.id] = $1.offset }
        return try items.sorted { lhs, rhs in
            let lhsLinkId = try lhs.getLinkId()
            let rhsLinkId = try rhs.getLinkId()
            return tasksIdsByOverallPosition[lhsLinkId]! < tasksIdsByOverallPosition[rhsLinkId]! // swiftlint:disable:this force_unwrapping
        }
    }
}


extension QuestionnaireResponses.Response {
    fileprivate struct FHIRConversionContext {
        let task: SpeziQuestionnaire.Questionnaire.Task
    }
    
    fileprivate func toFHIR(using context: FHIRConversionContext) throws -> QuestionnaireResponseItem? {
        let task = context.task
        if !nestedResponses.isEmpty, task.kind.followUpTasks.isEmpty {
            throw FHIRConversionError("Unexpectedly found nested responses in task without nested tasks")
        }
        let responseItem = QuestionnaireResponseItem(
            linkId: context.task.id.asFHIRStringPrimitive()
        )
        switch self.value {
        case .none:
            guard nestedResponses.isEmpty else {
                throw FHIRConversionError("Found empty response with nested responses")
            }
            return nil
        case .string(let response):
            responseItem.answer = [
                .init(value: .string(response.asFHIRStringPrimitive()))
            ]
        case .bool(let response):
            responseItem.answer = [
                .init(value: .boolean(response.asPrimitive()))
            ]
        case .date(let response):
            let value = try { () -> QuestionnaireResponseItemAnswer.ValueX in
                guard case .dateTime(let config) = task.kind else {
                    throw FHIRConversionError("Invalid Input")
                }
                switch config.style {
                case .dateOnly:
                    return .date(FHIRPrimitive(FHIRDate(
                        year: response.year ?? 0, // should always be non-nil
                        month: response.month.map(numericCast),
                        day: response.day.map(numericCast)
                    )))
                case .timeOnly:
                    return .time(FHIRPrimitive(FHIRTime(
                        hour: response.hour.map(numericCast) ?? 0,
                        minute: response.minute.map(numericCast) ?? 0,
                        second: response.second.map { Decimal($0) } ?? 0
                    )))
                case .dateAndTime:
                    return .dateTime(FHIRPrimitive(DateTime(
                        date: FHIRDate(
                            year: response.year ?? 0,
                            month: response.month.map(numericCast),
                            day: response.day.map(numericCast)
                        ),
                        time: FHIRTime(
                            hour: response.hour.map(numericCast) ?? 0,
                            minute: response.minute.map(numericCast) ?? 0,
                            second: response.second.map { Decimal($0) } ?? 0
                        )
                    )))
                }
            }()
            responseItem.answer = [.init(value: value)]
        case .number(let response):
            guard case .numeric(let config) = task.kind else {
                throw FHIRConversionError("Invalid Input")
            }
            let value: QuestionnaireResponseItemAnswer.ValueX
            if !config.unit.isEmpty {
                value = .quantity(Quantity(
                    unit: config.unit.asFHIRStringPrimitive(),
                    value: response.asFHIRDecimalPrimitive()
                ))
            } else {
                // this will lead to integer questions getting decimal responses, but prob not an issue for the time being
                value = .decimal(response.asFHIRDecimalPrimitive())
            }
            responseItem.answer = [.init(value: value)]
        case .choice(let response):
            guard case .choice(let config) = task.kind else {
                throw FHIRConversionError("Invalid Input")
            }
            responseItem.answer = try response.selectedOptions.map { optionId in
                guard let option = config.options.first(where: { $0.id == optionId }) else {
                    throw FHIRConversionError("Unable to find option for '\(optionId)'")
                }
                return QuestionnaireResponseItemAnswer(value: .coding(option.fhirCoding))
            }
        case .attachments(let responses):
            responseItem.answer = try responses.map { attachment in
                let data = try Data(contentsOf: attachment.url)
                let sha1 = Insecure.SHA1.hash(data: data)
                return .init(value: .attachment(.init(
                    contentType: attachment.contentType?.identifier.asFHIRStringPrimitive(),
//                        creation: <#T##FHIRPrimitive<DateTime>?#>, // not easy bc eg an imported photo/file will likely not be brand new...
                    data: FHIRPrimitive(Base64Binary(data.base64EncodedString())),
                    hash: FHIRPrimitive(Base64Binary(Data(sha1).base64EncodedString())),
                    id: attachment.id.uuidString.asFHIRStringPrimitive(),
                    size: data.count.asFHIRUnsignedIntegerPrimitive(),
                    title: attachment.filename.asFHIRStringPrimitive(),
                )))
            }
        }
        for (nestingId, responses) in nestedResponses {
            switch nestingId {
            case .choiceOption(let optionId):
                guard let option = task.kind.choiceOptions.first(where: { $0.id == optionId }) else {
                    throw FHIRConversionError("Unable to find choice option '\(optionId)'")
                }
                guard self.value.choiceValue.selectedOptions.contains(option.id) else {
                    throw FHIRConversionError("Found a nested answer for a choice option that isn't selected ('\(option.id)')")
                }
                guard let answer = (responseItem.answer ?? []).first(where: { $0.value == .coding(option.fhirCoding) }) else {
                    throw FHIRConversionError("Unable to find answer for choice option")
                }
                answer.item = try responses.toFHIR(using: .init(allTasks: task.kind.followUpTasks))
            }
        }
        return responseItem
    }
}


extension SpeziQuestionnaire.Questionnaire.Task.Kind.ChoiceConfig.Option {
    var fhirCoding: Coding {
        if let idx = id.firstIndex(of: ":") {
            let system = String(id[..<idx])
            let code = String(id[idx...].dropFirst())
            return Coding(
                code: code.asFHIRStringPrimitive(),
                display: title.asFHIRStringPrimitive(),
                system: system.asFHIRURIPrimitive()
            )
        } else {
            return Coding(
                code: id.asFHIRStringPrimitive(),
                display: title.asFHIRStringPrimitive(),
                system: nil
            )
        }
    }
}


extension QuestionnaireResponseItem {
    fileprivate func getLinkId() throws -> String {
        if let linkId = linkId.value?.string {
            return linkId
        } else {
            throw FHIRConversionError("Unable to get linkId")
        }
    }
}
