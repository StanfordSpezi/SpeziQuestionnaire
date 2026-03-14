//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable missing_docs file_types_order all

public import CoreTransferable
public import Foundation
public import UniformTypeIdentifiers
public import PencilKit
public import CoreGraphics
public import class UIKit.UIImage


extension QuestionnaireResponses {
    /// Storage container for task responses.
    public struct Responses: Hashable, Collection, Sendable {
        public typealias Storage = [Questionnaire.Task.ID: Response]
        public typealias Element = Storage.Element
        public typealias Index = Storage.Index
        
        fileprivate var storage: Storage = [:]
        
        public var startIndex: Index {
            storage.startIndex
        }
        public var endIndex: Index {
            storage.endIndex
        }
        
        public init() {}
        
        /* private-but-testable */ init(_ entries: Storage) {
            self.storage = entries
        }
        
        /// Returns a new  ``Responses`` instance, with all empty fields and values removed.
        func sanitized() -> Responses? {
            let newEntries = storage.compactMapValues {
                $0.sanitized()
            }
            return newEntries.isEmpty ? nil : Responses(newEntries)
        }
        
        public func index(after idx: Index) -> Index {
            storage.index(after: idx)
        }
        
        public subscript(position: Index) -> Element {
            storage[position]
        }
        
        public subscript(key: Questionnaire.Task.ID) -> Response {
            get {
                storage[key] ?? .init(value: .none)
            }
            set {
                if newValue.value.shouldClear {
                    storage[key] = nil
                } else {
                    storage[key] = newValue
                }
            }
        }
    }
    
    
    public protocol CustomResponseValueProtocol: Hashable, Sendable, SendableMetatype {
        init() // TODO is this needed?
        
        var isEmpty: Bool { get }
        
        var shouldClearResponse: Bool { get }
        
//        func summarize(for task: Questionnaire.Task, using runner: LLMRunner) async throws -> String? {
    }
    
    
    /// A response that was collected for some task within a questionnaire.
    public struct Response: Hashable, Sendable { // TODO is the Hashability here really needed?
        public enum Value: Hashable, Sendable {
            /// The lack of a response
            case none
            case string(String)
            case bool(Bool)
            case date(DateComponents)
            case number(Double)
            case choice(ChoiceResponse)
            case attachments([CollectedAttachment])
            case custom(any CustomResponseValueProtocol)
//            case annotatedImage(AnnotatedImage) // TODO we need to model this via one of the FHIR types!!!!
            
            public static func == (lhs: Self, rhs: Self) -> Bool {
                switch lhs {
                case .none:
                    return switch rhs {
                    case .none: true
                    default: false
                    }
                case .string(let lhs):
                    return switch rhs {
                    case .string(lhs): true
                    default: false
                    }
                case .bool(let lhs):
                    return switch rhs {
                    case .bool(lhs): true
                    default: false
                    }
                case .date(let lhs):
                    return switch rhs {
                    case .date(lhs): true
                    default: false
                    }
                case .number(let lhs):
                    return switch rhs {
                    case .number(lhs): true
                    default: false
                    }
                case .choice(let lhs):
                    return switch rhs {
                    case .choice(lhs): true
                    default: false
                    }
                case .attachments(let lhs):
                    return switch rhs {
                    case .attachments(lhs): true
                    default: false
                    }
                case .custom(let lhs):
                    return switch rhs {
                    case .custom(let rhs):
                        lhs.isEqual(to: rhs)
                    default:
                        false
                    }
                }
            }
            
            public func hash(into hasher: inout Hasher) {
                switch self {
                case .none:
                    hasher.combine(ObjectIdentifier(Never.self))
                case .string(let value):
                    hasher.combine(ObjectIdentifier(type(of: value)))
                    hasher.combine(value)
                case .bool(let value):
                    hasher.combine(ObjectIdentifier(type(of: value)))
                    hasher.combine(value)
                case .date(let value):
                    hasher.combine(ObjectIdentifier(type(of: value)))
                    hasher.combine(value)
                case .number(let value):
                    hasher.combine(ObjectIdentifier(type(of: value)))
                    hasher.combine(value)
                case .choice(let value):
                    hasher.combine(ObjectIdentifier(type(of: value)))
                    hasher.combine(value)
                case .attachments(let value):
                    hasher.combine(ObjectIdentifier(type(of: value)))
                    hasher.combine(value)
                case .custom(let value):
                    hasher.combine(ObjectIdentifier(type(of: value)))
                    value.hash(into: &hasher)
                }
            }
        }
        
        public enum NestedResponseIdentifier: Hashable, Sendable {
            case choiceOption(Questionnaire.Task.Kind.ChoiceConfig.Option.ID)
        }
        
        /// The response's value.
        public var value: Value
        
        /// Nested responses that were collected for sub-tasks nested within this task.
        ///
        /// - Important: This property may only be used if ``value`` is not ``Value/none``
        public var nestedResponses: [NestedResponseIdentifier: Responses]
        
        init(value: Value, nestedResponses: [NestedResponseIdentifier: Responses] = [:]) {
            self.value = value
            self.nestedResponses = nestedResponses
        }
        
        func sanitized() -> Response? {
            guard !value.shouldClear else {
                // NOTE that we intentionally don't check nestedResponses here,
                // since that is only allowed to be non-empty if value is also not empty
                return nil
            }
            return Self(
                value: value,
                nestedResponses: nestedResponses.compactMapValues { $0.sanitized() }
            )
        }
    }
    
    
    public struct ChoiceResponse: Hashable, Sendable {
        public typealias Option = Questionnaire.Task.Kind.ChoiceConfig.Option
        
        /// The currently selected options.
        public private(set) var selectedOptions: Set<Option.ID>
        public internal(set) var freeTextOtherResponse: String?
        
        var isEmpty: Bool {
            selectedOptions.isEmpty && freeTextOtherResponse == nil
        }
        
        var didSelectFreeTextOtherOption: Bool {
            get {
                freeTextOtherResponse != nil
            }
            set {
                switch (didSelectFreeTextOtherOption, newValue) {
                case (false, false), (true, true):
                    return
                case (true, false):
                    freeTextOtherResponse = nil
                case (false, true):
                    freeTextOtherResponse = ""
                }
            }
        }
        
        init(selectedOptions: Set<Option.ID>, freeTextOtherResponse: String? = nil) {
            self.selectedOptions = selectedOptions
            self.freeTextOtherResponse = freeTextOtherResponse
        }
        
        func didSelect(_ optionId: Option.ID) -> Bool {
            selectedOptions.contains(optionId)
        }
        
        mutating func select(_ optionId: Option.ID) {
            if !selectedOptions.contains(optionId) {
                selectedOptions.insert(optionId)
            }
        }
        mutating func deselect(_ optionId: Option.ID) {
            selectedOptions.remove(optionId)
        }
    }
}


extension QuestionnaireResponses.Responses {
    public subscript(path: QuestionnaireResponses.ResponsesPath) -> QuestionnaireResponses.Responses {
        get { self[responsesPath: path] }
        set { self[responsesPath: path] = newValue }
    }
    
    public subscript(path: QuestionnaireResponses.ResponsePath) -> QuestionnaireResponses.Response {
        get { self[responsePath: path] }
        set { self[responsePath: path] = newValue }
    }
    
    fileprivate subscript(responsesPath path: some Collection<QuestionnaireResponses.ResponsesPath.Element>) -> QuestionnaireResponses.Responses {
        get {
            guard let first = path.first else {
                // we have a path that is pointing to a responses container, and the path is empty, and we already are at a resposes container.
                return self
            }
            switch first {
            case .task(let taskId):
                return self[taskId][responsesPath: path.dropFirst()]
            case .choiceOption:
                fatalError("Invalid input: Cannot subscript into \(Self.self) using \(first)")
            }
        }
        set {
            guard let first = path.first else {
                // we have a path that is pointing to a responses container, and the path is empty, and we already are at a resposes container.
                self = newValue
                return
            }
            switch first {
            case .task(let taskId):
                self[taskId][responsesPath: path.dropFirst()] = newValue
            case .choiceOption:
                fatalError("Invalid input: Cannot subscript into \(Self.self) using \(first)")
            }
        }
    }
    
    fileprivate subscript(responsePath path: some Collection<QuestionnaireResponses.ResponsePath.Element>) -> QuestionnaireResponses.Response {
        get {
            switch path.first {
            case nil:
                fatalError("Invalid path")
            case .task(let taskId):
                return self[taskId][responsePath: path.dropFirst()]
            case .choiceOption:
                fatalError("Invalid path")
            }
        }
        set {
            switch path.first {
            case nil:
                fatalError("Invalid path")
            case .task(let taskId):
                self[taskId][responsePath: path.dropFirst()] = newValue
            case .choiceOption:
                fatalError("Invalid path")
            }
        }
    }
}


extension QuestionnaireResponses.Response {
    fileprivate subscript(responsePath path: some Collection<QuestionnaireResponses.ResponsesPath.Element>) -> QuestionnaireResponses.Response {
        get {
            guard let first = path.first else {
                return self // empty path --> identity
            }
            switch first {
            case .task:
                fatalError("Invalid input: Cannot subscript into \(Self.self) using \(first)")
            case .choiceOption(let optionId):
                return self.nestedResponses[.choiceOption(optionId), default: .init()][responsePath: path.dropFirst()]
            }
        }
        set {
            guard let first = path.first else {
                self = newValue // empty path --> identity
                return
            }
            switch first {
            case .task:
                fatalError("Invalid input: Cannot subscript into \(Self.self) using \(first)")
            case .choiceOption(let optionId):
                self.nestedResponses[.choiceOption(optionId), default: .init()][responsePath: path.dropFirst()] = newValue
            }
        }
    }
    
    fileprivate subscript(responsesPath path: some Collection<QuestionnaireResponses.ResponsesPath.Element>) -> QuestionnaireResponses.Responses {
        get {
            guard let first = path.first else {
                fatalError("Invalid input: Cannot subscript into \(Self.self) using empty \(QuestionnaireResponses.ResponsesPath.self)")
            }
            switch first {
            case .task:
                fatalError("Invalid input: Cannot subscript into \(Self.self) using \(first)")
            case .choiceOption(let optionId):
                return self.nestedResponses[.choiceOption(optionId), default: .init()][responsesPath: path.dropFirst()]
            }
        }
        set {
            guard let first = path.first else {
                fatalError("Invalid input: Cannot subscript into \(Self.self) using empty \(QuestionnaireResponses.ResponsesPath.self)")
            }
            switch first {
            case .task:
                fatalError("Invalid input: Cannot subscript into \(Self.self) using \(first)")
            case .choiceOption(let optionId):
                self.nestedResponses[.choiceOption(optionId), default: .init()][responsesPath: path.dropFirst()] = newValue
            }
        }
    }
}

extension QuestionnaireResponses.Response.Value {
    package var boolValue: Bool? {
        get { if case .bool(let value) = self { value } else { nil } }
        set { self = newValue.map { Self.bool($0) } ?? .none }
    }
    
    package var stringValue: String? {
        get { if case .string(let value) = self { value } else { nil } }
        set { self = newValue.map { Self.string($0) } ?? .none }
    }
    
    package var dateValue: DateComponents? {
        get { if case .date(let value) = self { value } else { nil } }
        set { self = newValue.map { Self.date($0) } ?? .none }
    }
    
    package var numberValue: Double? {
        get { if case .number(let value) = self { value } else { nil } }
        set { self = newValue.map { Self.number($0) } ?? .none }
    }
    
    /// - Important: Assigning this property will unconditionally turn this `ResponseValue` into a choice question response value,
    ///     regardless of the actual kind of the task to which the response belongs.
    package var choiceValue: QuestionnaireResponses.ChoiceResponse {
        get { if case .choice(let value) = self { value } else { .init(selectedOptions: []) } }
        set { self = .choice(newValue) }
    }
    
    package var attachmentsValue: [QuestionnaireResponses.CollectedAttachment]? {
        get { if case .attachments(let value) = self { value } else { nil } }
        set { self = newValue.map { Self.attachments($0) } ?? .none }
    }
    
    package var annotatedImageValue: QuestionnaireResponses.AnnotatedImage? {
        get { self[asCustomTypeA: QuestionnaireResponses.AnnotatedImage.self] }
        set { self[asCustomTypeA: QuestionnaireResponses.AnnotatedImage.self] = newValue }
    }
    
    package subscript<T: QuestionnaireResponses.CustomResponseValueProtocol>(
        asCustomTypeA type: T.Type
    ) -> T? {
        get { if case .custom(let value) = self { value as? T } else { nil } }
        set { self = newValue.map { Self.custom($0) } ?? .none }
    }
}


extension QuestionnaireResponses.Response.Value {
    public var isEmpty: Bool {
        switch self {
        case .none:
            true
        case .string(let string):
            string.isEmpty
        case .bool:
            false
        case .date(let components):
            [Calendar.Component.year, .month, .day, .hour, .minute, .second].allSatisfy {
                components.value(for: $0) == nil
            }
        case .number:
            false
        case .choice(let choiceResponse):
            choiceResponse.isEmpty
        case .attachments(let attachments):
            attachments.isEmpty
        case .custom(let value):
            value.isEmpty
        }
    }
    
    var shouldClear: Bool {
        switch self {
        case .none, .string, .bool, .date, .number, .choice, .attachments:
            self.isEmpty
        case .custom(let value):
            value.shouldClearResponse
        }
    }
}


// MARK: File Attachments

extension QuestionnaireResponses {
    public final class CollectedAttachment: Hashable, Identifiable, Sendable {
        private static let tmpDir = URL.temporaryDirectory.appending(path: "edu.stanford.SpeziQuestionnaire.TmpAttachment")
        
        public let id = UUID()
        public let filename: String
        /// A temporary file url where the attachment is stored.
        ///
        /// - Important: This file will automatically be deleted when the attachment object gets deallocated.
        public let url: URL
        /// The attachment's file size, in bytes
        public let size: UInt64?
        
        /// The attachment's content type, determined based on the fle at `url`.
        public var contentType: UTType? {
            (try? url.resourceValues(forKeys: [.contentTypeKey]))?.contentType
        }
        
        package init(url inputUrl: URL) throws {
            guard inputUrl.startAccessingSecurityScopedResource() else {
                throw NSError(domain: "edu.stanford.Spezi", code: 0, userInfo: [
                    NSLocalizedDescriptionKey: "Unable to access file url"
                ])
            }
            defer {
                inputUrl.stopAccessingSecurityScopedResource()
            }
            self.filename = inputUrl.lastPathComponent
            self.url = Self.tmpDir
                .appending(component: id.uuidString)
                .appendingPathExtension(inputUrl.pathExtension)
            try FileManager.default.createDirectory(at: Self.tmpDir, withIntermediateDirectories: true)
            try FileManager.default.copyItem(at: inputUrl, to: self.url)
            self.size = try FileManager.default.attributesOfItem(atPath: self.url.path)[FileAttributeKey.size] as? UInt64
        }
        
        public static func == (lhs: CollectedAttachment, rhs: CollectedAttachment) -> Bool {
            lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        deinit {
            try? FileManager.default.removeItem(at: url)
        }
    }
}


extension QuestionnaireResponses.CollectedAttachment: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .item) { input in
            try Self(url: input.file)
        }
    }
}


extension QuestionnaireResponses {
    public struct AnnotatedImage: CustomResponseValueProtocol, Hashable, Sendable { // TODO rename ImageAnnotation? (it only stores the annotation, not the image)
        public var scaleFactor: Double
        public var drawing: PKDrawing
        
        public var isEmpty: Bool {
            drawing.strokes.isEmpty
        }
        
        public var shouldClearResponse: Bool {
            false
        }
        
        public init(drawing: PKDrawing, scaleFactor: Double = 1) {
            self.drawing = drawing
            self.scaleFactor = scaleFactor
        }
        
        public init() {
            self.init(drawing: PKDrawing(), scaleFactor: 1)
        }
        
        public func draw(onto baseImage: UIImage) -> UIImage? {
            guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
                  let baseCGImage = baseImage.cgImage,
                  let drawingCGImage = drawing.image(from: drawing.bounds, scale: 1 / scaleFactor).cgImage else {
                return nil
            }
            let ctxBounds = CGRect(
                origin: .zero,
                size: CGSize(width: baseCGImage.width, height: baseCGImage.height)
            )
            let context = CGContext(
                data: nil,
                width: Int(ctxBounds.width),
                height: Int(ctxBounds.height),
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )!
            context.draw(baseCGImage, in: ctxBounds)
            context.draw(drawingCGImage, in: { () -> CGRect in
                // we need to flip the rect to compensate for the CGContext's flipped coordinate system
                let rect = drawing.bounds.applying(
                    CGAffineTransform(scaleX: 1 / scaleFactor, y: 1 / scaleFactor)
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


extension PKDrawing: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.bounds)
        hasher.combine(self.strokes.count)
    }
}

extension Equatable {
    fileprivate func isEqual(to other: Any) -> Bool {
        if let other = other as? Self {
            self == other
        } else {
            false
        }
    }
}
