//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ModelsR4


public struct TimedWalkTestResult: Sendable, Equatable, Hashable, Codable {
    public let stepCount: Double
    public let distance: Double
    public let startDate: Date
    public let endDate: Date
    
    
    public var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
    
    public var observation: Observation {
        let observation = Observation(
            code: CodeableConcept(),
            status: FHIRPrimitive(.final)
        )
        
        // Set basic elements applicable to all observations
        observation.id = UUID().uuidString.asFHIRStringPrimitive()
        observation.appendIdentifier(Identifier(id: observation.id))
        observation.setEffective(startDate: self.startDate, endDate: self.endDate)
        observation.setIssued(on: Date())
        
        // Add LOINC code dependent on the walk test duration.
        let loincSystem = "http://loinc.org".asFHIRURIPrimitive()
        if self.startDate.distance(to: self.endDate).rounded() == 60 * 60 {
            observation.appendCoding(
                Coding(
                    code: "62619-2".asFHIRStringPrimitive(),
                    system: loincSystem
                )
            )
        } else {
            observation.appendCoding(
                Coding(
                    code: "55430-3".asFHIRStringPrimitive(),
                    system: loincSystem
                )
            )
        }
        
        observation.appendComponent(
            builObservationComponent(
                code: "55423-8",
                system: "http://loinc.org",
                unit: "steps",
                value: self.stepCount
            )
        )
        
        observation.appendComponent(
            builObservationComponent(
                code: "55430-3",
                system: "http://loinc.org",
                unit: "m",
                value: self.distance
            )
        )
        
        return observation
    }
    
    
    public init(stepCount: Double, distance: Double, startDate: Date, endDate: Date) {
        self.stepCount = stepCount
        self.distance = distance
        self.startDate = startDate
        self.endDate = endDate
    }
    
    
    private func builObservationComponent(code: String, system: String, unit: String, value: Double) -> ObservationComponent {
        let coding = Coding(code: code.asFHIRStringPrimitive(), system: system.asFHIRURIPrimitive())
        let codeable = CodeableConcept(coding: [coding])
        let component = ObservationComponent(code: codeable)
        
        component.value = .quantity(
            Quantity(
                code: code.asFHIRStringPrimitive(),
                system: system.asFHIRURIPrimitive(),
                unit: unit.asFHIRStringPrimitive(),
                value: value.asFHIRDecimalPrimitive()
            )
        )
        
        return component
    }
}
