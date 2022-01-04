//
//  MeasurementLabel.swift
//  DebugKit
//  
//
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import SwiftUI

struct MeasurementLabel: View {
    
    // MARK: - Properties
    let name: String
    let value: String
    
    // MARK: - Preset
    static func displaying(value: Int, withName name: String) -> some View {
        return MeasurementLabel(name: name, value: String(value))
    }
    
    static func displaying<T: Foundation.Unit>(measurement: Measurement<T>, withName name: String, using formatter: MeasurementFormatter) -> some View {
        return MeasurementLabel(name: name, value: formatter.string(from: measurement))
    }
    
    // MARK: - Body
    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Text(value)
                .foregroundColor(Color(UIColor.secondaryLabel))
        }
    }
}

// MARK: - Preview
struct MeasurementLabel_Previews: PreviewProvider {
    
    static var previews: some View {
        MeasurementLabel(name: "Measurement Title", value: "125 m/s")
            .previewLayout(.sizeThatFits)

        MeasurementLabel(name: "Measurement Title", value: "125 m/s")
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
