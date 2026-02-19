//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable line_length force_unwrapping

import Foundation


extension Questionnaire {
    /// Patient Health Questionnaire-9
    /// 
    /// - SeeAlso: https://www.apa.org/depression-guideline/patient-health-questionnaire.pdf
    public static let phq9 = Self(
        metadata: .init(
            id: "phq9",
            url: nil,
            title: "Patient Health Questionnaire-9",
            explainer: ""
        ),
        sections: [
            .init(id: "H1/T1", tasks: [
                .init(
                    id: "instructions",
                    title: "",
                    kind: .instructional("Over the **last 2 weeks**, how often have you been bothered by any of the following problems?")
                ),
                .init(
                    id: "H1/T1/Q1",
                    title: "Little interest or pleasure in doing things",
                    kind: .choice(.init(options: .phq9Options, allowsMultipleSelection: false))
                ),
                .init(
                    id: "H1/T1/Q2",
                    title: "Feeling down, depressed, or hopeless",
                    kind: .choice(.init(options: .phq9Options, allowsMultipleSelection: false))
                ),
                .init(
                    id: "H1/T1/Q3",
                    title: "Trouble falling or staying asleep, or sleeping too much",
                    kind: .choice(.init(options: .phq9Options, allowsMultipleSelection: false))
                ),
                .init(
                    id: "H1/T1/Q4",
                    title: "Feeling tired or having little energy",
                    kind: .choice(.init(options: .phq9Options, allowsMultipleSelection: false))
                ),
                .init(
                    id: "H1/T1/Q5",
                    title: "Poor appetite or overeating",
                    kind: .choice(.init(options: .phq9Options, allowsMultipleSelection: false))
                ),
                .init(
                    id: "H1/T1/Q6",
                    title: "Feeling bad about yourself — or that you are a failure or have let yourself or your family down",
                    kind: .choice(.init(options: .phq9Options, allowsMultipleSelection: false))
                ),
                .init(
                    id: "H1/T1/Q7",
                    title: "Trouble concentrating on things, such as reading the newspaper or watching television",
                    kind: .choice(.init(options: .phq9Options, allowsMultipleSelection: false))
                ),
                .init(
                    id: "H1/T1/Q8",
                    title: "Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual",
                    kind: .choice(.init(options: .phq9Options, allowsMultipleSelection: false))
                ),
                .init(
                    id: "H1/T1/Q9",
                    title: "Thoughts that you would be better off dead or of hurting yourself in some way",
                    kind: .choice(.init(options: .phq9Options, allowsMultipleSelection: false))
                )
            ])
        ]
    )
}

extension [Questionnaire.Task.Kind.ChoiceConfig.Option] {
    fileprivate static let phq9Options: Self = [
        .init(
            id: "0",
            title: "Not at all",
            fhirCoding: .init(
                system: URL(string: "http://hl7.org/fhir/uv/sdc/CodeSystem/CSPHQ9")!,
                code: "Not-at-all"
            )
        ),
        .init(
            id: "1",
            title: "Several days",
            fhirCoding: .init(
                system: URL(string: "http://hl7.org/fhir/uv/sdc/CodeSystem/CSPHQ9")!,
                code: "Several-days"
            )
        ),
        .init(
            id: "2",
            title: "More than half the days",
            fhirCoding: .init(
                system: URL(string: "http://hl7.org/fhir/uv/sdc/CodeSystem/CSPHQ9")!,
                code: "More than half the days"
            )
        ),
        .init(
            id: "3",
            title: "Nearly every day",
            fhirCoding: .init(
                system: URL(string: "http://hl7.org/fhir/uv/sdc/CodeSystem/CSPHQ9")!,
                code: "Nearly every day"
            )
        )
    ]
}
