//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import SpeziQuestionnaire


extension Questionnaire {
    /// Generalized Anxiety Disorder 7 Questionnaire
    ///
    /// - SeeAlso: https://adaa.org/sites/default/files/GAD-7_Anxiety-updated_0.pdf
    public static let gad7 = Self(
        metadata: .init(
            id: "gad7",
            url: nil,
            title: "GAD-7 Anxiety",
            explainer: ""
        ),
        sections: [
            .init(id: "main", tasks: [
                .init(
                    id: "instructions",
                    title: "",
                    kind: .instructional("Over the **last 2 weeks**, how often have you been bothered by of the following problems?")
                ),
                .init(
                    id: "q1",
                    title: "Feeling nervous, anxious, or on edge",
                    kind: .choice(.init(options: .gad7Options, allowsMultipleSelection: false))
                ),
                .init(
                    id: "q2",
                    title: "Not being able to stop or control worrying",
                    kind: .choice(.init(options: .gad7Options, allowsMultipleSelection: false))
                ),
                .init(
                    id: "q3",
                    title: "Worrying too much about different things",
                    kind: .choice(.init(options: .gad7Options, allowsMultipleSelection: false))
                ),
                .init(
                    id: "q4",
                    title: "Trouble relaxing",
                    kind: .choice(.init(options: .gad7Options, allowsMultipleSelection: false))
                ),
                .init(
                    id: "q5",
                    title: "Being so restless that it is hard to sit still",
                    kind: .choice(.init(options: .gad7Options, allowsMultipleSelection: false))
                ),
                .init(
                    id: "q6",
                    title: "Becoming easily annoyed or irritable",
                    kind: .choice(.init(options: .gad7Options, allowsMultipleSelection: false))
                ),
                .init(
                    id: "q7",
                    title: "Feeling afraid, as if something awful might happen",
                    kind: .choice(.init(options: .gad7Options, allowsMultipleSelection: false))
                )
            ])
        ]
    )
}

extension [Questionnaire.Task.Kind.ChoiceConfig.Option] {
    fileprivate static let gad7Options: Self = [
        .init(id: "0", title: "Not at all"),
        .init(id: "1", title: "Several days"),
        .init(id: "2", title: "More than half the days"),
        .init(id: "3", title: "Nearly every day")
    ]
}
