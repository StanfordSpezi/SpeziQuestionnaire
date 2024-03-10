# ``SpeziTimedWalkTest``

<!--
#
# This source file is part of the Stanford Spezi open source project
#
# SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
#
# SPDX-License-Identifier: MIT
#       
-->

Enables apps to conduct an timed walk test.

## Overview

The `SpeziTimedWalkTest` target in the Spezi Questinnaire package enables the conduction of timed walk tests in an app,

@Row {
    @Column {
        @Image(source: "GetReady", alt: "Get ready screen of the TimedWalkTestView defined by a TimedWalkTest."){
            Get ready screen of the ``TimedWalkTestView`` defined by a ``TimedWalkTest``.
        }
    }
    @Column {
        @Image(source: "TimedWalkTest", alt: "The TimedWalkTestView used to conduct a TimedWalkTest."){
            The ``TimedWalkTestView`` used to conduct a ``TimedWalkTest``.
        }
    }
    @Column {
        @Image(source: "Result", alt: "Display of the result of the TimedWalkTestView encoded in a TimedWalkTestResult."){
            Display of the result of the ``TimedWalkTestView`` encoded in a ``TimedWalkTestResult``
        }
    }
}
            
## Setup

You need to add the Spezi Questionnaire Swift package to
[your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) or
[Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).

> Important: If your application is not yet configured to use Spezi, follow the [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/initial-setup) and set up the core Spezi infrastructure.

## Example

In the following example, we create a SwiftUI view with a button that displays a the timed walk test view defined by the ``TimedWalkTest`` using the ``TimedWalkTestView``.

```swift
import SpeziTimedWalkTest
import SwiftUI


struct ExampleView: View {
    @State var displayWalkTest = false

    
    private var timedWalkTest: TimedWalkTest {
        TimedWalkTest(walkTime: 5)
    }
    
    var body: some View {
        Button("Display Walk Test") {
            displayWalkTest.toggle()
        }
            .sheet(isPresented: $displayWalkTest) {
                NavigationStack {
                    TimedWalkTestView(timedWalkTest: timedWalkTest) { result in
                        switch result {
                        case .completed:
                            // ...
                        case .failed:
                            // ...
                        case .cancelled:
                            // ...
                        }
                        displayWalkTest = false
                    }
                }
            }
    }
}
```

## Topics

### Timed Walk Test

- ``TimedWalkTest``
- ``TimedWalkTestView``
- ``TimedWalkTestViewResult``
- ``TimedWalkTestResult``
- ``TimedWalkTestError``
