//
//  ContentView.swift
//  DebugKit iOS Example
//
//  Created by Will McGinty on 12/14/21.
//

import SwiftUI
import DebugKit
import MetricKit

struct ContentView: View {

    @ObservedObject var metricsLogService: LogService<MetricPayload>
    @ObservedObject var notificationsLogService: LogService<DebugKit.Notification>

    var body: some View {
        NavigationView {
            List {
                NavigationLink("Metrics Log") {
                    LogList(logService: metricsLogService)
                        .navigationTitle("Metrics")
                }

                NavigationLink("Notifications Log") {
                    LogList(logService: notificationsLogService)
                        .navigationTitle("Notifications")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Example")
        }
    }
}
