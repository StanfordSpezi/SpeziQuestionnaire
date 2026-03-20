//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import PencilKit
private import SpeziViews
public import class UIKit.UIImage


extension QuestionnaireResponses {
    /// An annotation collected by asking the user to draw onto an image.
    public struct ImageAnnotation: CustomResponseValueProtocol, Hashable, Sendable {
        /// The actual drawing produced by the user.
        public var drawing: PKDrawing
        
        /// Whether the annotation is empty.
        public var isEmpty: Bool {
            drawing.isEmpty
        }
        
        /// Creates an empty annotation.
        public init() {
            self.init(drawing: PKDrawing())
        }
        
        /// Creates an annotation from a PencilKit drawing.
        public init(drawing: PKDrawing) {
            self.drawing = drawing
        }
        
        /// Produces an image by overlaying the drawing onto a base image.
        public func draw(onto baseImage: UIImage) -> UIImage? {
            let scale: CGFloat = 1
            guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
                  let baseCGImage = baseImage.cgImage,
                  let drawingCGImage = drawing.image(from: drawing.bounds, scale: scale).cgImage else {
                return nil
            }
            let ctxBounds = CGRect(
                origin: .zero,
                size: CGSize(width: baseCGImage.width, height: baseCGImage.height)
            )
            guard let context = CGContext(
                data: nil,
                width: Int(ctxBounds.width),
                height: Int(ctxBounds.height),
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return nil
            }
            context.draw(baseCGImage, in: ctxBounds)
            context.draw(drawingCGImage, in: { () -> CGRect in
                // we need to flip the rect to compensate for the CGContext's flipped coordinate system
                let rect = drawing.bounds.applying(
                    CGAffineTransform(scaleX: scale, y: scale)
                )
                return CGRect(
                    x: rect.origin.x,
                    y: ctxBounds.height - rect.origin.y - rect.height,
                    width: rect.width,
                    height: rect.height
                )
            }())
            return context.makeImage().map { UIImage(cgImage: $0) }
        }
    }
}
