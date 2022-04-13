//
//  ContentSubscriber.swift
//  Example
//
//  Copyright © 2020 Bottle Rocket Studios. All rights reserved.
//

import Combine
import DebugKit
import MetricKit
import SwiftUI
import UserNotifications

class ContentSubscriber: NSObject {

    // MARK: - Properties
    private var notifications = PassthroughSubject<UNNotification, Never>()
    private var metrics = PassthroughSubject<MXMetricPayload, Never>()

    // MARK: - Interface
    func logIncomingNotifications(to logService: LogService<UNNotification>,
                                  storingIn cancellables: inout Set<AnyCancellable>) {
        notifications
            .receive(on: RunLoop.main)
            .sink { notification in withAnimation { logService.insert(notification) } }
            .store(in: &cancellables)

        UNUserNotificationCenter.current().delegate = self
    }

    func logIncomingMetricsPayloads(to logService: LogService<MXMetricPayload>,
                                    storingIn cancellables: inout Set<AnyCancellable>) {
        metrics
            .receive(on: RunLoop.main)
            .sink { payload in withAnimation { logService.insert(payload) } }
            .store(in: &cancellables)

        MXMetricManager.shared.add(self)
    }
}

// MARK: - Incomings
extension ContentSubscriber: UNUserNotificationCenterDelegate, MXMetricManagerSubscriber {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        notifications.send(notification)
        return [.badge, .banner]
    }

    func didReceive(_ payloads: [MXMetricPayload]) {
        payloads.forEach(metrics.send)
    }
}
