//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


private import SpeziFoundation


/// A path to a component in a ``Questionnaire``
public struct ComponentPath: Hashable, ExpressibleByArrayLiteral, Sendable {
    private let elements: [Element]
    
    init(_ elements: String...) {
        self.elements = elements
    }
    
    public init(arrayLiteral elements: String...) {
        self.elements = elements
    }
    
    public init(_ other: some Sequence<Element>) {
        self.elements = Array(other)
    }
}


extension ComponentPath {
    func isDescendant(of other: Self) -> Bool {
        self.count > other.count && self.starts(with: other)
    }
}


extension ComponentPath {
    func section(in questionnaire: Questionnaire) -> Questionnaire.Section? {
        self[safe: 0].flatMap { id in questionnaire.sections.first { $0.id == id } }
    }
    
    func task(in questionnaire: Questionnaire) -> Questionnaire.Task? {
        guard let id = self[safe: 1], let section = section(in: questionnaire) else {
            return nil
        }
        return section.tasks.first { $0.id == id }
    }
    
    func option(in questionnaire: Questionnaire) -> Questionnaire.Task.SCMCOption? {
        guard let id = self[safe: 2], section(in: questionnaire) != nil, let task = task(in: questionnaire) else {
            return nil
        }
        return switch task.kind {
        case .singleChoice(let options), .multipleChoice(let options):
            options.first { $0.id == id }
        case .instructional, .freeText, .dateTime:
            nil
        }
    }
}

extension ComponentPath: LosslessStringConvertible {
    public var description: String {
        elements.lazy
            .map { element in
                // TODO what if `element` also contains '?
                element.contains("/") ? "'\(element)'" : element
            }
            .joined(separator: "/")
    }
    
    public init?(_ description: String) {
        fatalError("Not Yet Implemented")
    }
}


extension ComponentPath: RandomAccessCollection {
    public typealias Element = String
    public typealias Index = [Element].Index
    
    public var startIndex: Index {
        elements.startIndex
    }
    
    public var endIndex: Index {
        elements.endIndex
    }
    
    public subscript(position: Index) -> String {
        elements[position]
    }
}
