//
//  NavigationLink+Metric.swift
//  DebugKit
//
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import SwiftUI

// MARK: - NavigationLink + Metric
extension NavigationLink {

    init?(metric: Metric, destination: Destination.Type,
          payload: MetricPayload, keyPath: KeyPath<MetricPayload, Destination.Metric?>) where Destination: MetricConfigurableView, Label == SwiftUI.Label<Text, Image> {
        guard let metricPayload = payload[keyPath: keyPath] else { return nil }
        self.init(destination: destination.init(payload: payload, metric: metricPayload),
                  label: { Label(metric.title, systemImage: metric.systemImageName) })
    }
}

// MARK: - Preview
struct MetricNavigationLink_Previews: PreviewProvider {

    static var previews: some View {
        ForEach(Metric.allCases, id: \.self) { metric in
            Label(metric.title, systemImage: metric.systemImageName)
                .previewLayout(.sizeThatFits)
        }
    }
}
