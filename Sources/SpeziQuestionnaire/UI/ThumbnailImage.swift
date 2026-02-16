//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import QuickLookThumbnailing
import SwiftUI


struct FileThumbnail: View {
    @Environment(\.displayScale) private var scale
    private let url: URL
    private let size: CGSize
    @State private var image: UIImage?
    
    var body: some View {
        VStack {
            if let image {
                Image(uiImage: image)
            }
        }
        .task {
            let request = QLThumbnailGenerator.Request(
                fileAt: url,
                size: size,
                scale: scale,
                representationTypes: .all
            )
            let generator = QLThumbnailGenerator.shared
            guard let thumbnail = try? await generator.generateBestRepresentation(for: request) else {
                return
            }
            self.image = thumbnail.uiImage
        }
    }
    
    init(url: URL, size: CGSize = CGSize(width: 50, height: 50)) {
        self.url = url
        self.size = size
    }
}
