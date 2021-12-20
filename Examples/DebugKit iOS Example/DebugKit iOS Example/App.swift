//
//  iOSExampleApp.swift
//  DebugKit iOS Example
//
//  Created by Will McGinty on 12/14/21.
//

import SwiftUI
import MetricKit
import DebugKit
import Combine

@main
struct iOSExampleApp: App {

    // MARK: - Properties
    @StateObject var metricsLogService: LogService<MetricPayload> = .init(storage: LogFileStorage(url: FileManager.default.temporaryDirectory.appendingPathComponent("metrics")))
    @StateObject var notificationsLogService: LogService<DebugKit.Notification> = .init(storage: LogFileStorage(url: FileManager.default.temporaryDirectory.appendingPathComponent("notifications2")))

    private let subscriber = Subscriber()
    @State var cancellables: Set<AnyCancellable> = []

    // MARK: - View
    var body: some Scene {
        WindowGroup {
            ContentView(metricsLogService: metricsLogService,
                        notificationsLogService: notificationsLogService)
                .onAppear {
                    self.subscriber.logIncomingMetricsPayloads(to: metricsLogService, storingIn: &cancellables)
                    self.subscriber.logIncomingNotifications(to: notificationsLogService, storingIn: &cancellables)

                    self.registerForPushNotifications()
                }
        }
    }

    // MARK: - Interface
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            debugPrint("Permission granted: \(granted)")
        }
    }
}

class Subscriber: NSObject, UNUserNotificationCenterDelegate, MXMetricManagerSubscriber {

    // MARK: - Properties
    private var notifications = PassthroughSubject<UNNotification, Never>()
    private var metrics = PassthroughSubject<MXMetricPayload, Never>()

    // MARK: - Interface
    func logIncomingNotifications(to logService: LogService<DebugKit.Notification>,
                                  storingIn cancellables: inout Set<AnyCancellable>) {
        notifications
            .receive(on: RunLoop.main)
            .sink { logService.append(.init(notification: $0)) }
            .store(in: &cancellables)

        UNUserNotificationCenter.current().delegate = self
    }

    func logIncomingMetricsPayloads(to logService: LogService<MetricPayload>,
                                    storingIn cancellables: inout Set<AnyCancellable>) {
        metrics
            .receive(on: RunLoop.main)
            .sink { logService.append(.init(payload: $0)) }
            .store(in: &cancellables)

        MXMetricManager.shared.add(self)
    }

    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        notifications.send(notification)
        return [.badge, .banner]
    }

    // MARK: - MXMetricManagerSubscriber
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            metrics.send(payload)
        }
    }
}
