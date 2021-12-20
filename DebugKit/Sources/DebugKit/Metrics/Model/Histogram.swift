//
//  Histogram.swift
//  
//
//  Created by Will McGinty on 12/20/21.
//

import MetricKit

/// Currently, the buckets of an `MXHistogram` can only be enumerated once - leading to false negative empty data sets. To work around this, all `MXHistogram` are read at initialization time into separate objects. FB9811513
struct Histogram<UnitType: Unit> {

    // MARK: - Bucket Subtype
    struct Bucket {
        let start: Measurement<UnitType>
        let end: Measurement<UnitType>
        let count: Int
    }

    // MARK: - Properties
    let buckets: [Bucket]

    // MARK: - Initializer
    init(buckets: [Bucket]) {
        self.buckets = buckets
    }

    init(histogram: MXHistogram<UnitType>) {
        self.buckets = histogram.bucketEnumerator.compactMap {
            guard let bucket = $0 as? MXHistogramBucket<UnitType> else { return nil }
            return .init(start: bucket.bucketStart, end: bucket.bucketEnd, count: bucket.bucketCount)
        }
    }
}
