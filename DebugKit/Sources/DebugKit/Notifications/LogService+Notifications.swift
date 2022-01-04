//
//  LogService+Notifications.swift
//  DebugKit
//  
//
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import UserNotifications
import SwiftUI

extension UNNotification: Recordable {
    public var record: Notification { return .init(notification: self) }

    public static func view(for entry: Log<Notification>.Entry) -> some View {
        Notification.view(for: entry)
    }
}

public extension LogService {

    static func notifications(storedAt url: URL?) -> LogService<Notification> {
        return LogService<Notification>(storage: url.map(LogFileStorage.init))
    }

    static func notifications(storedAt url: URL?) -> LogService<UNNotification> {
        return LogService<UNNotification>(storage: url.map(LogFileStorage.init))
    }
}
