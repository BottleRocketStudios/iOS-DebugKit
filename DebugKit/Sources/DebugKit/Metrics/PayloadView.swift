//
//  PayloadView.swift
//  
//
//  Created by Will McGinty on 6/19/21.
//

import SwiftUI
import MetricKit

struct PayloadView: View {
    
    let metrics: MetricPayload
    
    public init(metrics: MetricPayload) {
        self.metrics = metrics
    }
    
    public var body: some View {
        List {
            Section(header: Text("Hardware Metrics")) {
                NavigationLink(title: "Cellular Conditions", systemImage: "phone.connection", destination: CellularMetricsView.self,
                               payload: metrics, keyPath: \.cellularConditionMetrics)
                NavigationLink(title: "CPU", systemImage: "cpu", destination: CPUMetricsView.self, payload: metrics, keyPath: \.cpuMetrics)
                NavigationLink(title: "GPU", systemImage: "gamecontroller", destination: GPUMetricsView.self, payload: metrics, keyPath: \.gpuMetrics)
                NavigationLink(title: "Disk IO", systemImage: "internaldrive", destination: DiskIOMetricsView.self, payload: metrics, keyPath: \.diskIOMetrics)
                NavigationLink(title: "Display", systemImage: "display", destination: DisplayMetricsView.self, payload: metrics, keyPath: \.displayMetrics)
                NavigationLink(title: "Memory", systemImage: "memorychip", destination: MemoryMetricsView.self, payload: metrics, keyPath: \.memoryMetrics)
            }
            
            Section(header: Text("Software Metrics")) {
                NavigationLink(title: "Animation", systemImage: "wand.and.rays", destination: AnimationMetricsView.self, payload: metrics, keyPath: \.animationMetrics)
                NavigationLink(title: "Application Exit", systemImage: "xmark.octagon", destination: ExitMetricsView.self, payload: metrics, keyPath: \.applicationExitMetrics)
                NavigationLink(title: "Application Time", systemImage: "timer", destination: TimeMetricsView.self, payload: metrics, keyPath: \.applicationTimeMetrics)
                NavigationLink(title: "Launch", systemImage: "airplane.departure", destination: LaunchMetricsView.self, payload: metrics, keyPath: \.applicationLaunchMetrics)
                NavigationLink(title: "Location Activity", systemImage: "location", destination: LocationMetricsView.self, payload: metrics, keyPath: \.locationActivityMetrics)
                NavigationLink(title: "Network Transfer", systemImage: "network", destination: NetworkMetricsView.self, payload: metrics, keyPath: \.networkTransferMetrics)
                NavigationLink(title: "Responsiveness", systemImage: "dial.max.fill", destination: ResponsivenessMetricsView.self,
                               payload: metrics, keyPath: \.applicationResponsivenessMetrics)
            }
        }
    }
}
