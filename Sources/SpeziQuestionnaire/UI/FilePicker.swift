//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PhotosUI
import SpeziFoundation
import SpeziViews
import SwiftUI
import UniformTypeIdentifiers


/// Reusable view that offers file import options from a range of sources.
struct FilePicker: View {
    enum Item: Sendable {
        case file(URL)
        case photo(PhotosPickerItem)
    }
    @Environment(\.isEnabled) private var isEnabled
    private let enabledTypes: Set<UTType>
    private let allowMultipleSelection: Bool
    private let selectionHandler: @Sendable ([Item]) -> Void
    @State private var isShowingPhotosPicker = false
    @State private var isShowingFileImporter = false
    @State private var viewState: ViewState = .idle
    @State private var selectedPhotos: [PhotosPickerItem] = []
    
    var body: some View {
        // TODO
        // - if there is only one enabled uti, we should skip the menu!
        // - if there are no enabled UTIs, we show the regular menu, but disable it!
        Menu {
            importMenuContents
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.green)
                    .accessibilityHidden(true)
                Text("Select File")
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .frame(maxHeight: .infinity)
            .padding()
        }
        .listRowInsets(EdgeInsets())
        .viewStateAlert(state: $viewState)
        // We need all of these modifiers placed here at the top level, since the buttons that trigger them are in the Menu,
        // and will disappear when tapped (bc the menu gets closed)
        .photosPicker(
            isPresented: $isShowingPhotosPicker,
            selection: $selectedPhotos,
            maxSelectionCount: nil,
            selectionBehavior: .default,
            matching: .any(of: Array {
                if shouldEnable(.movie) {
                    .videos
                }
                if shouldEnable(.image) {
                    // TODO if the user has live photos enabled, would this filter only photos w/out a live photo attached,
                    // or would it still include everything?
                    .images
                }
            }),
            preferredItemEncoding: .automatic
        )
        .fileImporter(
            isPresented: $isShowingFileImporter,
            allowedContentTypes: Array(enabledTypes),
            allowsMultipleSelection: allowMultipleSelection
        ) { result in
            switch result {
            case .success(let urls):
                selectionHandler(urls.map { .file($0) })
            case .failure(let error):
                viewState = .error(AnyLocalizedError(error: error))
            }
        }
        .onChange(of: selectedPhotos) { _, newValue in
            guard !newValue.isEmpty else {
                return
            }
            // it seems that the PhotosPicker only updates the binding, once, at the end, when the user confirmed the selection.
            // if multiple selection is enabled, the binding does not get continuously updated as the selection changes.
            let photos = exchange(&selectedPhotos, with: [])
            selectionHandler(photos.map { .photo($0) })
//            Task {
//                var attachments: [QuestionnaireResponses.CollectedAttachment] = []
//                for photo in photos {
//                    do {
//                        if let attachment = try await photo.loadTransferable(type: QuestionnaireResponses.CollectedAttachment.self) {
//                            attachments.append(attachment)
//                        } else {
//                            print("HMMMMM")
//                        }
//                    } catch {
//                        print("Failed to load image as attachment: \(error)")
//                    }
//                }
//                print("attachments", attachments)
//            }
        }
    }
    
    @ViewBuilder private var importMenuContents: some View {
        if shouldEnable(.image) { // TODO what about videos?
            takePhotoButton
            selectPhotosButton
        }
        Divider()
        importFileButton
    }
    
    private var takePhotoButton: some View {
        Button {
            // TODO
        } label: {
            Label("Take Photo", systemImage: "camera")
        }
    }
    
    private var selectPhotosButton: some View {
        Button {
            isShowingPhotosPicker = true
        } label: {
            Label("Select Photo", systemImage: "photo.on.rectangle")
        }
    }
    
    private var importFileButton: some View {
        Button {
            isShowingFileImporter = true
        } label: {
            Label("Select File", systemImage: "document")
        }
    }
    
    init(
        _ contentTypes: Set<UTType>,
        allowMultipleSelection: Bool,
        selectionHandler: @escaping @Sendable ([Item]) -> Void
    ) {
        self.enabledTypes = contentTypes.isEmpty ? [.data] : contentTypes
        self.allowMultipleSelection = allowMultipleSelection
        self.selectionHandler = selectionHandler
    }
    
    private func shouldEnable(_ uti: UTType) -> Bool {
        enabledTypes.contains { $0.isCompatible(with: uti) }
    }
}


extension UTType {
    func isCompatible(with other: Self) -> Bool {
        self.conforms(to: other) || other.conforms(to: self)
    }
}
