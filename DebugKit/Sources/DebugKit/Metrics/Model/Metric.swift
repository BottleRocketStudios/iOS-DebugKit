//
//  Metric.swift
//  DebugKit
//  
//
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import Foundation
import MetricKit

enum Metric: CaseIterable {
    case cellularConditions
    case cpu
    case gpu
    case diskIO
    case display
    case memory

    case animation
    case appExit
    case appTime
    case launch
    case location
    case network
    case responsiveness

    var title: String {
        switch self {
        case .cellularConditions: return "Cellular Conditions"
        case .cpu: return "CPU"
        case .gpu: return "GPU"
        case .diskIO: return "Disk I/O"
        case .display: return "Display"
        case .memory: return "Memory"
        case .animation: return "Animation"
        case .appExit: return "Application Exits"
        case .appTime: return "Application Time"
        case .launch: return "Launch"
        case .location: return "Location Activity"
        case .network: return "Network Transfer"
        case .responsiveness: return "Responsiveness"
        }
    }

    var systemImageName: String {
        switch self {
        case .cellularConditions: return "phone.connection"
        case .cpu: return "cpu"
        case .gpu: return "gamecontroller"
        case .diskIO: return "internaldrive"
        case .display: return "display"
        case .memory: return "memorychip"
        case .animation: return "wand.and.rays"
        case .appExit: return "xmark.octagon"
        case .appTime: return "timer"
        case .launch: return "airplane.departure"
        case .location: return "location"
        case .network: return "network"
        case .responsiveness: return "dial.max"
        }
    }

    func contained(in payload: MXMetricPayload) -> Bool {
        switch self {
        case .cellularConditions: return payload[keyPath: \.cellularConditionMetrics] != nil
        case .cpu: return payload[keyPath: \.cpuMetrics] != nil
        case .gpu: return payload[keyPath: \.gpuMetrics] != nil
        case .diskIO: return payload[keyPath: \.diskIOMetrics] != nil
        case .display: return payload[keyPath: \.displayMetrics] != nil
        case .memory: return payload[keyPath: \.memoryMetrics] != nil
        case .animation: return payload[keyPath: \.animationMetrics] != nil
        case .appExit: return payload[keyPath: \.applicationExitMetrics] != nil
        case .appTime: return payload[keyPath: \.applicationTimeMetrics] != nil
        case .launch: return payload[keyPath: \.applicationLaunchMetrics] != nil
        case .location: return payload[keyPath: \.locationActivityMetrics] != nil
        case .network: return payload[keyPath: \.networkTransferMetrics] != nil
        case .responsiveness: return payload[keyPath: \.applicationResponsivenessMetrics] != nil
        }
    }
}
