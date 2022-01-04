//
//  MeasurementFormatters.swift
//  DebugKit
//  
//
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import Foundation

extension MeasurementFormatter {

    static let naturalScale: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .naturalScale
        return formatter
    }()

    static let providedUnit: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .providedUnit
        return formatter
    }()
}

extension NumberFormatter {

    static let standard: NumberFormatter = {
        let formatter = NumberFormatter()
        return formatter
    }()

    func string(from double: Double) -> String? {
        return string(from: NSNumber(value: double))
    }
}

extension DateIntervalFormatter {

    static let standard: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}
