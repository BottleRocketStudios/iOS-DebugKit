//
//  MetricView.swift
//  
//
//  Created by Will McGinty on 12/15/21.
//

import MetricKit
import SwiftUI

protocol MetricConfigurableView: View {
    associatedtype Metric
    init(payload: MetricPayload, metric: Metric)
}

extension NavigationLink {

    init?(title: LocalizedStringKey, systemImage: String, destination: Destination.Type,
          payload: MetricPayload, keyPath: KeyPath<MetricPayload, Destination.Metric?>) where Destination: MetricConfigurableView, Label == SwiftUI.Label<Text, Image> {
        guard let metric = payload[keyPath: keyPath] else { return nil }
        self.init(destination: destination.init(payload: payload, metric: metric),
                  label: { Label(title, systemImage: systemImage) })
    }
}

// MARK: - MetricView
struct MetricView<T: Foundation.Unit>: View {

    // MARK: - Kind Subtype
    enum Kind {
        case histogram(Histogram<T>, formatter: MeasurementFormatter = .shortNaturalScale)
        case measurement(Measurement<T>, formatter: MeasurementFormatter = .shortNaturalScale)
        case average(MXAverage<T>, formatter: MeasurementFormatter = .shortNaturalScale)
        case value(Int)
    }

    // MARK: - Properties
    let title: String
    let kind: Kind

    // MARK: - View
    var body: some View {
        Group {
            switch kind {
            case let .histogram(histogram, formatter): HistogramView.displaying(histogram: histogram, withTitle: title, using: formatter)
            case let .measurement(measurement, formatter): MeasurementLabel.displaying(measurement: measurement, withName: title, using: formatter)
            case let .average(average, formatter): AverageLabel.displaying(average: average, withName: title, using: formatter)
            case .value(let value): MeasurementLabel.displaying(value: value, withName: title)
            }
        }
    }
}

struct AnimationMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let payload: MetricPayload
    let metric: MXAnimationMetric

    // MARK: - View
    var body: some View {
        List {
            MetricView(title: "Hitch Time Ratio", kind: .measurement(metric.scrollHitchTimeRatio))
        }
        .navigationTitle("Animation")
    }
}

struct CellularMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let payload: MetricPayload
    let metric: MXCellularConditionMetric

    // MARK: - View
    var body: some View {
        if let cellularConditions = payload.cellularConditions {
            MetricView(title: "Cellular Conditions", kind: .histogram(cellularConditions, formatter: .shortProvidedUnit))
        } else {
            NoEntriesView(configuration: .default)
                .navigationTitle("Cellular Conditions")
        }
    }
}

struct CPUMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let payload: MetricPayload
    let metric: MXCPUMetric

    // MARK: - View
    var body: some View {
        List {
            MetricView(title: "CPU Time", kind: .measurement(metric.cumulativeCPUTime))
            MetricView(title: "CPU Instructions", kind: .measurement(metric.cumulativeCPUInstructions))
        }
        .navigationTitle("CPU")
    }
}

struct DiskIOMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let payload: MetricPayload
    let metric: MXDiskIOMetric

    // MARK: - View
    var body: some View {
        List {
            MetricView(title: "Logical Writes", kind: .measurement(metric.cumulativeLogicalWrites))
        }
        .navigationTitle("Disk IO")
    }
}

struct DisplayMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let payload: MetricPayload
    let metric: MXDisplayMetric

    // MARK: - View
    var body: some View {
        Group {
            if let averagePixelLuminance = metric.averagePixelLuminance {
                List {
                    MetricView(title: "Average Pixel Luminance", kind: .average(averagePixelLuminance, formatter: .shortProvidedUnit))
                }
            } else {
                NoEntriesView(configuration: .default)
            }
        }
        .navigationTitle("Display")
    }
}

struct ExitMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let payload: MetricPayload
    let metric: MXAppExitMetric

    // MARK: - View
    var body: some View {
        List {
            Section(header: Text("Foreground Exits")) {
                MetricView(title: "Normal Foreground Exits", kind: .value(metric.foregroundExitData.cumulativeNormalAppExitCount))
                MetricView(title: "Abnormal Foreground Exits", kind: .value(metric.foregroundExitData.cumulativeAbnormalExitCount))
                MetricView(title: "Bad Access Foreground Exits", kind: .value(metric.foregroundExitData.cumulativeBadAccessExitCount))
                MetricView(title: "Watchdog Foreground Exits", kind: .value(metric.foregroundExitData.cumulativeAppWatchdogExitCount))
                MetricView(title: "Illegal Instruction Foreground Exits", kind: .value(metric.foregroundExitData.cumulativeIllegalInstructionExitCount))
                MetricView(title: "OOM Foreground Exits", kind: .value(metric.foregroundExitData.cumulativeMemoryResourceLimitExitCount))
            }

            Section(header: Text("Background Exits")) {
                MetricView(title: "Normal Background Exits", kind: .value(metric.backgroundExitData.cumulativeNormalAppExitCount))
                MetricView(title: "Abnormal Background Exits", kind: .value(metric.backgroundExitData.cumulativeAbnormalExitCount))
                MetricView(title: "Bad Access Background Exits", kind: .value(metric.backgroundExitData.cumulativeBadAccessExitCount))
                MetricView(title: "Watchdog Background Exits", kind: .value(metric.backgroundExitData.cumulativeAppWatchdogExitCount))
                MetricView(title: "Illegal Instruction Background Exits", kind: .value(metric.backgroundExitData.cumulativeIllegalInstructionExitCount))
                MetricView(title: "Memory Exceeded Background Exits", kind: .value(metric.backgroundExitData.cumulativeMemoryResourceLimitExitCount))
                MetricView(title: "Memory Pressure Background Exits", kind: .value(metric.backgroundExitData.cumulativeMemoryPressureExitCount))
                MetricView(title: "CPU Resources Exceeded Background Exits", kind: .value(metric.backgroundExitData.cumulativeCPUResourceLimitExitCount))
                MetricView(title: "Suspend with Locked File Background Exits", kind: .value(metric.backgroundExitData.cumulativeSuspendedWithLockedFileExitCount))
                MetricView(title: "Task Assertion Background Exits", kind: .value(metric.backgroundExitData.cumulativeBackgroundTaskAssertionTimeoutExitCount))
            }
        }
        .navigationTitle("Application Exit")
    }
}

struct GPUMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let payload: MetricPayload
    let metric: MXGPUMetric

    // MARK: - View
    var body: some View {
        List {
            MetricView(title: "GPU Time", kind: .measurement(metric.cumulativeGPUTime))
        }
        .navigationTitle("GPU")
    }
}

struct LaunchMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let payload: MetricPayload
    let metric: MXAppLaunchMetric

    // MARK: - View
    var body: some View {
        List {
            if let resumeTime = payload.resumeTime {
                NavigationLink("Resume Time") {
                    MetricView(title: "Resume Time", kind: .histogram(resumeTime))
                }
            }

            if let timeToFirstDraw = payload.timeToFirstDraw {
                NavigationLink("Time To First Draw") {
                    MetricView(title: "Time To First Draw", kind: .histogram(timeToFirstDraw))
                }
            }

            if let optimizedTimeToFirstDraw = payload.optimizedTimeToFirstDraw {

                NavigationLink("Optimized Time To First Draw") {
                    MetricView(title: "Optimized Time To First Draw", kind: .histogram(optimizedTimeToFirstDraw))
                }
            }
        }
        .navigationTitle("Launch")
    }
}

struct LocationMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let payload: MetricPayload
    let metric: MXLocationActivityMetric

    // MARK: - View
    var body: some View {
        List {
            MetricView(title: "Best for Navigation", kind: .measurement(metric.cumulativeBestAccuracyForNavigationTime))
            MetricView(title: "Best", kind: .measurement(metric.cumulativeBestAccuracyTime))
            MetricView(title: "Nearest 10 M", kind: .measurement(metric.cumulativeNearestTenMetersAccuracyTime))
            MetricView(title: "Nearest 100 M", kind: .measurement(metric.cumulativeHundredMetersAccuracyTime))
            MetricView(title: "Nearest KM", kind: .measurement(metric.cumulativeKilometerAccuracyTime))
            MetricView(title: "Nearest 3 KM", kind: .measurement(metric.cumulativeThreeKilometersAccuracyTime))
        }
        .navigationTitle("Location Activity")
    }
}

struct MemoryMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let payload: MetricPayload
    let metric: MXMemoryMetric

    // MARK: - View
    var body: some View {
        List {
            MetricView(title: "Average Suspended Memory", kind: .average(metric.averageSuspendedMemory))
            MetricView(title: "Peak Memory", kind: .measurement(metric.peakMemoryUsage))
        }
        .navigationTitle("Memory")
    }
}

struct NetworkMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let payload: MetricPayload
    let metric: MXNetworkTransferMetric

    // MARK: - View
    var body: some View {
        List {
            MetricView(title: "Cellular Down", kind: .measurement(metric.cumulativeCellularDownload))
            MetricView(title: "Cellular Up", kind: .measurement(metric.cumulativeCellularUpload))
            MetricView(title: "WiFi Down", kind: .measurement(metric.cumulativeWifiDownload))
            MetricView(title: "WiFi Up", kind: .measurement(metric.cumulativeWifiUpload))
        }
        .navigationTitle("Network Transfer")
    }
}

struct ResponsivenessMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let payload: MetricPayload
    let metric: MXAppResponsivenessMetric

    // MARK: - View
    var body: some View {

        if let hangTime = payload.hangTime {
            MetricView(title: "Hang Time", kind: .histogram(hangTime))
        } else {
            NoEntriesView(configuration: .default)
                .navigationTitle("Responsiveness")
        }
    }
}

struct TimeMetricsView: MetricConfigurableView {
    
    // MARK: - Properties
    let payload: MetricPayload
    let metric: MXAppRunTimeMetric

    // MARK: - View
    var body: some View {
        List {
            MetricView(title: "Foreground", kind: .measurement(metric.cumulativeForegroundTime))
            MetricView(title: "Background", kind: .measurement(metric.cumulativeBackgroundTime))
            MetricView(title: "Background Audio", kind: .measurement(metric.cumulativeBackgroundAudioTime))
            MetricView(title: "Background Location", kind: .measurement(metric.cumulativeBackgroundLocationTime))
        }
        .navigationTitle("Application Time")
    }
}
