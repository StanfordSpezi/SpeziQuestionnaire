//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import class ModelsR4.Questionnaire
import SpeziQuestionnaire
import SpeziQuestionnaireFHIR
import FHIRQuestionnaires
import SpeziViews
import SwiftUI
import UniformTypeIdentifiers


struct ContentView: View {
    @Environment(ExampleStandard.self) var standard
    
    @State private var showDetails = false
    @State private var loadedQuestionnaire: SpeziQuestionnaire.Questionnaire?
    @State private var activeQuestionnaire: SpeziQuestionnaire.Questionnaire?
    @State private var showFileImporter = false
    @State private var viewState: ViewState = .idle
    
    
    var body: some View {
        Form {
            Section {
                sectionContent
            } header: {
                Text("Surveys")
            } footer: {
                Text("Pick a predefined questionnaire or import one from a file.")
            }
            .viewStateAlert(state: $viewState)
        }
        .navigationTitle("Spezi Questionnaire")
        .sheet(item: $activeQuestionnaire) { questionnaire in
            QuestionnaireSheet(questionnaire) { result in
                switch result {
                case .success:
                    standard.surveyResponseCount += 1
                default:
                    break
                }
                activeQuestionnaire = nil
            }
        }
        .onAppear {
            for r4Questionnaire in ModelsR4.Questionnaire.exampleQuestionnaires + ModelsR4.Questionnaire.researchQuestionnaires {
                do {
                    _ = try SpeziQuestionnaire.Questionnaire(r4Questionnaire)
                } catch {
                    fatalError("Error in \(r4Questionnaire.title?.value?.string ?? ""): \(error)")
                }
            }
        }
//        .sheet(isPresented: $showDetails) {
//            if let loadedQuestionnaire {
//                NavigationStack {
//                    QuestionnaireDetailView(questionnaire: loadedQuestionnaire)
//                }
//            }
//        }
    }
    
    
    @ViewBuilder private var sectionContent: some View {
        HStack {
            Label("Completed", systemImage: "checkmark.circle")
            Spacer()
                Text("\(standard.surveyResponseCount)")
                    .foregroundStyle(.secondary)
        }
        predefinedMenu
        fileImporterButton
        if let loadedQuestionnaire = loadedQuestionnaire {
            VStack(alignment: .leading, spacing: 8) {
                Text(loadedQuestionnaire.metadata.title)
                    .font(.headline)
//                    if let url = loadedQuestionnaire.url?.value?.description {
//                        Text(url)
//                            .font(.footnote)
//                            .foregroundStyle(.secondary)
//                    }
            }
                .padding(.top, 4)
            Button {
                activeQuestionnaire = loadedQuestionnaire
            } label: {
                Label("Start Questionnaire", systemImage: "play.circle")
            }
            Button {
                showDetails = true
            } label: {
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
    
    private var predefinedMenu: some View {
        Menu("Pick Predefined Questionnaire") {
            Section {
                menuButton(title: "Question Kinds Showcase", questionnaire: .testQuestionnaire)
            }
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
                menuButton(title: "PHQ-9 (Native)", questionnaire: SpeziQuestionnaire.Questionnaire.phq9)
                menuButton(title: "PHQ-9 (FHIR)", questionnaire: ModelsR4.Questionnaire.phq9)
                menuButton(title: "GAD-7 (Native)", questionnaire: SpeziQuestionnaire.Questionnaire.gad7)
                menuButton(title: "GAD-7 (FHIR)", questionnaire: ModelsR4.Questionnaire.gad7)
                menuButton(title: "IPSS", questionnaire: .ipss)
                menuButton(title: "GCS", questionnaire: .gcs)
            }
        }
    }
    
    private var fileImporterButton: some View {
        Button("Load Questionnaire from File") {
            showFileImporter = true
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.json]) { result in
            do {
                viewState = .processing
                switch result {
                case .success(let url):
                    loadedQuestionnaire = try importQuestionnaire(from: url)
                case .failure(let error):
                    throw error
                }
                viewState = .idle
            } catch {
                viewState = .error(AnyLocalizedError(error: error))
            }
        }
    }
    
    private func menuButton(title: String, questionnaire: SpeziQuestionnaire.Questionnaire) -> some View {
        Button(title) {
            loadedQuestionnaire = questionnaire
        }
    }
    
    private func menuButton(title: String, questionnaire: ModelsR4.Questionnaire) -> some View {
        AsyncButton(title, state: $viewState) {
            loadedQuestionnaire = try SpeziQuestionnaire.Questionnaire(questionnaire)
        }
    }
    
    
    private func importQuestionnaire(from url: URL) throws -> SpeziQuestionnaire.Questionnaire {
        let data = try Data(contentsOf: url)
        let fhirQuestionnaire = try JSONDecoder().decode(ModelsR4.Questionnaire.self, from: data)
        return try SpeziQuestionnaire.Questionnaire(fhirQuestionnaire)
    }
}


extension SpeziQuestionnaire.Questionnaire {
    static let testQuestionnaire = Self(
        metadata: .init(
            id: "edu.stanford.SpeziQuestionnaire.test",
            title: "Test Questionnaire",
            explainer: "This is the test questionnaire, whose purpose is testing the questionnaire infrastructure."
        ),
        sections: [
            .init(id: "sec1", tasks: [
                .init(
                    id: "1",
                    title: "Instructions",
                    kind: .instructional("These are **markdown-based** instructions")
                ),
                .init(
                    id: "2",
                    title: "Single-Choice Question",
                    subtitle: "What's your favourite ice cream flavour?",
                    kind: .singleChoice(options: [
                        .init(id: "0", title: "Strawberry"),
                        .init(id: "1", title: "Mango"),
                        .init(id: "2", title: "Chocolate")
                    ])
                ),
                .init(
                    id: "3",
                    title: "Multiple-Choice Question",
                    subtitle: "Which of the books have you read already?",
                    kind: .multipleChoice(options: [
                        .init(id: "0", title: "AGOT"),
                        .init(id: "1", title: "ACOK"),
                        .init(id: "2", title: "ASOS"),
                        .init(id: "3", title: "AFFC"),
                        .init(id: "4", title: "ADWD")
                    ])
                ),
                .init(
                    id: "4",
                    title: "Free-Text Entry",
                    subtitle: "Tell us a little about yourself",
                    kind: .freeText
                ),
                .init(
                    id: "5",
                    title: "Date Entry",
                    kind: .dateTime(.init(style: .dateOnly, minDate: nil, maxDate: nil))
                ),
                .init(
                    id: "6",
                    title: "Time Entry",
                    kind: .dateTime(.init(style: .timeOnly, minDate: nil, maxDate: nil))
                ),
                .init(
                    id: "7",
                    title: "Date&Time Entry",
                    kind: .dateTime(.init(style: .dateAndTime, minDate: nil, maxDate: nil))
                ),
                .init(
                    id: "8",
                    title: "Numeric (Slider)",
                    kind: .numeric(.init(
                        inputMode: .slider(stepValue: 0.25),
                        minimum: -5,
                        maximum: 12,
                        unit: ""
                    ))
                ),
                .init(
                    id: "9",
                    title: "Numeric (TextField Decimal)",
                    kind: .numeric(.init(
                        inputMode: .numberPad(.decimal),
                        minimum: -5,
                        maximum: 12,
                        unit: ""
                    ))
                ),
                .init(
                    id: "10",
                    title: "Numeric (TextField Integer)",
                    kind: .numeric(.init(
                        inputMode: .numberPad(.integer),
                        minimum: -5,
                        maximum: 12,
                        unit: ""
                    ))
                ),
                .init(
                    id: "11",
                    title: "Numeric (Unit Entry)",
                    kind: .numeric(.init(
                        inputMode: .numberPad(.integer),
                        minimum: -5,
                        maximum: 12,
                        unit: "m/s^2"
                    ))
                )
            ])
        ]
    )
}
