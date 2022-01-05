//
//  AverageLabel.swift
//  DebugKit
//  
//
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import SwiftUI
import MetricKit

struct AverageLabel: View {

    // MARK: - Properties
    let title: String
    let averageValue: String
    let sampleCount: String

    // MARK: - Preset
    static func displaying<T: Foundation.Unit>(average: MXAverage<T>, using formatter: MeasurementFormatter, withTitle title: String) -> some View {
        return AverageLabel(title: title, averageValue: formatter.string(from: average.averageMeasurement), sampleCount: "\(average.sampleCount)")
    }

    // MARK: - View
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            VStack(alignment: .trailing) {
                Text(averageValue)
                Text("\(sampleCount) samples")
                    .font(.caption)
            }
        }
    }
}


#if DEBUG

// MARK: - Preview
struct AverageLabel_Previews: PreviewProvider {

    static var previews: some View {
        AverageLabel(title: "Average Value", averageValue: "5", sampleCount: "100")
            .previewLayout(.sizeThatFits)

        AverageLabel(title: "Average Value", averageValue: "5", sampleCount: "100")
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}

#endif
