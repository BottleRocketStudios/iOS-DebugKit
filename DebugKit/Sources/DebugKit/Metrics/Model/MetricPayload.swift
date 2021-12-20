//
//  MXMetricPayload+Recordable.swift
//  
//
//  Created by Will McGinty on 12/14/21.
//

import MetricKit
import SwiftUI

@dynamicMemberLookup
public struct MetricPayload: Identifiable {

    // MARK: - Properties
    public let id: UUID
    let payload: MXMetricPayload

    // Histogram Data Sets
    let cellularConditions: Histogram<MXUnitSignalBars>?

    let timeToFirstDraw: Histogram<UnitDuration>?
    let optimizedTimeToFirstDraw: Histogram<UnitDuration>?

    let resumeTime: Histogram<UnitDuration>?
    let hangTime: Histogram<UnitDuration>?

    // MARK: - Initializers
    public init(payload: MXMetricPayload) {
        self.id = UUID()
        self.payload = payload

        cellularConditions = payload.cellularConditionMetrics.map { .init(histogram: $0.histogrammedCellularConditionTime) }
        
        timeToFirstDraw = payload.applicationLaunchMetrics.map { .init(histogram: $0.histogrammedTimeToFirstDraw) }
        if #available(iOS 15.2, *) {
            optimizedTimeToFirstDraw = payload.applicationLaunchMetrics.map { .init(histogram: $0.histogrammedOptimizedTimeToFirstDraw) }
        } else {
            optimizedTimeToFirstDraw = nil
        }

        resumeTime = payload.applicationLaunchMetrics.map { .init(histogram: $0.histogrammedApplicationResumeTime) }
        hangTime = payload.applicationResponsivenessMetrics.map { .init(histogram: $0.histogrammedApplicationHangTime) }
    }

    // MARK: - Dynamic Member Lookup
    subscript<T>(dynamicMember keyPath: KeyPath<MXMetricPayload, T>) -> T {
        payload[keyPath: keyPath]
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
                       label: { EntryView(date: entry.date, payload: entry.element) })
    }
}

// MARK: - EntryView Subtype
private extension MetricPayload {

    struct EntryView: View  {

        // MARK: - Properties
        let date: Date
        let payload: MetricPayload

        // MARK: - View
        var body: some View {
            VStack(alignment: .leading) {

                HStack(spacing: 4) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .foregroundColor(.accentColor)

                    Text("App Version \(payload.latestApplicationVersion)")
                }
                .font(.caption.bold())

                HStack {
                    Text("Collection Start")
                        .font(.caption)
                        .foregroundColor(.accentColor)

                    Group {
                        Text(payload.timeStampBegin, style: .date)
                        Text(payload.timeStampBegin, style: .time)
                    }
                    .font(.caption)
                }

                HStack {
                    Text("Collection End")
                        .font(.caption)
                        .foregroundColor(.accentColor)

                    Group {
                        Text(payload.timeStampEnd, style: .date)
                        Text(payload.timeStampEnd, style: .time)
                    }
                    .font(.caption)
                }
            }.padding()
        }
    }
}
