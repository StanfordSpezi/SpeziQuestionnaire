//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PhotosUI
import SpeziViews
import SwiftUI
import UniformTypeIdentifiers


struct FileAttachmentQuestionView: View {
    let config: Questionnaire.Task.Kind.FileAttachmentConfig
    @Binding var attachments: [QuestionnaireResponses.CollectedAttachment]
    
    var body: some View {
        ForEach(attachments) { attachment in
            row(for: attachment)
        }
        .onDelete { indices in
            attachments.remove(atOffsets: indices)
        }
        FilePicker(config.contentTypes, allowMultipleSelection: config.allowsMultipleSelection) { items in
            Task {
                await handle(items: items)
            }
        }
    }
    
    @ViewBuilder
    private func row(for attachment: QuestionnaireResponses.CollectedAttachment) -> some View {
        HStack {
            FileThumbnail(url: attachment.url, size: CGSize(width: 36, height: 36))
                .frame(width: 36, height: 36, alignment: .center)
            VStack(alignment: .leading) {
                Text(attachment.filename)
                    .accessibilityIdentifier("FileAttachmentFilename")
                if let size = attachment.size {
                    Text(Int64(size), format: .byteCount(style: .file, spellsOutZero: true))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("FileAttachmentFilesize")
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
    
    @concurrent
    private func handle(items: [FilePicker.Item]) async {
        let attachments = await withTaskGroup(of: QuestionnaireResponses.CollectedAttachment?.self) { taskGroup in
            for item in items {
                taskGroup.addTask {
                    do {
                        switch item {
                        case .file(let url):
                            return try QuestionnaireResponses.CollectedAttachment(url: url)
                        case .photo(let item):
                            return try await item.loadTransferable(type: QuestionnaireResponses.CollectedAttachment.self)
                        }
                    } catch {
                        print("ERROR: \(error)")
                        return nil
                    }
                }
            }
            var attachments: [QuestionnaireResponses.CollectedAttachment] = []
            while let attachment = await taskGroup.next() {
                if let attachment {
                    attachments.append(attachment)
                }
            }
            return attachments
        }
        await MainActor.run {
            self.attachments.append(contentsOf: attachments)
        }
    }
}
