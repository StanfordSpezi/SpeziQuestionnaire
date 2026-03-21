//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

private import CryptoKit
private import Foundation
public import ModelsR4
private import PencilKit
public import SpeziQuestionnaire


private struct FHIRConversionError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
}


extension SpeziQuestionnaire.QuestionnaireResponses {
    public protocol CustomResponseValueProtocolWithFHIRSupport: CustomResponseValueProtocol { // swiftlint:disable:this type_name
        /// Generates a FHIR R4 [`QuestionnaireResponseItemAnswer`](https://build.fhir.org/questionnaireresponse-definitions.html#QuestionnaireResponse.item.answer) for this custom value.
        ///
        /// - throws: If the response was invalid, or there was some other error turning it into a `ModelsR4.QuestionnaireResponseItemAnswer`.
        /// - returns: An array of `ModelsR4.QuestionnaireResponseItemAnswer` objects, which will be inserted into the `ModelsR4.QuestionnaireResponse` to which this response belongs.
        ///     In most cases this array should contain only a single element, but if the custom resopnse represents multiple actual responses, it should contain one element per response.
        func toFHIR(
            for task: SpeziQuestionnaire.Questionnaire.Task
        ) throws -> [ModelsR4.QuestionnaireResponseItemAnswer]
    }
}


extension ModelsR4.QuestionnaireResponse {
    /// Creates a FHIR R4 `QuestionnaireResponse` from a Spezi `QuestionnaireResponses`.
    public convenience init(_ other: SpeziQuestionnaire.QuestionnaireResponses) throws {
        self.init(status: .init(.completed))
        self.id = other.id.uuidString.asFHIRStringPrimitive()
        self.identifier = Identifier(value: other.id.uuidString.asFHIRStringPrimitive())
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
    fileprivate struct FHIRConversionContext { // maybe also use this for the CustomResponseValue conversion?
        let task: SpeziQuestionnaire.Questionnaire.Task
    }
    
    fileprivate func toFHIR( // swiftlint:disable:this function_body_length cyclomatic_complexity
        using context: FHIRConversionContext
    ) throws -> QuestionnaireResponseItem? {
        // QUESTION do we need to place responses to tasks contained in a FHIR group in an empty QuestionnaireResponseItem?
        // (RKoF currently doesn't)
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
                return QuestionnaireResponseItemAnswer(value: .coding(option.toFHIRCoding()))
            }
            if let otherText = response.freeTextOtherResponse {
                // SAFETY: we just assigned a non-nil value above
                responseItem.answer!.append(.init(value: .string(otherText.asFHIRStringPrimitive()))) // swiftlint:disable:this force_unwrapping
            }
        case .attachments(let responses):
            responseItem.answer = try responses.map { attachment in
                try .init(attachment)
            }
        case .custom(let value):
            typealias CustomFHIRSupportingValue = any QuestionnaireResponses.CustomResponseValueProtocolWithFHIRSupport
            guard let value = value as? CustomFHIRSupportingValue else {
                throw FHIRConversionError(
                    """
                    Encountered custom response value of type '\(type(of: value))', which is missing FHIR support.
                    (Add FHIR support by conforming to '\(CustomFHIRSupportingValue.self)'.)
                    """
                )
            }
            responseItem.answer = try value.toFHIR(for: context.task)
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
                guard let answer = (responseItem.answer ?? []).first(where: { $0.value == .coding(option.toFHIRCoding()) }) else {
                    throw FHIRConversionError("Unable to find answer for choice option")
                }
                answer.item = try responses.toFHIR(using: .init(allTasks: task.kind.followUpTasks))
            }
        }
        return responseItem
    }
}


extension SpeziQuestionnaire.Questionnaire.Task.Kind.ChoiceConfig.Option {
    func toFHIRCoding() -> Coding {
        if let fhirCoding {
            Coding(
                code: fhirCoding.code.asFHIRStringPrimitive(),
                display: title.asFHIRStringPrimitive(),
                system: fhirCoding.system.asFHIRURIPrimitive()
            )
        } else {
            Coding(
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


extension QuestionnaireResponses.ImageAnnotation: SpeziQuestionnaire.QuestionnaireResponses.CustomResponseValueProtocolWithFHIRSupport {
    public func toFHIR(for task: SpeziQuestionnaire.Questionnaire.Task) throws -> [QuestionnaireResponseItemAnswer] {
        let baseImage: UIImage
        switch task.kind {
        case .annotateImage(let config):
            guard let image = config.inputImage.image() else {
                // Simply draw the annotation onto a clear backgrund in this case? (no.)
                throw FHIRConversionError("Unable to obtain baseImage")
            }
            baseImage = image
        default:
            throw FHIRConversionError("Invalid task kind")
        }
        guard let annotatedImage = self.draw(onto: baseImage) else {
            throw FHIRConversionError("Unable to draw annotated image")
        }
        let tmpUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, conformingTo: .png)
        guard let pngData = annotatedImage.pngData() else {
            throw FHIRConversionError("Unable to process annotated image")
        }
        try pngData.write(to: tmpUrl)
        defer {
            try? FileManager.default.removeItem(at: tmpUrl)
        }
        let attachment = try QuestionnaireResponses.CollectedAttachment(url: tmpUrl)
        return try [QuestionnaireResponseItemAnswer(attachment)]
    }
}


extension QuestionnaireResponseItemAnswer {
    convenience init(_ attachment: QuestionnaireResponses.CollectedAttachment) throws {
        let data = try Data(contentsOf: attachment.url)
        let sha1 = Insecure.SHA1.hash(data: data)
        self.init(value: .attachment(.init(
            contentType: attachment.contentType?.preferredMIMEType?.asFHIRStringPrimitive(),
//                        creation: <#T##FHIRPrimitive<DateTime>?#>, // not easy bc eg an imported photo/file will likely not be brand new...
            data: FHIRPrimitive(Base64Binary(data.base64EncodedString())),
            hash: FHIRPrimitive(Base64Binary(Data(sha1).base64EncodedString())),
            id: attachment.id.uuidString.asFHIRStringPrimitive(),
            size: data.count.asFHIRUnsignedIntegerPrimitive(),
            title: attachment.filename.asFHIRStringPrimitive(),
        )))
    }
}
