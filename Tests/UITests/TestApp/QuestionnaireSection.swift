//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziQuestionnaire
import SwiftUI
import UniformTypeIdentifiers


struct QuestionnaireSection: View {
    @Environment(ExampleStandard.self) var standard
    
    @State private var showDetails = false
    @State private var displayQuestionnaire = false
    @State private var loadedQuestionnaire: Questionnaire?
    @State private var showFileImporter = false
    
    
    var body: some View {
        Section(header: Text("Surveys"), footer: Text("Pick a predefined questionnaire or import one from a file.")) {
            HStack {
                Label("Completed", systemImage: "checkmark.circle")
                Spacer()
                Text("\(standard.surveyResponseCount)")
                    .foregroundStyle(.secondary)
            }
            predefinedMenu
            Button("Load Questionnaire from File") { showFileImporter = true }
            if let loadedQuestionnaire = loadedQuestionnaire {
                VStack(alignment: .leading, spacing: 8) {
                    Text(loadedQuestionnaire.title?.value?.string ?? "Untitled Questionnaire")
                        .font(.headline)
                    if let url = loadedQuestionnaire.url?.value?.description {
                        Text(url)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                    .padding(.top, 4)
                Button { displayQuestionnaire = true } label: {
                    Label("Start Questionnaire", systemImage: "play.circle")
                }
                Button { showDetails = true } label: {
                    Label("Details", systemImage: "info.circle")
                }
            } else {
                ContentUnavailableView(
                    "No Questionnaire Selected",
                    systemImage: "list.bullet.rectangle",
                    description: Text("Pick a predefined questionnaire or import a JSON file to begin.")
                )
            }
        }
        .sheet(isPresented: $displayQuestionnaire) {
            if let loadedQuestionnaire {
                QuestionnaireView(
                    questionnaire: loadedQuestionnaire,
                    completionStepMessage: "Completed",
                    questionnaireResult: { result in
                        switch result {
                        case .completed:
                            standard.surveyResponseCount += 1
                        default:
                            break
                        }
                        displayQuestionnaire = false
                    }
                )
            }
        }
        .sheet(isPresented: $showDetails) {
            if let loadedQuestionnaire {
                NavigationStack {
                    QuestionnaireDetailView(questionnaire: loadedQuestionnaire)
                }
            }
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
                do {
                    let data = try Data(contentsOf: url)
                    if let fhirQuestionnaire = try? JSONDecoder().decode(Questionnaire.self, from: data) {
                        loadedQuestionnaire = fhirQuestionnaire
                    } else {
                        print("Failed to decode Questionnaire from selected file.")
                    }
                } catch {
                    print("Error reading file: \(error)")
                }
            case .failure(let error):
                print("File import failed: \(error)")
            }
        }
    }
    
    
    private var predefinedMenu: some View {
        Menu("Pick Predefined Questionnaire") {
            Section("Examples") {
                menuButton(title: "Skip Logic Example", questionnaire: .skipLogicExample)
                menuButton(title: "Multiple EnableWhen", questionnaire: .multipleEnableWhen)
                menuButton(title: "Text Validation Example", questionnaire: .textValidationExample)
                menuButton(title: "Contained ValueSet Example", questionnaire: .containedValueSetExample)
                menuButton(title: "Number Example", questionnaire: .numberExample)
                menuButton(title: "Date/Time Example", questionnaire: .dateTimeExample)
                menuButton(title: "Form Example", questionnaire: .formExample)
                menuButton(title: "Image Capture Example", questionnaire: .imageCaptureExample)
                menuButton(title: "Slider Example", questionnaire: .sliderExample)
            }
            Section("Research") {
                menuButton(title: "PHQ-9", questionnaire: .phq9)
                menuButton(title: "GAD-7", questionnaire: .gad7)
                menuButton(title: "IPSS", questionnaire: .ipss)
                menuButton(title: "GCS", questionnaire: .gcs)
            }
        }
    }
    
    private func menuButton(title: String, questionnaire: Questionnaire) -> some View {
        Button(title) {
            loadedQuestionnaire = questionnaire
        }
    }
}
