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

    @ObservedObject var metricsLogService: LogService<MXMetricPayload>
    @ObservedObject var notificationsLogService: LogService<UNNotification>

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Logs")) {
                    if let notificationLog = notificationsLogService {
                        NavigationLink("Notifications") {
                            LogView(logService: notificationLog)
                        }
                    }

                    if let metricLog = metricsLogService {
                        NavigationLink("Metrics") {
                            LogView(logService: metricLog)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Example")
        }
    }
}
