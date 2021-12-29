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

    @ObservedObject var environmentService: EnvironmentService
    @ObservedObject var pushService: PushService
    @ObservedObject var metricsLogService: LogService<MXMetricPayload>
    @ObservedObject var notificationsLogService: LogService<UNNotification>

    var body: some View {
        NavigationView {
            DebugOptionsView(configuredSections: [.init(section: .init(title: "General"),
                                                        items: [.version(for: .main), .build(for: .main),
                                                                .deviceToken(for: pushService.deviceToken)]),
                                                  .init(section: .init(title: "Debug"),
                                                        items: [.crashTest()]),
                                                  .init(section: .init(title: "Logs"),
                                                        items: [.log(for: "Metrics", logService: metricsLogService),
                                                                .log(for: "Notifications", logService: notificationsLogService)]),
                                                  .section(for: EnvironmentService.Environment.self, with: "Environment",
                                                              currentEnvironment: environmentService.selectedEnvironment,
                                                              setNewEnvironment: { environmentService.selectedEnvironment = $0 })
                                                 ])
                .ignoresSafeArea()
                .navigationTitle("Debug Options")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
