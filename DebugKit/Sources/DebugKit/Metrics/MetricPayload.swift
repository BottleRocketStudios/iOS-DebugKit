//
//  MXMetricPayload+Recordable.swift
//  
//
//  Created by Will McGinty on 12/14/21.
//

import MetricKit
import SwiftUI

public struct MetricPayload: Identifiable {

    // MARK: - Properties
    public let id: UUID
    let payload: MXMetricPayload

    // MARK: - Initializers
    public init(payload: MXMetricPayload) {
        self.id = UUID()
        self.payload = payload
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
        NavigationLink(destination: { PayloadView(metrics: entry.element.payload) },
                       label: { Text(entry.date, style: .date) })
    }
}
