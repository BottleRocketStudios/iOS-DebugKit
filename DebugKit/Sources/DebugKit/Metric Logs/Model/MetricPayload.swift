//
//  MetricPayload.swift
//  DebugKit
//  
//
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import MetricKit
import SwiftUI

@dynamicMemberLookup
public struct MetricPayload: Identifiable {

    // MARK: - Properties
    public let id = UUID()
    let payload: MXMetricPayload

    // Histogram Data Sets
    let cellularConditions: Histogram<MXUnitSignalBars>?
    let resumeTime: Histogram<UnitDuration>?
    let hangTime: Histogram<UnitDuration>?
    let timeToFirstDraw: Histogram<UnitDuration>?
    let optimizedTimeToFirstDraw: Histogram<UnitDuration>?

    // MARK: - Initializers
    public init(payload: MXMetricPayload) {
        self.payload = payload

        cellularConditions = payload.cellularConditionMetrics.map { .init(histogram: $0.histogrammedCellularConditionTime) }
        resumeTime = payload.applicationLaunchMetrics.map { .init(histogram: $0.histogrammedApplicationResumeTime) }
        hangTime = payload.applicationResponsivenessMetrics.map { .init(histogram: $0.histogrammedApplicationHangTime) }
        timeToFirstDraw = payload.applicationLaunchMetrics.map { .init(histogram: $0.histogrammedTimeToFirstDraw) }
        if #available(iOS 15.2, *) {
            optimizedTimeToFirstDraw = payload.applicationLaunchMetrics.map { .init(histogram: $0.histogrammedOptimizedTimeToFirstDraw) }
        } else {
            optimizedTimeToFirstDraw = nil
        }
    }

    // MARK: - Dynamic Member Lookup
    subscript<T>(dynamicMember keyPath: KeyPath<MXMetricPayload, T>) -> T {
        payload[keyPath: keyPath]
    }

    // MARK: - Interface
    var metricCount: Int {
        return Metric.allCases.filter { $0.contained(in: payload) }.count
    }
}

// MARK: - Codable
extension MetricPayload: Codable {

    private enum CodingKeys: String, CodingKey {
        case payloadData
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let payloadData = try container.decode(Data.self, forKey: .payloadData)
        self.init(payload: try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(payloadData) as! MXMetricPayload)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let payloadData = try NSKeyedArchiver.archivedData(withRootObject: payload, requiringSecureCoding: true)
        try container.encode(payloadData, forKey: .payloadData)
    }
}

// MARK: - Recordable
extension MetricPayload: Recordable {

    public static func view(for entry: Log<Self>.Entry) -> some View {
        NavigationLink(destination: { PayloadView(metrics: entry.element) },
                       label: { EntryView(configuration: .init(applicationVersion: entry.element.latestApplicationVersion,
                                                               osVersion: entry.element.metaData?.osVersion,
                                                               startDate: entry.element.timeStampBegin,
                                                               endDate: entry.element.timeStampEnd,
                                                               metricCount: entry.element.metricCount)) })
    }
}

// MARK: - EntryView Subtype
private extension MetricPayload {

    struct EntryView: View  {

        // MARK: - Configuration Subtype
        struct Configuration {

            // MARK: - Properties
            let applicationVersion: String
            let osVersion: String?
            let startDate: Date
            let endDate: Date
            let metricCount: Int

            // MARK: - Interface
            var interval: DateInterval {
                return DateInterval(start: startDate, end: endDate)
            }

            var titledContent: [(label: String, content: String)] {
                return [("Total Metrics", String(metricCount)), ("App Version", applicationVersion), ("OS Version", osVersion ?? "")]
            }
        }

        // MARK: - Properties
        let configuration: Configuration

        // MARK: - View
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(DateIntervalFormatter.standard.string(from: configuration.interval) ?? "")
                    .font(.caption)
                    .foregroundColor(Color(UIColor.secondaryLabel))

                VStack(alignment: .leading) {
                    ForEach(configuration.titledContent, id: \.0) { titleContent in
                        if !titleContent.content.isEmpty {
                            HStack(alignment: .firstTextBaseline) {
                                Text(titleContent.label.localizedUppercase)
                                    .font(.caption2.bold())
                                    .foregroundColor(.accentColor)

                                Text(titleContent.content)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                        }
                    }
                }
            }
        }
    }
}


#if DEBUG

// MARK: - Preview
struct MetricEntryView_Previews: PreviewProvider {

    static var previews: some View {
        let config = MetricPayload.EntryView.Configuration(applicationVersion: "10.0.0",
                                                           osVersion: "15.0",
                                                           startDate: Date(),
                                                           endDate: Date().advanced(by: 86400),
                                                           metricCount: 7)

        MetricPayload.EntryView(configuration: config)
            .previewLayout(.sizeThatFits)

        MetricPayload.EntryView(configuration: config)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}

#endif
