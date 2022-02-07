//
//  PushService.swift
//  Example
//
//  Copyright © 2020 Bottle Rocket Studios. All rights reserved.
//

import UserNotifications

class PushService: ObservableObject {

    // MARK: - Properties
    @Published var deviceToken: Data?

    // MARK: - Interface
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            debugPrint("Permission granted: \(granted)")
        }
    }
}
