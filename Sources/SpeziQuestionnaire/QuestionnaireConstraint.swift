//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import ModelsR4

public protocol QuestionnaireConstraint: Standard {
    func add(_ response: QuestionnaireResponse) async
}
