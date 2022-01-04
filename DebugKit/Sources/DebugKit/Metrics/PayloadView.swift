//
//  PayloadView.swift
//  DebugKit
//  
//
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
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
                NavigationLink(metric: .cellularConditions, destination: CellularMetricsView.self, payload: metrics, keyPath: \.cellularConditionMetrics)
                NavigationLink(metric: .cpu, destination: CPUMetricsView.self, payload: metrics, keyPath: \.cpuMetrics)
                NavigationLink(metric: .gpu, destination: GPUMetricsView.self, payload: metrics, keyPath: \.gpuMetrics)
                NavigationLink(metric: .diskIO, destination: DiskIOMetricsView.self, payload: metrics, keyPath: \.diskIOMetrics)
                NavigationLink(metric: .display, destination: DisplayMetricsView.self, payload: metrics, keyPath: \.displayMetrics)
                NavigationLink(metric: .memory, destination: MemoryMetricsView.self, payload: metrics, keyPath: \.memoryMetrics)
            }
            
            Section(header: Text("Software Metrics")) {
                NavigationLink(metric: .animation, destination: AnimationMetricsView.self, payload: metrics, keyPath: \.animationMetrics)
                NavigationLink(metric: .appExit, destination: ExitMetricsView.self, payload: metrics, keyPath: \.applicationExitMetrics)
                NavigationLink(metric: .appTime, destination: TimeMetricsView.self, payload: metrics, keyPath: \.applicationTimeMetrics)
                NavigationLink(metric: .launch, destination: LaunchMetricsView.self, payload: metrics, keyPath: \.applicationLaunchMetrics)
                NavigationLink(metric: .location, destination: LocationMetricsView.self, payload: metrics, keyPath: \.locationActivityMetrics)
                NavigationLink(metric: .network, destination: NetworkMetricsView.self, payload: metrics, keyPath: \.networkTransferMetrics)
                NavigationLink(metric: .responsiveness, destination: ResponsivenessMetricsView.self, payload: metrics, keyPath: \.applicationResponsivenessMetrics)
            }
        }
    }
}
