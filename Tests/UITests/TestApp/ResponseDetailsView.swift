//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import ModelsR4
import SwiftUI


struct ResponseDetailsView: View {
    let response: ModelsR4.QuestionnaireResponse
    
    var body: some View {
        Form {
            Section("Metadata") {
                LabeledContent("id", value: response.id?.value?.string ?? "n/a")
                LabeledContent("authored", value: (try? response.authored?.value?.asNSDate())?.formatted() ?? "n/a")
            }
            ForEach(response.item ?? [], id: \.self) { item in
                ResponseItemView(item: item)
            }
        }
    }
}


private struct ResponseItemView: View {
    let item: QuestionnaireResponseItem
    
    var body: some View {
        Section {
            LabeledContent("linkId", value: item.linkId.value?.string ?? "n/a")
            ForEach(item.answer ?? [], id: \.self) { answer in
                responseValueView(for: answer)
            }
            NavigationLink {
                Form {
                    ForEach(item.item ?? [], id: \.self) { item in
                        ResponseItemView(item: item)
                    }
                }
            } label: {
                LabeledContent("Nested Items", value: (item.item ?? []).count, format: .number)
            }
            .disabled((item.item ?? []).isEmpty)
        }
    }
    
    @ViewBuilder
    private func responseValueView(for answer: QuestionnaireResponseItemAnswer) -> some View {
        if let value = answer.value {
            NavigationLink {
                // ???
            } label: {
                LabeledContent("Answer (\(value.typeDesc))", value: value.valueDesc)
            }
            .disabled(true)
        } else {
            LabeledContent("Answer", value: "nil value")
        }
    }
}


extension QuestionnaireResponseItemAnswer.ValueX {
    fileprivate var typeDesc: String {
        switch self {
        case .attachment: "attachment"
        case .boolean: "boolean"
        case .coding: "coding"
        case .date: "date"
        case .dateTime: "dateTime"
        case .decimal: "decimal"
        case .integer: "integer"
        case .quantity: "quantity"
        case .reference: "reference"
        case .string: "string"
        case .time: "time"
        case .uri: "uri"
        }
    }
    
    fileprivate var valueDesc: String {
        switch self {
        case .attachment:
            return "attachment"
        case .boolean(let value):
            return value.value?.bool.description ?? "nil"
        case .coding(let coding):
            let system = coding.system?.value?.url.absoluteString ?? ""
            let code = coding.code?.value?.string ?? ""
            return "\(system)/\(code)"
        case .date(let date):
            return date.value?.description ?? "nil"
        case .dateTime(let dateTime):
            return dateTime.value?.description ?? "nil"
        case .decimal(let value):
            return value.value?.decimal.description ?? "nil"
        case .integer(let value):
            return value.value?.integer.description ?? "nil"
        case .quantity(let quantity):
            let value = quantity.value?.value?.decimal.description ?? "nil"
            let unit = quantity.unit?.value?.string ?? ""
            return "\(value) \(unit)"
        case .reference(let reference):
            return reference.reference?.value?.string ?? "nil"
        case .string(let value):
            return value.value?.string ?? "nil"
        case .time(let time):
            return time.value?.description ?? "nil"
        case .uri(let value):
            return value.value?.url.absoluteString ?? "nil"
        }
    }
}
