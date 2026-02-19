//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import FHIRQuestionnaires
import class ModelsR4.Questionnaire
import class ModelsR4.QuestionnaireResponse
import SpeziQuestionnaire
import SpeziQuestionnaireFHIR
import SpeziViews
import SwiftUI
import UniformTypeIdentifiers


struct ContentView: View {
    struct WrappedQuestionnaire: Hashable, Identifiable {
        let r4: ModelsR4.Questionnaire? // swiftlint:disable:this identifier_name
        let spezi: SpeziQuestionnaire.Questionnaire
        
        var id: some Hashable {
            spezi.id
        }
        
        init(r4 questionnaire: ModelsR4.Questionnaire) throws {
            self.r4 = questionnaire
            self.spezi = try .init(questionnaire)
        }
        
        init(spezi questionnaire: SpeziQuestionnaire.Questionnaire) {
            self.r4 = nil
            self.spezi = questionnaire
        }
    }
    
    @Environment(ResponsesStore.self) var responsesStore
    
    @State private var showDetails = false
    @State private var loadedQuestionnaire: WrappedQuestionnaire?
    @State private var showFileImporter = false
    @State private var viewState: ViewState = .idle
    
    @State private var activeQuestionnaireNewImpl: SpeziQuestionnaire.Questionnaire?
    @State private var activeQuestionnaireOldImpl: ModelsR4.Questionnaire?
    @State private var currentlyShownResponse: ModelsR4.QuestionnaireResponse?
    
    var body: some View {
        Form {
            Section {
                sectionContent
            } header: {
                Text("Surveys")
            } footer: {
                Text("Pick a predefined questionnaire or import one from a file.")
            }
            if let loadedQuestionnaire {
                Section("Loaded Questionnaire") {
                    loadedQuestionnaireSection(for: loadedQuestionnaire)
                }
            }
            if !responsesStore.responses.isEmpty {
                responsesSection
            }
        }
        .navigationTitle("Spezi Questionnaire")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink("Tests") {
                    TestsPage()
                }
            }
        }
        .viewStateAlert(state: $viewState)
        .sheet(item: $activeQuestionnaireNewImpl) { questionnaire in
            QuestionnaireSheet(questionnaire) { result in
                switch result {
                case .completed(let response):
                    do {
                        let fhirResponse = try ModelsR4.QuestionnaireResponse(response)
                        responsesStore.responses.append(fhirResponse)
                        try printFhirResponse(fhirResponse)
                    } catch {
                        print("\(error)")
                    }
                default:
                    break
                }
            }
        }
        .sheet(item: $activeQuestionnaireOldImpl) { r4Questionnaire in
            LegacyQuestionnaireView(
                questionnaire: r4Questionnaire,
                completionStepMessage: "Completed"
            ) { result in
                switch result {
                case .completed(let response):
                    responsesStore.responses.append(response)
                    try? printFhirResponse(response)
                default:
                    break
                }
                activeQuestionnaireOldImpl = nil
            }
        }
        .sheet(item: $currentlyShownResponse) { response in
            ResponseDetailsSheet(response: response)
        }
    }
    
    @ViewBuilder private var sectionContent: some View {
        HStack {
            Label("Completed", systemImage: "checkmark.circle")
            Spacer()
            Text(responsesStore.responses.count, format: .number)
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel("Completed, \(responsesStore.responses.count)")
        predefinedMenu
        fileImporterButton
    }
    
    private var predefinedMenu: some View {
        Menu("Pick Predefined Questionnaire") {
            Section {
                menuButton(title: "Question Kinds Showcase", questionnaire: .testQuestionnaire)
                menuButton(title: "Follow-Up Tasks", questionnaire: .followUpTasksQuestionnaire)
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
    
    private var responsesSection: some View {
        Section("Responses") {
            ForEach(responsesStore.responses, id: \.self) { response in
                Button {
                    currentlyShownResponse = response
                } label: {
                    VStack(alignment: .leading) {
                        Text(response.questionnaire?.value?.url.absoluteString ?? "n/a")
                        if let authoredDate = try? response.authored?.value?.asNSDate() {
                            Text(authoredDate, format: .iso8601)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
    
    private func menuButton(title: String, questionnaire: SpeziQuestionnaire.Questionnaire) -> some View {
        Button(title) {
            loadedQuestionnaire = .init(spezi: questionnaire)
        }
    }
    
    private func menuButton(title: String, questionnaire: ModelsR4.Questionnaire) -> some View {
        AsyncButton(title, state: $viewState) {
            loadedQuestionnaire = try .init(r4: questionnaire)
        }
    }
    
    
    @ViewBuilder
    private func loadedQuestionnaireSection(for loadedQuestionnaire: WrappedQuestionnaire) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loadedQuestionnaire.spezi.metadata.title)
                .font(.headline)
            if let url = loadedQuestionnaire.spezi.metadata.url?.absoluteString {
                Text(url)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 4)
        Button {
            activeQuestionnaireNewImpl = loadedQuestionnaire.spezi
        } label: {
            Label("Start Questionnaire (Spezi Impl)", systemImage: "play.circle")
        }
        Button {
            activeQuestionnaireOldImpl = loadedQuestionnaire.r4
        } label: {
            Label("Start Questionnaire (ResearchKit Impl)", systemImage: "play.circle")
        }
        .disabled(loadedQuestionnaire.r4 == nil)
        Button {
            showDetails = true
        } label: {
            Label("Details", systemImage: "info.circle")
        }
    }
    
    private func importQuestionnaire(from url: URL) throws -> WrappedQuestionnaire {
        let data = try Data(contentsOf: url)
        let fhirQuestionnaire = try JSONDecoder().decode(ModelsR4.Questionnaire.self, from: data)
        return try WrappedQuestionnaire(r4: fhirQuestionnaire)
    }
    
    private func printFhirResponse(_ response: ModelsR4.QuestionnaireResponse) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
        let data = try encoder.encode(response)
        let string = String(decoding: data, as: UTF8.self)
        print(string)
    }
}


extension ModelsR4.Questionnaire: @retroactive Identifiable {}
extension ModelsR4.QuestionnaireResponse: @retroactive Identifiable {}
