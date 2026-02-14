//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


struct ComponentPath: Hashable, ExpressibleByArrayLiteral, Sendable {
    private let elements: [Element]
    
    init(_ elements: String...) {
        self.elements = elements
    }
    
    init(arrayLiteral elements: String...) {
        self.elements = elements
    }
    
    init(_ other: some Sequence<Element>) {
        self.elements = Array(other)
    }
}

extension ComponentPath: CustomStringConvertible {
    var description: String {
        elements.joined(separator: "/")
    }
}


extension ComponentPath: RandomAccessCollection {
    typealias Element = String
    typealias Index = [Element].Index
    
    var startIndex: Index {
        elements.startIndex
    }
    
    var endIndex: Index {
        elements.endIndex
    }
    
    subscript(position: Index) -> String {
        elements[position]
    }
}
