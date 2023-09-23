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

Module that enables apps to display and collect responses from [FHIR Questionnaires](http://hl7.org/fhir/R4/questionnaire.html).

## Overview

The Spezi Questionnaire package enables [FHIR Questionnaires](http://hl7.org/fhir/R4/questionnaire.html) to be displayed in your Spezi application.

Questionnaires are displayed using [ResearchKit](https://github.com/ResearchKit/ResearchKit) and the [ResearchKitOnFHIR](https://github.com/StanfordBDHG/ResearchKitOnFHIR) package.

@Row {
    @Column {
        @Image(source: "Overview", alt: "Screenshot showing a FHIR Questionnaire rendered using the Questionnaire module."){
            A FHIR Questionnaire rendered using ``QuestionnaireView``.
    }
}

## Setup

### 1. Add Spezi Questionnaire as a Dependency

You need to add the Spezi Questionnaire Swift package to
[your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#) or
[Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).

> Important: If your application is not yet configured to use Spezi, follow the [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/setup) setup the core Spezi infrastructure.

### 2. Ensure that your Standard Conforms to the ``QuestionnaireConstraint`` Protocol

In order to recieve responses from Questionnaires, the [`Standard`](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/standard) defined in your Configuration within your [`SpeziAppDelegate`](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/speziappdelegate) should conform to the ``QuestionnaireConstraint`` protocol. 

Below, we create an `ExampleStandard` and extend it to implement an `add` function which receives the result of our questionnaire as a [FHIR QuestionnaireResponse](http://hl7.org/fhir/R4/questionnaireresponse.html). In this simple example, completing a survey increases the surveyResponseCount.

```swift
/// An example Standard used for the configuration.
actor ExampleStandard: Standard, ObservableObject, ObservableObjectProvider {
    @Published @MainActor var surveyResponseCount: Int = 0
}


extension ExampleStandard: QuestionnaireConstraint {
    func add(response: ModelsR4.QuestionnaireResponse) async {
        surveyResponseCount += 1
        }
    }
}
```

> Tip: You can learn more about a [`Standard` in the Spezi documentation](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/standard)

### 3. Register the Questionnaire Data Source Component

The ``QuestionnaireDataSource`` component needs to be registered in a Spezi-based application using the [`configuration`](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/speziappdelegate/configuration) in a
 [`SpeziAppDelegate`](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/speziappdelegate):

```swift
class ExampleAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: ExampleStandard()) {
            QuestionnaireDataSource()
            // ...
        }
    }
}
```

> Tip: You can learn more about a [`Component` in the Spezi documentation](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/component).

## Example

In the following example, we create a SwiftUI view with a button that displays a sample questionnaire from the `FHIRQuestionnaires` package using ``QuestionnaireView``.

```swift
import FHIRQuestionnaires
import SpeziQuestionnaire
import SwiftUI


struct QuestionnaireView: View {
    @EnvironmentObject var standard: ExampleStandard
    @State var displayQuestionnaire = false
    
    
    var body: some View {
        Button("Display Questionnaire") {
            displayQuestionnaire.toggle()
        }
            .sheet(isPresented: $displayQuestionnaire) {
                QuestionnaireView(questionnaire: Questionnaire.gcs)
            }
    }
}
```

## Topics

- ``QuestionnaireConstraint``
- ``QuestionnaireDataSource``
- ``QuestionnaireView``
