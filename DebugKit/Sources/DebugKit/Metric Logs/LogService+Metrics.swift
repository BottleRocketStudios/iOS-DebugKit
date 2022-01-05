//
//  LogService+Metrics.swift
//  DebugKit
//  
//
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import MetricKit
import SwiftUI

// MARK: - MXMetricPayload + Recordable
extension MXMetricPayload: Recordable {
    public var record: MetricPayload { return .init(payload: self) }

    public static func view(for entry: Log<MetricPayload>.Entry) -> some View {
        return MetricPayload.view(for: entry)
    }
}

// MARK: - LogService + MXMetricPayloads
public extension LogService {

    static func metricPayloads(storedAt url: URL?) -> LogService<MXMetricPayload> {
        return LogService<MXMetricPayload>(storage: url.map(LogFileStorage.init))
    }
}
