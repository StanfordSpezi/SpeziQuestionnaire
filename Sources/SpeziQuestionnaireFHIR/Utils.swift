//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ModelsR4


extension Decimal {
    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
    
    var intValue: Int {
        NSDecimalNumber(decimal: self).intValue
    }
}


extension FHIRDate {
//    /// Converts a `FHIRDate` to a `Date` with the time set to the start of day in the user's current time zone.
//    /// If either the month or day are not provided, we will assume they are the first.
//    /// - Returns: An optional `Date`
//    var asDateAtStartOfDayWithDefaults: Date? {
//        let dateComponents = DateComponents(year: year, month: Int(month ?? 1), day: Int(day ?? 1))
//        return Calendar.current.date(from: dateComponents).map { Calendar.current.startOfDay(for: $0) }
//    }
    
    func dateComponents(missingComponentFallback fallback: Int? = 1) -> DateComponents {
        DateComponents(
            year: self.year,
            month: self.month.map(numericCast) ?? fallback,
            day: self.day.map(numericCast) ?? fallback
        )
    }
}


extension FHIRTime {
    func dateComponents() -> DateComponents {
        DateComponents(
            hour: Int(self.hour),
            minute: Int(self.minute),
            second: self.second.intValue
        )
    }
}


extension DateTime {
    func dateComponents(missingDateComponentFallback dateFallback: Int? = 1) -> DateComponents {
        var components = self.date.dateComponents(missingComponentFallback: dateFallback)
        if let timeComps = self.time?.dateComponents() {
            components.hour = timeComps.hour
            components.minute = timeComps.minute
            components.second = timeComps.second
        }
        if let originalTimeZoneString {
            components.timeZone = TimeZone(identifier: originalTimeZoneString)
        }
        return components
    }
}
