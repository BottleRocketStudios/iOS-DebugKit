//
//  LogService+Notifications.swift
//  DebugKit
//  
//
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import UserNotifications
import SwiftUI

// MARK: - UNNotification + Recordable
extension UNNotification: Recordable {
    public var record: Notification { return .init(notification: self) }

    public static func view(for entry: Log<Notification>.Entry) -> some View {
        Notification.view(for: entry)
    }
}

// MARK: - LogService + UNNotifications
public extension LogService {

    static func notifications(storedAt url: URL?) -> LogService<UNNotification> {
        return LogService<UNNotification>(storage: url.map(LogFileStorage.init))
    }
}
