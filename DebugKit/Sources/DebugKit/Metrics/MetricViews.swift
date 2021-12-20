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
    init(metric: Metric)
}

extension NavigationLink {

    init?(title: LocalizedStringKey, destination: Destination.Type, metric: Destination.Metric?) where Destination: MetricConfigurableView, Label == Text {
        guard let metric = metric else { return nil }
        self.init(title, destination: destination.init(metric: metric))
    }
}

// MARK: - MetricView
struct MetricView<T: Foundation.Unit>: View {

    // MARK: - Kind Subtype
    enum Kind {
        case histogram(MXHistogram<T>)
        case measurement(Measurement<T>)
        case value(Int)
    }

    // MARK: - Properties
    let title: String
    let kind: Kind

    // MARK: - View
    var body: some View {
        switch kind {
        case .histogram(let histogram): Histogram.displaying(histogram: histogram, withTitle: title)
        case .measurement(let measurement): MeasurementLabel.displaying(measurement: measurement, withName: title)
        case .value(let value): MeasurementLabel.displaying(value: value, withName: title)
        }
    }
}

struct CellularMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let metric: MXCellularConditionMetric

    // MARK: - View
    var body: some View {
        MetricView(title: "Cellular Condition", kind: .histogram(metric.histogrammedCellularConditionTime))
    }
}

struct AnimationMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let metric: MXAnimationMetric

    // MARK: - View
    var body: some View {
        List {
            MetricView(title: "Hitch Time Ratio", kind: .measurement(metric.scrollHitchTimeRatio))
        }
    }
}

struct CPUMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let metric: MXCPUMetric

    // MARK: - View
    var body: some View {
        List {
            MetricView(title: "CPU Time", kind: .measurement(metric.cumulativeCPUTime))
            MetricView(title: "CPU Instructions", kind: .measurement(metric.cumulativeCPUInstructions))
        }
    }
}

struct DisplayMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let metric: MXDisplayMetric

    // MARK: - View
    var body: some View {
        List {
            // TODO: Expose more about the average
            MetricView(title: "Average Pixel Luminance", kind: .measurement(metric.averagePixelLuminance!.averageMeasurement))
        }
    }
}

struct GPUMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let metric: MXGPUMetric

    // MARK: - View
    var body: some View {
        List {
            MetricView(title: "GPU Time", kind: .measurement(metric.cumulativeGPUTime))
        }
    }
}

struct LaunchMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let metric: MXAppLaunchMetric

    // MARK: - View
    var body: some View {
        List {
            NavigationLink("Resume Time") {
                MetricView(title: "Resume Time", kind: .histogram(metric.histogrammedApplicationResumeTime))
            }

            NavigationLink("Time To First Draw") {
                MetricView(title: "Time To First Draw", kind: .histogram(metric.histogrammedTimeToFirstDraw))
            }

            if #available(iOS 15.2, *) {
                NavigationLink("Optimized Time To First Draw") {
                    MetricView(title: "OptimizedTime To First Draw", kind: .histogram(metric.histogrammedOptimizedTimeToFirstDraw))
                }
            }
        }
    }
}

struct LocationMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let metric: MXLocationActivityMetric

    // MARK: - View
    var body: some View {
        List {
            MetricView(title: "Best for Navigation", kind: .measurement(metric.cumulativeBestAccuracyForNavigationTime))
            MetricView(title: "Best", kind: .measurement(metric.cumulativeBestAccuracyTime))
            MetricView(title: "Ten Meters", kind: .measurement(metric.cumulativeNearestTenMetersAccuracyTime))
            MetricView(title: "100 Meters", kind: .measurement(metric.cumulativeHundredMetersAccuracyTime))
            MetricView(title: "Kilometer", kind: .measurement(metric.cumulativeKilometerAccuracyTime))
            MetricView(title: "3 Kilometers", kind: .measurement(metric.cumulativeThreeKilometersAccuracyTime))
        }
    }
}

struct MemoryMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let metric: MXMemoryMetric

    // MARK: - View
    var body: some View {
        List {
            MetricView(title: "Average Suspsended Memory", kind: .measurement(metric.averageSuspendedMemory.averageMeasurement))
            MetricView(title: "Peak Memory", kind: .measurement(metric.peakMemoryUsage))
        }
    }
}

struct NetworkMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let metric: MXNetworkTransferMetric

    // MARK: - View
    var body: some View {
        List {
            MetricView(title: "Cell Down", kind: .measurement(metric.cumulativeCellularDownload))
            MetricView(title: "Cell Up", kind: .measurement(metric.cumulativeCellularUpload))
            MetricView(title: "WiFi Down", kind: .measurement(metric.cumulativeWifiDownload))
            MetricView(title: "WiFi Up", kind: .measurement(metric.cumulativeWifiUpload))
        }
    }
}

struct ResponsivenessMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let metric: MXAppResponsivenessMetric

    // MARK: - View
    var body: some View {
        MetricView(title: "Hang Time", kind: .histogram(metric.histogrammedApplicationHangTime))
    }
}

struct TimeMetricsView: MetricConfigurableView {
    
    // MARK: - Properties
    let metric: MXAppRunTimeMetric

    // MARK: - View
    var body: some View {
        List {
            MetricView(title: "Foreground", kind: .measurement(metric.cumulativeForegroundTime))
            MetricView(title: "Background", kind: .measurement(metric.cumulativeBackgroundTime))
            MetricView(title: "Background Audio", kind: .measurement(metric.cumulativeBackgroundAudioTime))
            MetricView(title: "Background Location", kind: .measurement(metric.cumulativeBackgroundLocationTime))
        }
    }
}

struct ExitMetricsView: MetricConfigurableView {

    // MARK: - Properties
    let metric: MXAppExitMetric

    // MARK: - View
    var body: some View {
        List {
            Section {
                MetricView(title: "Normal Foreground Exits", kind: .value(metric.foregroundExitData.cumulativeNormalAppExitCount))
                MetricView(title: "Abnormal Foreground Exits", kind: .value(metric.foregroundExitData.cumulativeAbnormalExitCount))
                MetricView(title: "Bad Access Foreground Exits", kind: .value(metric.foregroundExitData.cumulativeBadAccessExitCount))
                MetricView(title: "Watchdog Foreground Exits", kind: .value(metric.foregroundExitData.cumulativeAppWatchdogExitCount))
                MetricView(title: "Illegal Instruction Foreground Exits", kind: .value(metric.foregroundExitData.cumulativeIllegalInstructionExitCount))
                MetricView(title: "OOM Foreground Exits", kind: .value(metric.foregroundExitData.cumulativeMemoryResourceLimitExitCount))
            }

            Section {
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
    }
}

