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
        var items: [QuestionnaireResponseItem] = []
        // TODO
//        for (taskId, optionIds) in other.selectedSCMCOptions.grouped(by: \.taskId).mapValues({ $0.map(\.optionId) }) {
//            guard let task = other.questionnaire.task(withId: taskId) else {
//                throw FHIRConversionError("Unable to find task '\(taskId)'")
//            }
//            let options: [SpeziQuestionnaire.Questionnaire.Task.Kind.ChoiceConfig.Option]
//            switch task.kind {
//            case .choice(let config):
//                options = config.options
//            default:
//                throw FHIRConversionError("Invalid Input")
//            }
//            items.append(.init(
//                answer: try optionIds.map { optionId -> QuestionnaireResponseItemAnswer in
//                    guard let option = options.first(where: { $0.id == optionId }) else {
//                        throw FHIRConversionError("Unable to find option")
//                    }
//                    if let idx = optionId.firstIndex(of: ":") {
//                        let system = String(optionId[..<idx])
//                        let code = String(optionId[idx...].dropFirst())
//                        return QuestionnaireResponseItemAnswer(
//                            value: .coding(Coding(
//                                code: code.asFHIRStringPrimitive(),
//                                display: option.title.asFHIRStringPrimitive(),
//                                system: system.asFHIRURIPrimitive()
//                            ))
//                        )
//                    } else {
//                        return QuestionnaireResponseItemAnswer(
//                            value: .coding(Coding(
//                                code: optionId.asFHIRStringPrimitive(),
//                                display: option.title.asFHIRStringPrimitive(),
//                                system: nil
//                            ))
//                        )
//                    }
//                },
////                definition: <#T##FHIRPrimitive<FHIRURI>?#>,
////                extension: <#T##[Extension]?#>,
////                id: <#T##FHIRPrimitive<FHIRString>?#>,
////                item: <#T##[QuestionnaireResponseItem]?#>,
//                linkId: taskId.asFHIRStringPrimitive(),
////                modifierExtension: <#T##[Extension]?#>,
////                text: <#T##FHIRPrimitive<FHIRString>?#>
//            ))
//        }
//        for (taskId, response) in other.freeTextResponses {
//            items.append(.init(
//                answer: [.init(value: .string(response.asFHIRStringPrimitive()))],
//                linkId: taskId.asFHIRStringPrimitive()
//            ))
//        }
//        for (taskId, response) in other.dateTimeResponses {
//            guard let task = other.questionnaire.task(withId: taskId) else {
//                throw FHIRConversionError("Unable to find task '\(taskId)'")
//            }
//            let value = try { () -> QuestionnaireResponseItemAnswer.ValueX in
//                guard case .dateTime(let config) = task.kind else {
//                    throw FHIRConversionError("Invalid Input")
//                }
//                switch config.style {
//                case .dateOnly:
//                    return .date(FHIRPrimitive(FHIRDate(
//                        year: response.year ?? 0, // should always be non-nil
//                        month: response.month.map(numericCast),
//                        day: response.day.map(numericCast)
//                    )))
//                case .timeOnly:
//                    return .time(FHIRPrimitive(FHIRTime(
//                        hour: response.hour.map(numericCast) ?? 0,
//                        minute: response.minute.map(numericCast) ?? 0,
//                        second: response.second.map { Decimal($0) } ?? 0
//                    )))
//                case .dateAndTime:
//                    return .dateTime(FHIRPrimitive(DateTime(
//                        date: FHIRDate(
//                            year: response.year ?? 0,
//                            month: response.month.map(numericCast),
//                            day: response.day.map(numericCast)
//                        ),
//                        time: FHIRTime(
//                            hour: response.hour.map(numericCast) ?? 0,
//                            minute: response.minute.map(numericCast) ?? 0,
//                            second: response.second.map { Decimal($0) } ?? 0
//                        )
//                    )))
//                }
//            }()
//            items.append(.init(
//                answer: [.init(value: value)],
//                linkId: taskId.asFHIRStringPrimitive()
//            ))
//        }
//        for (taskId, response) in other.numericResponses {
//            guard let task = other.questionnaire.task(withId: taskId) else {
//                throw FHIRConversionError("Unable to find task '\(taskId)'")
//            }
//            guard case .numeric(let config) = task.kind else {
//                throw FHIRConversionError("Invalid Input")
//            }
//            let value: QuestionnaireResponseItemAnswer.ValueX
//            if !config.unit.isEmpty {
//                value = .quantity(Quantity(
//                    unit: config.unit.asFHIRStringPrimitive(),
//                    value: response.asFHIRDecimalPrimitive()
//                ))
//            } else {
//                // this will lead to integer questions getting decimal responses, but prob not an issue for the time being
//                value = .decimal(response.asFHIRDecimalPrimitive())
//            }
//            items.append(.init(
//                answer: [.init(value: value)],
//                linkId: taskId.asFHIRStringPrimitive()
//            ))
//        }
//        for (taskId, response) in other.booleanResponses {
//            items.append(.init(
//                answer: [.init(value: .boolean(response.asPrimitive()))],
//                linkId: taskId.asFHIRStringPrimitive()
//            ))
//        }
//        for (taskId, attachments) in other.fileAttachmentResponses {
//            items.append(.init(
//                answer: try attachments.map { attachment in
//                    let data = try Data(contentsOf: attachment.url)
//                    let sha1 = Insecure.SHA1.hash(data: data)
//                    return .init(value: .attachment(.init(
//                        contentType: attachment.contentType?.identifier.asFHIRStringPrimitive(),
////                        creation: <#T##FHIRPrimitive<DateTime>?#>, // not easy bc eg an imported photo/file will likely not be brand new...
//                        data: FHIRPrimitive(Base64Binary(data.base64EncodedString())),
//                        hash: FHIRPrimitive(Base64Binary(Data(sha1).base64EncodedString())),
//                        id: attachment.id.uuidString.asFHIRStringPrimitive(),
//                        size: data.count.asFHIRUnsignedIntegerPrimitive(),
//                        title: attachment.filename.asFHIRStringPrimitive(),
//                    )))
//                },
//                linkId: taskId.asFHIRStringPrimitive()
//            ))
//        }
        // sort the items by task
        let tasksIdsByOverallPosition: [String: Int] = other.questionnaire.sections
            .flatMap(\.tasks)
            .enumerated()
            .reduce(into: [:]) { $0[$1.element.id] = $1.offset }
        try items.sort { lhs, rhs in
            let lhsLinkId = try lhs.getLinkId()
            let rhsLinkId = try rhs.getLinkId()
            return tasksIdsByOverallPosition[lhsLinkId]! < tasksIdsByOverallPosition[rhsLinkId]! // swiftlint:disable:this force_unwrapping
        }
        self.item = items
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
