//
//  MeasurementFormatters.swift
//  
//
//  Created by Will McGinty on 12/20/21.
//

import Foundation

extension MeasurementFormatter {

    static let shortNaturalScale: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.unitOptions = .naturalScale

        return formatter
    }()

    static let shortProvidedUnit: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
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