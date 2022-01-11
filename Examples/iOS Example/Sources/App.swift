//
//  iOSExampleApp.swift
//  DebugKit iOS Example
//
//  Created by Will McGinty on 12/14/21.
//  Copyright © 2020 Bottle Rocket Studios. All rights reserved.
//

import SwiftUI
import MetricKit
import DebugKit
import Combine

@main
struct iOSExampleApp: App {

    // MARK: - Properties
    private let subscriber = ContentSubscriber()

    @StateObject var environmentService: EnvironmentService = EnvironmentService()
    @StateObject var pushService: PushService = PushService()
    @StateObject var metricsLogService: LogService<MXMetricPayload> = .metricPayloads(storedAt: URL.documentsDirectory?.appendingPathComponent("metrics"))
    @StateObject var notificationsLogService: LogService<UNNotification> = .notifications(storedAt: URL.documentsDirectory?.appendingPathComponent("notifications"))
    @State var cancellables: Set<AnyCancellable> = []

    // MARK: - View
    var body: some Scene {
        WindowGroup {
            ContentView(environmentService: environmentService,
                        pushService: pushService,
                        metricsLogService: metricsLogService,
                        notificationsLogService: notificationsLogService)
                .onAppear {
                    self.subscriber.logIncomingMetricsPayloads(to: metricsLogService, storingIn: &cancellables)
                    self.subscriber.logIncomingNotifications(to: notificationsLogService, storingIn: &cancellables)

                    self.pushService.registerForPushNotifications()
                }
        }
    }
}
