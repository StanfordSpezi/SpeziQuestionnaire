//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


extension Set {
    mutating func remove(where predicate: (Element) -> Bool) {
        for element in self where predicate(element) {
            remove(element)
        }
    }
}
