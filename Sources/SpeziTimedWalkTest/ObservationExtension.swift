//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
// Based on https://github.com/StanfordBDHG/HealthKitOnFHIR/blob/main/Sources/HealthKitOnFHIR/Observation%20Extensions/Observation%2BCollections.swift
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import ModelsR4


extension Observation {
    private func appendElement<T>(_ element: T, to collection: ReferenceWritableKeyPath<Observation, [T]?>) {
        // swiftlint:disable:previous discouraged_optional_collection
        // Unfortunately we need to use an optional collection here as the ModelsR4 modules uses optional collections in the Observation type.
        
        guard self[keyPath: collection] != nil else {
            self[keyPath: collection] = [element]
            return
        }
        
        self[keyPath: collection]?.append(element)
    }
    
    private func appendElements<T>(_ elements: [T], to collection: ReferenceWritableKeyPath<Observation, [T]?>) {
        // swiftlint:disable:previous discouraged_optional_collection
        // Unfortunately we need to use an optional collection here as the ModelsR4 modules uses optional collections in the Observation type.
        
        if self[keyPath: collection] == nil {
            self[keyPath: collection] = []
            self[keyPath: collection]?.reserveCapacity(elements.count)
        } else {
            self[keyPath: collection]?.reserveCapacity((self[keyPath: collection]?.count ?? 0) + elements.count)
        }
        
        for element in elements {
            appendElement(element, to: collection)
        }
    }
    
    
    func appendIdentifier(_ identifier: Identifier) {
        appendElement(identifier, to: \.identifier)
    }
    
    func appendIdentifiers(_ identifiers: [Identifier]) {
        appendElements(identifiers, to: \.identifier)
    }
    
    func appendCategory(_ category: CodeableConcept) {
        appendElement(category, to: \.category)
    }
    
    func appendCategories(_ categories: [CodeableConcept]) {
        appendElements(categories, to: \.category)
    }
    
    func appendCoding(_ coding: Coding) {
        appendElement(coding, to: \.code.coding)
    }
    
    func appendCodings(_ codings: [Coding]) {
        appendElements(codings, to: \.code.coding)
    }
    
    func appendComponent(_ component: ObservationComponent) {
        appendElement(component, to: \.component)
    }
    
    func appendComponents(_ components: [ObservationComponent]) {
        appendElements(components, to: \.component)
    }
    
    func setEffective(startDate: Date, endDate: Date) {
        if startDate == endDate {
            effective = .dateTime(FHIRPrimitive(try? DateTime(date: startDate)))
        } else {
            effective = .period(
                Period(
                    end: FHIRPrimitive(try? DateTime(date: endDate)),
                    start: FHIRPrimitive(try? DateTime(date: startDate))
                )
            )
        }
    }
    
    func setIssued(on date: Date) {
        issued = FHIRPrimitive(try? Instant(date: date))
    }
    
    func setValue(_ quantity: Quantity) {
        value = .quantity(quantity)
    }
    
    func setValue(_ string: String) {
        value = .string(string.asFHIRStringPrimitive())
    }
}
