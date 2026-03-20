//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import PencilKit
import SpeziViews
import SwiftUI


/// View that implements the UI for responding to "annotate image" tasks.
struct AnnotateImageView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private let image: UIImage?
    private let task: Questionnaire.Task
    private let config: Questionnaire.Task.Kind.AnnotateImageConfig
    @Binding private var response: QuestionnaireResponses.ImageAnnotation
    
    @State private var showSheet = false
    
    var body: some View {
        Button {
            showSheet = true
        } label: {
            HStack(alignment: .top) {
                if let image {
                    previewImage(for: image)
                } else {
                    Image(systemName: "questionmark.square.dashed")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .accessibilityLabel("Image Missing")
                        .frame(width: 50)
                }
                VStack(alignment: .leading) {
                    HStack {
                        let regions = config.regions.map(\.name).joined(separator: ", ")
                        Text("Mark \(regions)")
                            .fontWeight(.medium)
                        Spacer()
                        let hasResponse = !response.isEmpty
                        Badge(hasResponse ? "Answered" : "Missing")
                            .tint(hasResponse ? .green : .orange)
                    }
                    Text("Tap to annotate")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .tint(colorScheme.textLabelForegroundStyle)
            }
        }
        .disabled(image == nil)
        .sheet(isPresented: $showSheet) {
            if let image {
                Sheet(task: task, config: config, image: image, response: $response)
            }
        }
    }
    
    init(
        task: Questionnaire.Task,
        config: Questionnaire.Task.Kind.AnnotateImageConfig,
        response: Binding<QuestionnaireResponses.ImageAnnotation>
    ) {
        self.task = task
        self.config = config
        self._response = response
        self.image = config.inputImage.image()
    }
    
    private func previewImage(for image: UIImage) -> some View {
        ImageAnnotationView(image: image, drawing: $response.drawing, tool: .init(.pen))
            .accessibilityLabel("Image")
            .frame(height: 100)
            .disabled(true)
    }
}


extension AnnotateImageView {
    fileprivate static func ink(for region: Questionnaire.Task.Kind.AnnotateImageConfig.Region) -> PKInk {
        PKInk(.pen, color: UIColor(region.color))
    }
}


extension AnnotateImageView {
    private struct Badge<Label: View>: View {
        private let label: Label
        
        var body: some View {
            label
                .font(.caption.weight(.medium))
                .foregroundStyle(.tint)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 6))
        }
        
        init(@ViewBuilder label: @MainActor () -> Label) {
            self.label = label()
        }
        
        init(_ title: LocalizedStringResource) where Label == Text {
            self.init {
                Text(title)
            }
        }
    }
}


private struct Sheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let task: Questionnaire.Task
    let config: Questionnaire.Task.Kind.AnnotateImageConfig
    let image: UIImage
    @Binding var response: QuestionnaireResponses.ImageAnnotation
    
    @State private var isDrawing = false
    @State private var isShowingToolPicker = false
    @State private var selectedRegion: Questionnaire.Task.Kind.AnnotateImageConfig.Region?
    @State private var isShowingResetAlert = false
    
    var body: some View {
        NavigationStack { // swiftlint:disable:this closure_body_length
            VStack(alignment: .leading) {
                Group {
                    Text(task.title)
                        .font(.headline)
                    Text(task.subtitle)
                        .font(.subheadline)
                    Divider()
                    Text(verbatim: """
                        Please annotate the image below.
                        Select a region marker from underneath the image, and highlight the corresponding areas in the image.
                        """)
                }
                .padding(.horizontal)
                Divider()
                HStack {
                    Spacer()
                    ImageAnnotationView(
                        image: image,
                        drawing: $response.drawing,
                        tool: selectedRegion.map { PKInkingTool(ink: AnnotateImageView.ink(for: $0), width: 2) } ?? .init(.crayon)
                    )
                    .disabled(selectedRegion == nil)
                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
                Form {
                    ForEach(config.regions) { region in
                        RegionRow(region: region, selectedRegion: $selectedRegion, drawing: $response.drawing)
                    }
                }
                .frame(height: 150)
                .sensoryFeedback(.selection, trigger: selectedRegion)
            }
            .navigationTitle("Annotate Image")
            .navigationBarTitleDisplayMode(.inline)
            .makeBackgroundMatchFormBackground()
            .toolbar {
                toolbarContent
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            if config.regions.count == 1 {
                selectedRegion = config.regions.first
            }
        }
    }
    
    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .destructive) {
                isShowingResetAlert = true
            } label: {
                Label("Reset", systemImage: "trash")
            }
            .tint(.red)
            .confirmationDialog("Reset Annotations", isPresented: $isShowingResetAlert) {
                Button("Reset", role: .destructive) {
                    response.drawing = .init()
                }
            } message: {
                Text("Do you want to remove all annotations?")
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            if #available(iOS 26, *) {
                Button(role: .confirm) {
                    dismiss()
                } label: {
                    Label("Save", systemImage: "checkmark")
                }
            } else {
                Button {
                    dismiss()
                } label: {
                    Label("Save", systemImage: "checkmark")
                }
                .buttonStyleGlassProminent()
            }
        }
    }
}


extension Sheet {
    private struct RegionRow: View {
        typealias Region = Questionnaire.Task.Kind.AnnotateImageConfig.Region
        
        @Environment(\.colorScheme) private var colorScheme
        
        let region: Region
        @Binding var selectedRegion: Region?
        @Binding var drawing: PKDrawing
        
        var body: some View {
            Button {
                selectedRegion = region
            } label: {
                HStack {
                    Circle()
                        .fill(region.color)
                        .frame(height: 17)
                    Text(region.name)
                        .foregroundStyle(colorScheme.textLabelForegroundStyle)
                    Spacer()
                    if selectedRegion == region {
                        Image(systemName: "checkmark")
                            .accessibilityHidden(true)
                            .fontWeight(.medium)
                    }
                }
            }
        }
    }
}
