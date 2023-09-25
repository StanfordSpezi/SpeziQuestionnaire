<!--

This source file is part of the Stanford Spezi open-source project.

SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
  
-->

# Spezi Questionnaire

[![Build and Test](https://github.com/StanfordSpezi/SpeziQuestionnaire/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/StanfordSpezi/SpeziQuestionnaire/actions/workflows/build-and-test.yml)
[![codecov](https://codecov.io/gh/StanfordSpezi/SpeziQuestionnaire/branch/main/graph/badge.svg?token=pJpdcIATps)](https://codecov.io/gh/StanfordSpezi/SpeziQuestionnaire)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7706903.svg)](https://doi.org/10.5281/zenodo.7706903)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStanfordSpezi%2FSpeziQuestionnaire%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/StanfordSpezi/SpeziQuestionnaire)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStanfordSpezi%2FSpeziQuestionnaire%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/StanfordSpezi/SpeziQuestionnaire)

Module that enables apps to display and collect responses from [FHIR Questionnaires](http://hl7.org/fhir/R4/questionnaire.html).

## Overview

The Spezi Questionnaire package enables [FHIR Questionnaires](http://hl7.org/fhir/R4/questionnaire.html) to be displayed in your Spezi application.

Questionnaires are displayed using [ResearchKit](https://github.com/ResearchKit/ResearchKit) and the [ResearchKitOnFHIR](https://github.com/StanfordBDHG/ResearchKitOnFHIR) package.

| ![Screenshot showing a Questionnaire rendered using the Spezi Questionnaire module.](Sources/SpeziQuestionnaire/SpeziQuestionnaire.docc/Resources/Overview.png#gh-light-mode-only) ![Screenshot showing a Questionnaire rendered using the Spezi Questionnaire module.](Sources/SpeziQuestionnaire/SpeziQuestionnaire.docc/Resources/Overview-dark.png#gh-dark-mode-only) |
 |:---:|
 |[`QuestionnaireView`](https://swiftpackageindex.com/stanfordspezi/speziquestionnaire/documentation/speziquestionnaire/questionnaireview)|

## Setup

### 1. Add Spezi Questionnaire as a Dependency

You need to add the Spezi Questionnaire Swift package to
[your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#) or
[Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).

> [!IMPORTANT]
> If your application is not yet configured to use Spezi, follow the [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/setup) setup the core Spezi infrastructure.

### 2. Ensure that your Standard Conforms to the [`QuestionnaireConstraint`](https://swiftpackageindex.com/stanfordspezi/speziquestionnaire/documentation/speziquestionnaire/questionnaireconstraint) Protocol

In order to recieve responses from Questionnaires, the [`Standard`](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/standard) defined in your Configuration within your [`SpeziAppDelegate`](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/speziappdelegate) should conform to the [`QuestionnaireConstraint`](https://swiftpackageindex.com/stanfordspezi/speziquestionnaire/documentation/speziquestionnaire/questionnaireconstraint) protocol. 

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

The [`QuestionnaireDataSource`](https://swiftpackageindex.com/stanfordspezi/speziquestionnaire/documentation/speziquestionnaire/questionnairedatasource) component needs to be registered in a Spezi-based application using the [`configuration`](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/speziappdelegate/configuration) in a
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

In the following example, we create a SwiftUI view with a button that displays a sample questionnaire from the `FHIRQuestionnaires` package using [`QuestionnaireView`](https://swiftpackageindex.com/stanfordspezi/speziquestionnaire/documentation/speziquestionnaire/questionnaireview).

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
For more information, please refer to the [API documentation](https://swiftpackageindex.com/StanfordSpezi/SpeziQuestionnaire/documentation).


## The Spezi Template Application

The [Spezi Template Application](https://github.com/StanfordSpezi/SpeziTemplateApplication) provides a great starting point and example using the Spezi Questionnaire module.


## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.


## License

This project is licensed under the MIT License. See [Licenses](https://github.com/StanfordSpezi/SpeziQuestionnaire/tree/main/LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterLight.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterDark.png#gh-dark-mode-only)
