//
//  MeasurementLabel.swift
//  
//
//  Created by Will McGinty on 6/19/21.
//

import Foundation
import SwiftUI
import MetricKit

public struct MeasurementLabel: View {
    
    // MARK: - Properties
    let name: String
    let value: String
    
    // MARK: - Preset
    static func displaying(value: Int, withName name: String) -> some View {
        return MeasurementLabel(name: name, value: String(value))
    }
    
    static func displaying<T: Foundation.Unit>(measurement: Measurement<T>, withName name: String) -> some View {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.unitOptions = .providedUnit
        
        return MeasurementLabel(name: name, value: formatter.string(from: measurement))
    }
    
    // MARK: - Body
    public var body: some View {
        HStack {
            Text(name)
            Spacer()
            Text(value)
        }
    }
}

// MARK: - Preview
struct MeasurementLabel_Previews: PreviewProvider {
    
    static var previews: some View {
        MeasurementLabel(name: "Measurement", value: "value")
            .previewLayout(.sizeThatFits)
    }
}
