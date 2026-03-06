//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


struct ViewTitleConfig: Sendable {
    fileprivate let title: Text
    fileprivate let subtitle: Text?
    
    init(title: some StringProtocol, subtitle: (some StringProtocol)? = String?.none) {
        self.title = Text(title)
        self.subtitle = subtitle.map { Text($0) }
    }
    
    init(title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil) {
        self.title = Text(title)
        self.subtitle = subtitle.map { Text($0) }
    }
}


extension View {
    @ViewBuilder
    func navigationTitle(_ config: ViewTitleConfig?) -> some View {
        if let config {
            let withTitle = self.navigationTitle(config.title)
            if let subtitle = config.subtitle, #available(iOS 26, *) {
                withTitle.navigationSubtitle(subtitle)
            } else {
                withTitle
            }
        } else {
            self
        }
    }
}


extension View {
//    @ViewBuilder
//    @_disfavoredOverload
//    nonisolated func navigationTitle(_ title: (some StringProtocol)?) -> some View {
//        if let title {
//            self.navigationTitle(title)
//        } else {
//            self
//        }
//    }
//    
//    @ViewBuilder
//    @_disfavoredOverload
//    nonisolated func navigationSubtitle(_ subtitle: (some StringProtocol)?) -> some View {
//        if let subtitle, #available(iOS 26, *) {
//            self.navigationSubtitle(subtitle)
//        } else {
//            self
//        }
//    }
}
