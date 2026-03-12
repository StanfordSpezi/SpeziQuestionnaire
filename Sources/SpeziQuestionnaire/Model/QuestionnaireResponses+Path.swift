//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Algorithms


extension QuestionnaireResponses {
    public enum ResponsePathComponent: Hashable, CustomStringConvertible, Sendable {
        case task(Questionnaire.Task.ID)
        case choiceOption(Questionnaire.Task.Kind.ChoiceConfig.Option.ID)
        
        fileprivate enum Kind: Equatable {
            /// A path (component) that, when evaluated, points to a container of multiple responses
            /// (i.e., a ``QuestionnaireResponses/Responses`` instance).
            case responsesContainer
            /// A path (component) that, when evaluated, points to a specific single ``QuestionnaireResponses/Response`` value.
            case singleResponse
        }
        
        public var description: String {
            switch self {
            case .task(let taskId):
                "task(\(taskId))"
            case .choiceOption(let optionId):
                "choiceOption(\(optionId))"
            }
        }
    }
    
    /// A path to a specific responses container within the questionnaire.
    public struct ResponsesPath: Hashable, RandomAccessCollection, Sendable {
        let components: [ResponsePathComponent]
        
        public var startIndex: Int {
            components.startIndex
        }
        public var endIndex: Int {
            components.endIndex
        }
        
        init() {
            self.init(EmptyCollection())
        }
        
        fileprivate init(_ path: some Collection<ResponsePathComponent>) {
            precondition(QuestionnaireResponses.validate(path: path) == .responsesContainer)
            components = Array(path)
        }
        
        func appending(taskId: Questionnaire.Task.ID) -> ResponsePath {
            ResponsePath(chain(components, CollectionOfOne(.task(taskId))))
        }
        
        func appending(_ other: ResponsesPath) -> ResponsesPath {
            ResponsesPath(chain(components, other))
        }
        
        public subscript(position: Int) -> ResponsePathComponent {
            components[position]
        }
    }
    
    
    /// A path to a specific response within the questionnaire.
    ///
    /// For a response to a regular task, the path only has a single component: the path's id.
    /// For a response to a follow-up question that is nested within a task, the path consists of the parent task's id and the choice option id.
    public struct ResponsePath: Hashable, RandomAccessCollection, Sendable {
        let components: [ResponsePathComponent]
        
        public var startIndex: Int {
            components.startIndex
        }
        public var endIndex: Int {
            components.endIndex
        }
        
        init(taskId: Questionnaire.Task.ID) {
            self.init(CollectionOfOne(.task(taskId)))
        }
        
        fileprivate init(_ path: some Collection<ResponsePathComponent>) {
            precondition(QuestionnaireResponses.validate(path: path) == .singleResponse)
            components = Array(path)
        }
        
        func appending(choiceOption optionId: Questionnaire.Task.Kind.ChoiceConfig.Option.ID) -> ResponsesPath {
            ResponsesPath(chain(components, CollectionOfOne(.choiceOption(optionId))))
        }
        
        public subscript(position: Int) -> ResponsePathComponent {
            components[position]
        }
    }
    
    
    private static func validate(path: some Collection<ResponsePathComponent>) -> ResponsePathComponent.Kind {
        func imp(
            current: ResponsePathComponent.Kind,
            rest: some Collection<ResponsePathComponent>
        ) -> ResponsePathComponent.Kind {
            switch (current, rest.first) {
            case (_, .none):
                return current
            case (.responsesContainer, .some(.task)):
                // we're at a responses container, and are now entering it, for some specific task
                return imp(current: .singleResponse, rest: rest.dropFirst())
            case (.singleResponse, .some(.choiceOption)):
                // we're within a single response, and are now entering its nested responses, for some choice option
                // NOTE: this only is valid if the single response is in fact a choice task, but that's not being validated here
                // (maybe it should?)
                return imp(current: .responsesContainer, rest: rest.dropFirst())
            case (.responsesContainer, .some(.choiceOption)):
                // we're in a responses container (which is a task -> Response mapping),
                // and indexing into this with a choice option is invalid
                preconditionFailure("Invalid path: choiceOption can only be used within a task! (\(Array(path)))")
            case (.singleResponse, .some(.task)):
                // we're within a single response, and are now trying to index into its nested responses, but are doing so using a task id, which is not allowed
                preconditionFailure("Invalid path: task can only be used within a responses container! (\(Array(path)))")
            }
        }
        return imp(current: .responsesContainer, rest: path)
    }
}
