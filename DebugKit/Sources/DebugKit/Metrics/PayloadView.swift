//
//  PayloadView.swift
//  
//
//  Created by Will McGinty on 6/19/21.
//

import SwiftUI
import MetricKit


public struct PayloadView: View {
    
    let metrics: MXMetricPayload
    
    public init(metrics: MXMetricPayload) {
        self.metrics = metrics
    }
    
    public var body: some View {
        List {
            Section(header: Text("Hardware Metrics")) {
                NavigationLink(title: "Cellular Conditions", destination: CellularMetricsView.self, metric: metrics.cellularConditionMetrics)
                NavigationLink(title: "CPU", destination: CPUMetricsView.self, metric: metrics.cpuMetrics)
                NavigationLink(title: "GPU", destination: GPUMetricsView.self, metric: metrics.gpuMetrics)
                NavigationLink(title: "Display", destination: DisplayMetricsView.self, metric: metrics.displayMetrics)
            }
            
            Section(header: Text("Software Metrics")) {
                NavigationLink(title: "Location Activity", destination: LocationMetricsView.self, metric: metrics.locationActivityMetrics)
                NavigationLink(title: "Network Transfer", destination: NetworkMetricsView.self, metric: metrics.networkTransferMetrics)
                NavigationLink(title: "Application Exit", destination: ExitMetricsView.self, metric: metrics.applicationExitMetrics)
                NavigationLink(title: "Application Time", destination: TimeMetricsView.self, metric: metrics.applicationTimeMetrics)
                NavigationLink(title: "Memory", destination: MemoryMetricsView.self, metric: metrics.memoryMetrics)
                NavigationLink(title: "Launch", destination: LaunchMetricsView.self, metric: metrics.applicationLaunchMetrics)
                NavigationLink(title: "Animation", destination: AnimationMetricsView.self, metric: metrics.animationMetrics)
                NavigationLink(title: "Responsiveness", destination: ResponsivenessMetricsView.self, metric: metrics.applicationResponsivenessMetrics)
            }
        }
    }
}
