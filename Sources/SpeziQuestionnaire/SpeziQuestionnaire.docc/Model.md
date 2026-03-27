# Data Structures

<!--
#
# This source file is part of the Stanford Spezi open source project
#
# SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
#
# SPDX-License-Identifier: MIT
#       
-->

Reusable Questionnaire Definition

## Overview

A questionnaire.

## Overview

Questionnaires consist of a sequence of ``Section``s, each of which contains a list of ``Task``s.
When using the ``QuestionnaireSheet`` to answer a questionnaire, each section is displayed as a separate page on a `NavigationStack`.

### Interoperability

The `Questionnaire` type is compatible with  [FHIR R4 questionnaires](https://hl7.org/fhir/R4/questionnaire.html)


## Topics

### Initializers
- ``init(metadata:sections:)``

### Instance Properties
- ``id``
- ``metadata``
- ``sections``

### Supporting Types
- ``Metadata``
- ``Section``
- ``Task``
