//
//  App.swift
//  Example
//
//  Copyright © 2020 Bottle Rocket Studios. All rights reserved.
//

import Combine
import DebugKit
import MetricKit
import SwiftUI

@main
struct iOSExampleApp: App {

    // MARK: - Properties
    private let subscriber = ContentSubscriber()

    @StateObject private var environmentService = EnvironmentService()
    @StateObject private var pushService = PushService()
    @StateObject private var metricsLogService: LogService<MXMetricPayload> = .metricPayloads(storedAt: URL.documentsDirectory?.appendingPathComponent("metrics"))
    @StateObject private var notificationsLogService: LogService<UNNotification> = .notifications(storedAt: URL.documentsDirectory?.appendingPathComponent("notifications"))
    @State private var cancellables: Set<AnyCancellable> = []

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
