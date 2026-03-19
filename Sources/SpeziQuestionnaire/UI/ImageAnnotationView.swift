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
import UIKit


struct ImageAnnotationView: View {
    let image: UIImage
    @Binding var drawing: PKDrawing
    @Binding var drawingScale: Double
    let tool: PKInkingTool
    
    @State private var isDrawing = false
    @State private var isShowingToolPicker = false
    @State private var canvasSize = AsyncStream.makeStream(of: CGSize.self)
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .accessibilityLabel("Image")
            .overlay {
                CanvasView(
                    drawing: $drawing,
                    isDrawing: $isDrawing,
                    tool: tool,
                    drawingPolicy: .anyInput,
                    showToolPicker: $isShowingToolPicker
                )
                .onPreferenceChange(CanvasView.CanvasSizePreferenceKey.self) { size in
                    canvasSize.continuation.yield(size)
                }
            }
            .task {
                for await canvasSize in canvasSize.stream {
                    // depending on the image, we might need to take the image scale into account here
                    let scaleX = canvasSize.width / image.size.width
                    let scaleY = canvasSize.height / image.size.height
                    precondition(scaleX.isApproximatelyEqual(to: scaleY), "\(scaleX) vs \(scaleY) (diff: \(scaleX - scaleY))")
                    if scaleX != drawingScale {
                        drawingScale = scaleX
                    }
                }
                canvasSize = AsyncStream.makeStream()
            }
    }
}
