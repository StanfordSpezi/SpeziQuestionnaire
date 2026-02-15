//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


extension Questionnaire {
    // https://www.apa.org/depression-guideline/patient-health-questionnaire.pdf
    public static let phq9 = Self(
        metadata: .init(
            id: "phq9",
            url: nil,
            title: "Patient Health Questionnaire-9",
            explainer: ""
        ),
        sections: [
            .init(id: "main", tasks: [
                .init(
                    id: "instructions",
                    title: "",
                    kind: .instructional("Over the **last 2 weeks**, how often have you been bothered by any of the following problems?")
                ),
                .init(
                    id: "q1",
                    title: "Little interest or pleasure in doing things",
                    kind: .singleChoice(options: .phq9Options)
                ),
                .init(
                    id: "q2",
                    title: "Feeling down, depressed, or hopeless",
                    kind: .singleChoice(options: .phq9Options)
                ),
                .init(
                    id: "q3",
                    title: "Trouble falling or staying asleep, or sleeping too much",
                    kind: .singleChoice(options: .phq9Options)
                ),
                .init(
                    id: "q4",
                    title: "Feeling tired or having little energy",
                    kind: .singleChoice(options: .phq9Options)
                ),
                .init(
                    id: "q5",
                    title: "Poor appetite or overeating",
                    kind: .singleChoice(options: .phq9Options)
                ),
                .init(
                    id: "q6",
                    title: "Feeling bad about yourself — or that you are a failure or have let yourself or your family down",
                    kind: .singleChoice(options: .phq9Options)
                ),
                .init(
                    id: "q7",
                    title: "Trouble concentrating on things, such as reading the newspaper or watching television",
                    kind: .singleChoice(options: .phq9Options)
                ),
                .init(
                    id: "q8",
                    title: "Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual",
                    kind: .singleChoice(options: .phq9Options)
                ),
                .init(
                    id: "q9",
                    title: "Thoughts that you would be better off dead or of hurting yourself in some way",
                    kind: .singleChoice(options: .phq9Options)
                )
            ])
        ]
    )
}

extension [Questionnaire.Task.SCMCOption] {
    fileprivate static let phq9Options: Self = [
        .init(id: "0", title: "Not at all"),
        .init(id: "1", title: "Several days"),
        .init(id: "2", title: "More than half the days"),
        .init(id: "3", title: "Nearly every day")
    ]
}
