//
//  PushService.swift
//  DebugKit iOS Example
//
//  Created by Will McGinty on 12/28/21.
//  Copyright © 2020 Bottle Rocket Studios. All rights reserved.
//

import UserNotifications

class PushService: ObservableObject {

    @Published var deviceToken: Data?

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            debugPrint("Permission granted: \(granted)")
        }
    }
}
