# ``SpeziQuestionnaireFHIR``

<!--
#
# This source file is part of the Stanford Spezi open source project
#
# SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
#
# SPDX-License-Identifier: MIT
#       
-->

Use FHIR questionnaires in your iOS app


## Discussion

The `SpeziQuestionnaireFHIR` target extends the `SpeziQuestionnaire` target, adding FHIR support:
- Convert a [FHIR R4 Questionnaire](https://hl7.org/fhir/R4/questionnaire.html) into a Spezi [`Questionnaire`](https://swiftpackageindex.com/stanfordspezi/speziquestionnaire/documentation/speziquestionnaire/questionnaire)
    - support for partially and fully custom question kinds using `item-control` and FHIR extensions
- Convert a Spezi [`QuestionnaireResponses`](https://swiftpackageindex.com/stanfordspezi/speziquestionnaire/documentation/speziquestionnaire/questionnaireresponses) instance into a [FHIR R4 QuestionnaireResponse](https://hl7.org/fhir/R4/questionnaireresponse.html)


### Supported Question Kinds

All of SpeziQuestionnaire's builtin question kinds are supported when importing a FHIR R4 questionnaire.

This includes the Annotate Image question kind; see below for an example FHIR R4 JSON definition of a question asking the user to highlight, on a bodymap image, the areas where they feel pain or stiffness:
```json
{
  "linkId": "pain-leg",
  "text": "In each leg, where do you feel pain?",
  "type": "attachment",
  "extension": [
    {
      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
      "valueCodeableConcept": {
        "coding": [
          {
            "system": "http://spezi.stanford.edu/fhir/CodeSystem/questionnaire-item-control",
            "code": "annotate-image"
          }
        ]
      }
    },
    {
      "url": "http://spezi.stanford.edu/fhir/CodeSystem/questionnaire-item-control/annotate-image/input-image",
      "valueString": "bodymap.png"
    },
    {
      "url": "http://spezi.stanford.edu/fhir/CodeSystem/questionnaire-item-control/annotate-image/region",
      "extension": [
        {
          "url": "label",
          "valueString": "Pain"
        },
        {
          "url": "color",
          "valueString": "red"
        }
      ]
    },
    {
      "url": "http://spezi.stanford.edu/fhir/CodeSystem/questionnaire-item-control/annotate-image/region",
      "extension": [
        {
          "url": "label",
          "valueString": "Stiffness"
        },
        {
          "url": "color",
          "valueString": "blue"
        }
      ]
    }
  ]
}
```


## Topics

### FHIR ↔ SpeziQuestionnaire Conversion
- ``SpeziQuestionnaire/Questionnaire/init(_:using:)``
- ``ModelsR4/QuestionnaireResponse/init(_:)``

### Supporting Types
- ``QuestionKindDefinitionWithFHIRSupport``
- ``QuestionKindDefinitionWithFHIRDecodingSupport``
- ``QuestionKindDefinitionWithFHIREncodingSupport``
- ``SpeziQuestionnaire/QuestionnaireResponses/CustomResponseValueProtocolWithFHIRSupport``
