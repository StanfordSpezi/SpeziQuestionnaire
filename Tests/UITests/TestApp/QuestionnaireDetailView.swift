////
//// This source file is part of the Stanford Spezi open-source project
////
//// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
////
//// SPDX-License-Identifier: MIT
////
//
//import SpeziQuestionnaire
//import SwiftUI
//
//
//struct QuestionnaireDetailView: View {
//    let questionnaire: Questionnaire
//    @State private var rawJSON: String = ""
//    
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                metadata
//                Divider()
//                rawJSONSection
//            }
//            .padding()
//        }
//        .navigationTitle(questionnaire.metadata.title)
//        .task {
//            loadRawJSON()
//        }
//    }
//    
//    private var metadata: some View {
//        VStack(alignment: .leading, spacing: 8) {
////            if let url = questionnaire.url?.value?.description {
////                LabeledContent("URL", value: url)
////            }
//            LabeledContent("ID", value: questionnaire.metadata.id)
////            if let status = questionnaire.status.value?.rawValue {
////                LabeledContent("Status", value: status)
////            }
////            if let date = questionnaire.date?.value?.description {
////                LabeledContent("Date", value: date)
////            }
//        }
//    }
//    
//    private var rawJSONSection: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Label("Raw JSON", systemImage: "curlybraces")
//                .font(.headline)
//            if rawJSON.isEmpty {
//                ProgressView().padding(.top, 8)
//            } else {
//                Text(rawJSON)
//                    .font(.system(.caption, design: .monospaced))
//                    .textSelection(.enabled)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(8)
//                    .background(.thinMaterial)
//                    .clipShape(RoundedRectangle(cornerRadius: 8))
//            }
//        }
//    }
//    
//    
//    private func loadRawJSON() {
//        do {
//            let data = try JSONEncoder().encode(questionnaire)
//            if let jsonString = String(data: data, encoding: .utf8) {
//                rawJSON = jsonString
//            } else {
//                rawJSON = "<Unable to encode questionnaire as UTF-8>"
//            }
//        } catch {
//            rawJSON = "<Encoding error: \(error)>"
//        }
//    }
//}
//
//
////#Preview {
////    NavigationStack {
////        QuestionnaireDetailView(questionnaire: .gcs)
////    }
////}
