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

Questionnaires are displayed using [ResearchKit](https://github.com/ResearchKit/ResearchKit) and the [ResearchKitOnFHIR](https://github.com/StanfordBDHG/ResearchKitOnFHIR) package.

@Row {
    @Column {
        @Image(source: "Overview", alt: "Screenshot showing an FHIR Questionnaire rendered using the Questionnaire module."){
            An FHIR Questionnaire is rendered using the ``QuestionnaireView``.
        }
    }
}
            
## Setup

You need to add the Spezi Questionnaire Swift package to
[your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#) or
[Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).

> Important: If your application is not yet configured to use Spezi, follow the [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/initial-setup) and set up the core Spezi infrastructure.

## Example

In the following example, we create a SwiftUI view with a button that displays a sample questionnaire from the `FHIRQuestionnaires` package using ``QuestionnaireView``.

```swift
import FHIRQuestionnaires
import SpeziQuestionnaire
import SwiftUI


struct ExampleQuestionnaireView: View {
    @State var displayQuestionnaire = false


    var body: some View {
        Button("Display Questionnaire") {
            displayQuestionnaire.toggle()
        }
            .sheet(isPresented: $displayQuestionnaire) {
                QuestionnaireView(
                    questionnaire: Questionnaire.gcs
                ) { result in
                    guard case let .completed(response) = result else {
                        return // user cancelled
                    }

                    // ... save the FHIR response to your data store
                }
            }
    }
}
```

## Topics

### Questionnaire

- ``QuestionnaireView``
- ``QuestionnaireResult``
            
