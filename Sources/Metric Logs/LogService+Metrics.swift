//
//  LogService+Metrics.swift
//  DebugKit
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

    static func metricPayloads(storedAt url: URL?) throws -> LogService<MXMetricPayload> {
        guard let url = url else { return .init() }
        return try .init(storage: LogFileStorage(url: url))
    }
}
