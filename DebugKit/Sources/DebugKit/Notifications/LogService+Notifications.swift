//
//  LogService+Notifications.swift
//  
//
//  Created by Will McGinty on 12/23/21.
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
