//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ModelsR4


#if compiler(<6)
extension ModelsR4.Identifier: Swift.Identifiable {}
#else
extension Identifier: @retroactive Identifiable {}
#endif
