//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Numerics
import PencilKit
import SpeziViews
import SwiftUI


/// View that overlays an editable `PKDrawing` onto a `UIImage`.
struct ImageAnnotationView: View {
    private let image: UIImage
    private let imageSizeInPixels: CGSize
    @Binding private var drawing: PKDrawing
    private let tool: PKInkingTool
    @State private var imageViewSize: CGSize = .zero
    
    var body: some View {
        Image(uiImage: image)
            // swiftlint:disable:previous accessibility_label_for_image
            // we expect the caller to set an accessibility identifier (bc we don't know what the image will be)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onGeometryChange(for: CGSize.self, of: \.size) { size in
                imageViewSize = size
            }
            .overlay {
                CanvasView(
                    drawing: $drawing,
                    tool: tool,
                    drawingPolicy: .anyInput
                )
                // we want the canvas' size to match that of the image
                .frame(
                    width: imageSizeInPixels.width,
                    height: imageSizeInPixels.height,
                    alignment: .center
                )
                // but scaled to the image view
                .scaleEffect(
                    imageViewSize.width / imageSizeInPixels.width,
                    anchor: .center
                )
            }
    }
    
    
    /// Creates an image annotation view.
    ///
    /// - parameter image: The image being annotated.
    /// - parameter drawing: A `Binding` to the variable containing the drawing.
    /// - parameter tool: The `PKInkingTool` that should be used when the user draws on the image.
    ///
    /// The `drawing` will be
    init(image: UIImage, drawing: Binding<PKDrawing>, tool: PKInkingTool) {
        self.image = image
        self.imageSizeInPixels = image.size.applying(.identity.scaledBy(x: image.scale, y: image.scale))
        self._drawing = drawing
        self.tool = tool
    }
}
