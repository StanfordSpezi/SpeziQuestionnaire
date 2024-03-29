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

Enables apps to display and collect responses from [HL7® FHIR® questionnaires](http://hl7.org/fhir/R4/questionnaire.html).


## Overview

The Spezi Questionnaire package enables [HL7® FHIR® Questionnaires](http://hl7.org/fhir/R4/questionnaire.html) to be displayed in your Spezi application.

Questionnaires are displayed using [ResearchKit](https://github.com/ResearchKit/ResearchKit) and the [ResearchKitOnFHIR](https://github.com/StanfordBDHG/ResearchKitOnFHIR) package.

| ![Screenshot showing a Questionnaire rendered using the Spezi Questionnaire module.](Sources/SpeziQuestionnaire/SpeziQuestionnaire.docc/Resources/Overview.png#gh-light-mode-only) ![Screenshot showing a Questionnaire rendered using the Spezi Questionnaire module.](Sources/SpeziQuestionnaire/SpeziQuestionnaire.docc/Resources/Overview~dark.png#gh-dark-mode-only) |
 |:---:|
 |An HL7® FHIR® Questionnaire is rendered using the [`QuestionnaireView`](https://swiftpackageindex.com/stanfordspezi/speziquestionnaire/documentation/speziquestionnaire/questionnaireview)|


## Setup

You need to add the Spezi Questionnaire Swift package to
[your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#) or
[Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).

> [!IMPORTANT]
> If your application is not yet configured to use Spezi, follow the [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/initial-setup) and set up the core Spezi infrastructure.

## Example

In the following example, we create a SwiftUI view with a button that displays a sample questionnaire from the `FHIRQuestionnaires` package using [`QuestionnaireView`](https://swiftpackageindex.com/stanfordspezi/speziquestionnaire/documentation/speziquestionnaire/questionnaireview).

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
For more information, please refer to the [API documentation](https://swiftpackageindex.com/StanfordSpezi/SpeziQuestionnaire/documentation).


## The Spezi Template Application

The [Spezi Template Application](https://github.com/StanfordSpezi/SpeziTemplateApplication) provides a great starting point and example using the Spezi Questionnaire module.


## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.

## Notices

FHIR is a registered trademark of Health Level Seven International.

## License

This project is licensed under the MIT License. See [Licenses](https://github.com/StanfordSpezi/SpeziQuestionnaire/tree/main/LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterLight.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterDark.png#gh-dark-mode-only)
