//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ModelsR4
import Spezi
import SwiftUI

public class WalkTestDataSource: Component, ObservableObject, ObservableObjectProvider {
    @StandardActor var standard: any WalkTestConstraint
    
    public init() {}
    
    public func add(_ response: WalkTestResponse) async {
        await standard.add(response: response)
    }
}
