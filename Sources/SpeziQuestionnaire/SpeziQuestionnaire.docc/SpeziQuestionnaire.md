# ``SpeziQuestionnaire``

<!--
#
# This source file is part of the Stanford Spezi open source project
#
# SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
#
# SPDX-License-Identifier: MIT
#       
-->

Enables apps to display and collect responses from FHIR questionnaires.

## Overview

The Spezi Questionnaire package enables [FHIR Questionnaires](http://hl7.org/fhir/R4/questionnaire.html) to be displayed in your Spezi application.

@Row {
    @Column {
        @Image(source: "Overview", alt: "Screenshot showing an FHIR Questionnaire rendered using the Questionnaire module."){
            An FHIR Questionnaire is rendered using the ``QuestionnaireView``.
        }
    }
}


## Setup

You need to add the Spezi Questionnaire Swift package to
[your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) or
[Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).

> Important: If your application is not yet configured to use Spezi, follow the [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/initial-setup) and set up the core Spezi infrastructure.

## Example

In the following example, we create a SwiftUI view with a button that displays a ``QuestionnaireSheet`` for answering the [GAD-7](https://en.wikipedia.org/wiki/Generalized_Anxiety_Disorder_7) questionnaire.

```swift
import SpeziQuestionnaire
import SwiftUI


struct GAS7QuestionnaireView: View {
    @State var activeQuestionnaire: Questionnaire?

    var body: some View {
        Button("Answer GAD-7") {
            activeQuestionnaire = .gad7
        }
        .sheet(item: $activeQuestionnaire) { item in
            QuestionnaireSheet(questionnaire: item) { result in
                switch result {
                case .completed(let resopnses):
                    // ... save the response to your data store
                case .cancelled:
                    break
                }
            }
        }
    }
}
```

## Topics

### Questionnaire Definitions
- ``Questionnaire``
- ``QuestionnaireResponses``

### UI
- ``QuestionnaireSheet``
            
