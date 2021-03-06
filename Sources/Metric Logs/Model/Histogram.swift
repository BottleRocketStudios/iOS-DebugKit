//
//  Histogram.swift
//  DebugKit
//  
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import MetricKit
import SwiftUI

struct Histogram<UnitType: Unit> {

    // MARK: - Bucket Subtype
    struct Bucket: Identifiable, Equatable {

        // MARK: - Properties
        let id = UUID()
        let start: Measurement<UnitType>
        let end: Measurement<UnitType>
        let count: Int

        // MARK: - Interface
        func unitValue(relativeTo max: Double) -> Double {
            return Double(count) / max
        }

        func formatted(using formatter: MeasurementFormatter) -> String {
            if start != end {
                return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
            }

            return formatter.string(from: start)
        }
    }

    // MARK: - Properties
    let buckets: [Bucket]

    // MARK: - Initializers
    init(buckets: [Bucket]) {
        self.buckets = buckets
    }

    // MARK: - Interface
    var measurementRange: ClosedRange<Measurement<UnitType>>? {
        guard let min = buckets.map(\.start).min(), let max = buckets.map(\.end).max() else { return nil }
        return min...max
    }

    var highestFrequencyEntry: Bucket? {
        return buckets.max(by: { $0.count < $1.count })
    }
}


// MARK: - Convenience
extension Histogram {

    /// Currently, the buckets of an `MXHistogram` can only be enumerated once - leading to false negative empty data sets. To work around this, all `MXHistogram` are read at initialization time into `Histogram` objects. FB9811513
    init(histogram: MXHistogram<UnitType>) {
        self.buckets = histogram.bucketEnumerator.compactMap {
            guard let bucket = $0 as? MXHistogramBucket<UnitType> else { return nil }
            return .init(start: bucket.bucketStart, end: bucket.bucketEnd, count: bucket.bucketCount)
        }
    }
}
