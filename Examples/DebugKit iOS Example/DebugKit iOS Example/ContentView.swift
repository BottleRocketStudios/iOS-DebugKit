//
//  ContentView.swift
//  DebugKit iOS Example
//
//  Created by Will McGinty on 12/14/21.
//  Copyright © 2020 Bottle Rocket Studios. All rights reserved.
//

import SwiftUI
import DebugKit
import MetricKit

struct ContentView: View {

    @ObservedObject var environmentService: EnvironmentService
    @ObservedObject var pushService: PushService
    @ObservedObject var metricsLogService: LogService<MXMetricPayload>
    @ObservedObject var notificationsLogService: LogService<UNNotification>

    @State private var isPresentingDebugOptions: Bool = false

    var body: some View {
        VStack {
            Text("App content")
                .sheet(isPresented: $isPresentingDebugOptions) {
                    NavigationView {
                        DebugOptionsView(configuredSections: [.init(section: .init(title: "General"),
                                                                    items: [.version(for: .main, title: "Version"), .build(for: .main, title: "Build"),
                                                                            .pushToken(with: pushService.deviceToken, title: "Push Token")]),
                                                              .init(section: .init(title: "Debug"),
                                                                    items: [.crashTest()]),
                                                              .init(section: .init(title: "Logs"),
                                                                    items: [.log(for: "Metrics", logService: metricsLogService),
                                                                            .log(for: "Notifications", logService: notificationsLogService)]),
                                                              .environmentPicker(for: EnvironmentService.Environment.allCases, withTitle: "Environment",
                                                                                    currentEnvironment: environmentService.selectedEnvironment,
                                                                                    setNewEnvironment: { environmentService.selectedEnvironment = $1 })
                                                             ])
                            .ignoresSafeArea()
                            .navigationTitle("Debug Options")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }

            Button("Present Debug Content") {
                isPresentingDebugOptions = true
            }
        }
    }
}
