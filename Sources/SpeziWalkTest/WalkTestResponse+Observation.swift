//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ModelsR4

extension WalkTestResponse {
    var observation: Observation {
        let uuid = UUID()
        let observation = Observation(
            code: CodeableConcept(),
            status: FHIRPrimitive(.final)
        )
        
        // Set basic elements applicable to all observations
        observation.id = uuid.uuidString.asFHIRStringPrimitive()
        observation.appendIdentifier(Identifier(id: observation.id))
        observation.setEffective(startDate: self.startDate, endDate: self.endDate)
        observation.setIssued(on: Date())
        
        let stepsComponent = builObservationComponent(
            code: "55423-8",
            system: "http://loinc.org",
            unit: "steps",
            value: self.stepCount
        )
        observation.appendComponent(stepsComponent)
        
        // EDIT CODE BASED ON DURATION OF WALK
        let distanceComponent = builObservationComponent(
            code: "55430-3",
            system: "http://loinc.org",
            unit: "m",
            value: self.distance
        )
        observation.appendComponent(distanceComponent)
        
        return observation
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
