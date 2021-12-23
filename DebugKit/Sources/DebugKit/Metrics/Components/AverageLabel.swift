//
//  AverageLabel.swift
//  
//
//  Created by Will McGinty on 12/20/21.
//

import SwiftUI
import MetricKit

struct AverageLabel: View {

    // MARK: - Properties
    let name: String
    let averageValue: String
    let sampleCount: String

    // MARK: - Preset
    static func displaying<T: Foundation.Unit>(average: MXAverage<T>,
                                               withName name: String, using formatter: MeasurementFormatter) -> some View {
        return AverageLabel(name: name, averageValue: formatter.string(from: average.averageMeasurement),
                            sampleCount: "\(average.sampleCount)")
    }

    // MARK: - Body
    var body: some View {
        HStack {
            Text(name)
            Spacer()
            VStack {
                Text(averageValue)
                Text("(\(sampleCount) samples)")
                    .font(.caption)
            }
        }
    }
}

// MARK: - Preview
struct AverageLabel_Previews: PreviewProvider {

    static var previews: some View {
        AverageLabel(name: "Average Value", averageValue: "5", sampleCount: "100")
            .previewLayout(.sizeThatFits)
    }
}
