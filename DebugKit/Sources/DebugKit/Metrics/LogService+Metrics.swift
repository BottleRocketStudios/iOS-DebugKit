//
//  LogService+Metrics.swift
//  
//
//  Created by Will McGinty on 12/23/21.
//

import MetricKit
import SwiftUI

extension MXMetricPayload: Recordable {
    public var record: MetricPayload { return .init(payload: self) }

    public static func view(for entry: Log<MetricPayload>.Entry) -> some View {
        return MetricPayload.view(for: entry)
    }
}

public extension LogService {

    static func metricPayloads(storedAt url: URL?) -> LogService<MetricPayload> {
        return LogService<MetricPayload>(storage: url.map(LogFileStorage.init))
    }

    static func metricPayloads(storedAt url: URL?) -> LogService<MXMetricPayload> {
        return LogService<MXMetricPayload>(storage: url.map(LogFileStorage.init))
    }
}
