//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import Foundation
private import SpeziFoundation


extension Questionnaire {
    /// Controls when a task or other questionnaire component should be enabled.
    ///
    /// Conditions allow establishing dependencies between ``Task``s within a ``Questionnaire``,
    /// and can be used to conditionally ask additional questions, based on e.g. a user's response to some previous task.
    ///
    /// A condition belonging to a task may only reference other tasks that precede that task within the questionnaire.
    /// If a condition references a task that appears after the task to which it belongs, it always evaluates to `false`.
    ///
    /// Conditions referencing invalid ``Task``s always evaluate to `false`.
    ///
    /// Conditions are evaluated
    ///
    /// ## Topics
    ///
    /// ### Conditions
    /// - ``not(_:)``
    /// - ``any(_:)``
    /// - ``all(_:)``
    /// - ``none``
    /// - ``true``
    /// - ``false``
    /// - ``init(booleanLiteral:)``
    /// - ``hasResponse(taskId:)``
    /// - ``isMissingResponse(taskId:)``
    /// - ``responseValueComparison(taskId:operator:value:)``
    ///
    /// ### Supporting Types
    /// - ``ComparisonOperator``
    /// - ``Value``
    public indirect enum Condition: ExpressibleByBooleanLiteral, Sendable {
        /// A condition that is satisfied if `nested` is not satisfied.
        case not(_ nested: Condition)
        
        /// A condition that is satisfied if any of its contained conditions are satisfied..
        ///
        /// If there are no nested conditions, `any` evaluates to `false`.
        case any(Set<Condition>)
        
        /// A condition that is satisfied if all of its contained conditions are satisfied.
        ///
        /// If there are no nested conditions, `all` evaluates to `true`.
        case all(Set<Condition>)
        
        /// A condition that is satisfied if a response exists for the task at `taskPath`.
        ///
        /// This condition only checks whether a response exists; it does not take the task's optionality into account.
        /// (Use ``isMissingResponse(taskId:)`` instead if you need that.)
        ///
        /// - parameter taskId: The id of a task within the questionnaire.
        case hasResponse(taskId: Task.ID)
        
        /// A condition that is satisfied if a response is currently missing for the  task at `taskPath`.
        ///
        /// - Note: This is not the opposite of ``hasResponse(taskId:)``.
        ///     For an optional task that doesn't have a response, this would evaluate to `false` (because the task isn't required, the response isn't missing),
        ///     whereas ``hasResponse(taskId:)`` would also evaluate to `false`, since it only checks for the existence of a response.
        case isMissingResponse(taskId: Task.ID)
        
        /// A condition that compares a task's response to some value.
        ///
        /// - Note: Not all comparisons make sense for all question types.
        ///     If a response is compared against a value of a different type, or if the operator isn't applicable for the type, the condition evaluates to `false`.
        ///
        /// - parameter taskId: The id of the task whose response should be inspected.
        /// - parameter operator: The comparison operation
        /// - parameter value: The value against which the task's response should be compared
        case responseValueComparison(taskId: Task.ID, operator: ComparisonOperator, value: Value)
        
        
        /// Models https://hl7.org/fhir/valueset-questionnaire-enable-operator.html
        ///
        /// - Note: This enum intentionally does not implement the `exists` and `!=` operations.
        ///     Use ``Questionnaire/Condition/hasResponse(taskId:)``, and ``Questionnaire/Condition/not(_:)`` in combination with ``equal`` instead.
        public enum ComparisonOperator: Hashable, Sendable {
            /// True if whether at least one answer has a value that is equal to the enableWhen answer
            case equal
            /// True if at least one answer has a value that is less than the enableWhen answer
            case lessThan
            /// True if at least one answer has a value that is greater than the enableWhen answer
            case greaterThan
            /// True if at least one answer has a value that is less or equal to the enableWhen answer
            case lessThanOrEqual
            /// True if at least one answer has a value that is greater or equal to the enableWhen answer
            case greaterThanOrEqual
        }
        
        /// Value used in comparison conditions.
        public enum Value: Hashable, Sendable {
            case bool(Bool)
            case integer(Int)
            case decimal(Double)
            case string(String)
            case date(DateComponents)
            case SCMCOption(id: String)
        }
        
        /// The lack of a condition.
        ///
        /// Always evaluates to `true`.
        public static var none: Self {
            true
        }
        
        /// A `Condition` that is always true.
        public static var `true`: Self {
            true
        }
        
        /// A `Condition` that is always false.
        public static var `false`: Self {
            false
        }
        
        /// Creates a ``Condition`` that always evaluates to the specified boolean value.
        public init(booleanLiteral value: Bool) {
            self = value ? .all([]) : .any([])
        }
        
        /// Constructs a condition that is true iff two other conditions are true.
        public static func && (lhs: Self, rhs: Self) -> Self {
            .all([lhs, rhs])
        }
        
        /// Constructs a condition that is true iff either of other conditions is true.
        public static func || (lhs: Self, rhs: Self) -> Self {
            .any([lhs, rhs])
        }
        
        /// Negates a condition
        public static prefix func ! (rhs: Self) -> Self {
            .not(rhs)
        }
    }
}


extension Questionnaire.Condition: Hashable {
    /// Determines whether two conditions are semantically equivalent.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.simplified().isEqual(to: rhs.simplified())
    }
    
    private func isEqual(to other: Self) -> Bool {
        switch (self, other) {
        case let (.not(lhs), .not(rhs)):
            lhs.isEqual(to: rhs)
        case let (.any(lhs), .any(rhs)):
            Set(lhs) == Set(rhs)
        case let (.all(lhs), .all(rhs)):
            Set(lhs) == Set(rhs)
        case let (.hasResponse(lhs), .hasResponse(rhs)):
            lhs == rhs
        case let (.isMissingResponse(lhs), .isMissingResponse(rhs)):
            lhs == rhs
        case let (.responseValueComparison(lhsTask, lhsOp, lhsVal), .responseValueComparison(rhsTask, rhsOp, rhsVal)):
            lhsTask == rhsTask && lhsOp == rhsOp && lhsVal == rhsVal
        default:
            false
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch simplified() {
        case .not(let inner):
            hasher.combine(0)
            hasher.combine(inner)
        case .any(let inner):
            hasher.combine(1)
            hasher.combine(inner)
        case .all(let inner):
            hasher.combine(2)
            hasher.combine(inner)
        case .hasResponse(let taskId):
            hasher.combine(3)
            hasher.combine(taskId)
        case .isMissingResponse(let taskId):
            hasher.combine(4)
            hasher.combine(taskId)
        case let .responseValueComparison(taskId, `operator`, value):
            hasher.combine(5)
            hasher.combine(taskId)
            hasher.combine(`operator`)
            hasher.combine(value)
        }
    }
}


extension Questionnaire.Condition {
    mutating func simplify() {
        self = self.simplified()
    }
    
    func simplified() -> Self { // swiftlint:disable:this cyclomatic_complexity
        switch self {
        case .not(let inner):
            switch inner.simplified() {
            case .not(let inner):
                return inner
            case true:
                return false
            case false:
                return true
            case let inner:
                return .not(inner)
            }
        case .any(let inner):
            let inner: Set<Self> = inner.compactMapIntoSet {
                switch $0.simplified() {
                case false: nil
                case let cond: cond
                }
            }
            if inner.isEmpty {
                return false
            } else if inner.contains(true) {
                return true
            } else {
                return .any(inner)
            }
        case .all(let inner):
            let inner: Set<Self> = inner.compactMapIntoSet {
                switch $0.simplified() {
                case true: nil
                case let cond: cond
                }
            }
            if inner.isEmpty {
                return true
            } else if inner.contains(false) {
                return false
            } else {
                return .all(inner)
            }
        case .hasResponse, .isMissingResponse, .responseValueComparison:
            return self
        }
    }
}
