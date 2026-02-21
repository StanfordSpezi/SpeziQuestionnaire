//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable missing_docs

public import Observation


/// Stores and manages responses to a questionnaire.
@Observable
public final class QuestionnaireResponses {
    /// The responses object's variant.
    ///
    /// There are two kinds of ``QuestionnaireResponses`` instances:
    /// 1. Root-level:
    ///     Owns a ``Responses`` object, which contains all responses collected for a questionnaire.
    /// 2. Nested/Inner-level:
    ///     Provides a scoped view into another ``QuestionnaireResponses`` instance.
    ///     In this case, the variant carries, in addition to the parent instance, a ``ResponsesPath`` connecting the current instance to its parent.
    ///     This is used when dealing with nested questions.
    ///     For example, a ``QuestionnaireResponses`` in
    ///
    /// This approach (of having the root/nested variant) is used to provide a common interface for accessing task responses,
    /// regardless of whether they are top-level tasks, or nested within some other response.
    /// In both cases, we can simply inject a ``QuestionnaireResponses`` instance into the SwiftUI view hierarchy,
    /// and the ``QuestionnaireSectionView`` will be able to work with it.
    ///
    /// Additionally, this approach allows us to have the type work correctly with the `Observation` framework, which is required for SwiftUI to properly trigger view updates.
    enum Variant {
        /// The root ``QuestionnaireResponses`` instance, which stores all responses.
        case root(Responses)
        /// A view into another ``QuestionnaireResponses`` instances, scoped to see only the responses at a specific path.
        case view(parent: QuestionnaireResponses, pathFromParent: ResponsesPath)
    }
    
    /// The questionnaire from which these responses were collected.
    public let questionnaire: Questionnaire
    
    private(set) var _variant: Variant { // swiftlint:disable:this identifier_name
        didSet {
            switch (oldValue, _variant) {
            case (.root, .root), (.view, .view):
                // ok
                break
            case (.root, .view), (.view, .root):
                preconditionFailure("Detected invalid variant kind change in \(Self.self)")
            }
            switch _variant {
            case .root(let responses):
                let sanitized = responses.sanitized() ?? Responses()
                if sanitized != responses {
                    _variant = .root(sanitized)
                }
            case .view:
                break
            }
        }
    }
    
    private var root: QuestionnaireResponses {
        switch _variant {
        case .root:
            self
        case .view(let parent, pathFromParent: _):
            parent.root
        }
    }
    
    private var pathFromParent: ResponsesPath {
        switch _variant {
        case .root:
            ResponsesPath()
        case .view(parent: _, let pathFromParent):
            pathFromParent
        }
    }
    
    var pathFromRoot: ResponsesPath {
        switch _variant {
        case .root:
            ResponsesPath()
        case let .view(parent, pathFromParent):
            parent.pathFromRoot.appending(pathFromParent)
        }
    }
    
    public internal(set) var responses: Responses {
        get {
            switch _variant {
            case .root(let responses):
                responses
            case let .view(parent, pathFromParent):
                parent.responses[pathFromParent]
            }
        }
        set {
            switch _variant {
            case .root:
                _variant = .root(newValue)
            case let .view(parent, pathFromParent):
                parent.responses[pathFromParent] = newValue
            }
        }
    }
    
    init(questionnaire: Questionnaire) {
        self.questionnaire = questionnaire
        _variant = .root(Responses())
    }
    
    private init(parent: QuestionnaireResponses, pathFromParent: ResponsesPath) {
        questionnaire = parent.questionnaire
        _variant = .view(parent: parent, pathFromParent: pathFromParent)
    }
    
    
    func view(appending path: ResponsesPath) -> Self {
        Self(parent: self.root, pathFromParent: path)
    }
}


// MARK: Completeness

extension QuestionnaireResponses {
    func hasResponse(for task: Questionnaire.Task) -> Bool {
        switch task.kind {
        case .instructional:
            // instructional tasks never collect a response; they are always considered as being complete.
            true
        case .boolean, .choice, .freeText, .dateTime, .numeric, .fileAttachment:
            responses[task.id].value != .none
        }
    }
    
    
    func isMissingResponse(for task: Questionnaire.Task) -> Bool {
        !task.isOptional && shouldEnable(task: task) && !hasResponse(for: task)
    }
    
    func isMissingResponses(in section: Questionnaire.Section) -> Bool {
        section.tasks.contains { task in
            isMissingResponse(for: task)
        }
    }
    
    /// Determines whether the questionnaire is currently complete in the specified section.
    ///
    /// This function returns `true` iff all currently enabled required tasks have responses, and none of these responses are invalid.
    func isComplete(in section: Questionnaire.Section) -> Bool {
        !isMissingResponses(in: section) && section.tasks.allSatisfy { task in
            // either the task is disabled, or its response is valid.
            !shouldEnable(task: task) || validateResponse(for: task) == .ok
        }
    }
    
    /// Returns the first task in the section that currently prevents the section from being complete.
    ///
    /// For example, if a required task is missing a response or its response is invalid, it would get returned.
    func firstTaskPreventingCompletion(of section: Questionnaire.Section) -> Questionnaire.Task? {
        section.tasks.first { task in
            isMissingResponse(for: task) || validateResponse(for: task) != .ok
        }
    }
    
    /// Determines the next section, taking into account the current responses and task conditions.
    ///
    /// This function automatically skips empty sections, if e.g. a section doesn't contain any tasks, or all of the section's tasks should be skipped, because of their conditions.
    func nextSection(
        after section: Questionnaire.Section,
        in sections: some Collection<Questionnaire.Section>
    ) -> Questionnaire.Section? {
        guard let sectionIdx = sections.firstIndex(of: section) else {
            return nil
        }
        let remainingSections = sections[sectionIdx...].dropFirst()
        return remainingSections.first { section in
            section.tasks.contains { shouldEnable(task: $0) }
        }
    }
}


extension QuestionnaireResponses {
    /// Removes all responses that were collected for tasks that are currently disabled.
    ///
    /// When collecting resopnses to a questionnaire, whether a task `Y` is enabled or disabled can change even after a response has already been collected for that task,
    /// if the user goes back to a previous task `X` and changes the response there, since `Y`'s ``Questionnaire/Task/enabledCondition`` might depend on the `X`'s response.
    ///
    /// While answering a questionnaire, the ``QuestionnaireResponses`` will keep the response collected for task `Y`, even if a change to `X` would mean that `Y` is no longer enabled;
    /// this ensures that the user doesn't have to re-enter potentially large amounts of data if they (accidentally) change an earlier task's response.
    ///
    /// This function goes through the entire questionnaire, in order, re-evaluates each task's ``Questionnaire/Task/enabledCondition``, and removes all responses whose task's
    /// are no longer enabled.
    func purgeResponsesToDisabledTasks() {
        _purgeResponsesToDisabledTasks(questionnaire.sections.lazy.flatMap(\.tasks))
    }
    
    private func _purgeResponsesToDisabledTasks(_ allTasks: some Sequence<Questionnaire.Task>) {
        for task in allTasks {
            guard shouldEnable(task: task) else {
                responses[task.id] = .init(value: .none)
                continue
            }
            if !responses[task.id].nestedResponses.isEmpty && task.kind.followUpTasks.isEmpty {
                // Found nested responses for a task that doesn't have nested questions
                responses[task.id].nestedResponses.removeAll()
            }
            switch task.kind {
            case .choice(let config):
                for option in config.options {
                    self
                        .view(appending: ResponsesPath().appending(taskId: task.id).appending(choiceOption: option.id))
                        ._purgeResponsesToDisabledTasks(task.kind.followUpTasks)
                }
            case .instructional:
                responses[task.id] = .init(value: .none)
            case .boolean, .freeText, .dateTime, .numeric, .fileAttachment:
                break
            }
        }
    }
}
