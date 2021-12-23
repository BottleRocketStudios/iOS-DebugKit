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
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    @StateObject var metricsLogService: LogService<MXMetricPayload> = .metricPayloads(storedAt: URL.documentsDirectory?.appendingPathComponent("metrics"))
    @StateObject var notificationsLogService: LogService<UNNotification> = .notifications(storedAt: URL.documentsDirectory?.appendingPathComponent("notifications"))

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
    func logIncomingNotifications(to logService: LogService<UNNotification>,
                                  storingIn cancellables: inout Set<AnyCancellable>) {
        notifications
            .receive(on: RunLoop.main)
            .sink { notification in
                withAnimation { logService.append(notification) }
            }
            .store(in: &cancellables)

        UNUserNotificationCenter.current().delegate = self
    }

    func logIncomingMetricsPayloads(to logService: LogService<MXMetricPayload>,
                                    storingIn cancellables: inout Set<AnyCancellable>) {
        metrics
            .receive(on: RunLoop.main)
            .sink { payload in
                withAnimation { logService.append(payload) }
            }
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

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        let content = UNMutableNotificationContent()
        content.userInfo = userInfo

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        print(request)

        return .noData
    }
}
