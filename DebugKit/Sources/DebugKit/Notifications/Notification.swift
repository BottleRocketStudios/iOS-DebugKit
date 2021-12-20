//
//  Notification.swift
//  
//
//  Created by Will McGinty on 12/16/21.
//

import UserNotifications
import SwiftUI

public struct Notification: Identifiable {

    // MARK: - Properties
    let notification: UNNotification

    public var id: String { return notification.request.identifier }
    public var content: UNNotificationContent { return notification.request.content }
    public var remotePayload: String? {
        guard notification.request.trigger is UNPushNotificationTrigger else { return nil }
        let jsonData = try? JSONSerialization.data(withJSONObject: content.userInfo, options: [.prettyPrinted])
        return jsonData.flatMap { String(data: $0, encoding: .utf8) }
    }

    // MARK: - Initializer
    public init(notification: UNNotification) {
        self.notification = notification
    }
}

// MARK: - Codable
extension Notification: Codable {

    private enum CodingKeys: String, CodingKey {
        case notificationData
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let notificationData = try container.decode(Data.self, forKey: .notificationData)
        self.init(notification: try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(notificationData) as! UNNotification)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let notificationData = try NSKeyedArchiver.archivedData(withRootObject: notification, requiringSecureCoding: true)
        try container.encode(notificationData, forKey: .notificationData)
    }
}

// MARK: - Recordable
extension Notification: Recordable {

    public static func view(for entry: Log<Self>.Entry) -> some View {
        EntryView(date: entry.date, notification: entry.element)
    }
}

// MARK: - EntryView Subtype
private extension Notification {

    struct EntryView: View  {

        // MARK: - Properties
        let date: Date
        let notification: Notification

        // MARK: - View
        var body: some View {
            if let payload = notification.remotePayload {
                NavigationLink(destination: payloadJSONView(for: payload), label: { payloadContentView })
            } else {
                payloadContentView
            }
        }

        // MARK: - Subviews
        @ViewBuilder
        private var payloadContentView: some View {
            VStack(alignment: .leading) {
                HStack(spacing: 4) {
                    Image(systemName: "cloud")
                        .foregroundColor(.accentColor)
                    Text(date, style: .date)
                    Text(date, style: .time)
                }
                .font(.caption.bold())

                Spacer()
                
                ForEach(notification.titledContent, id: \.0) { titleContent in
                    if !titleContent.content.isEmpty {
                        HStack(alignment: .firstTextBaseline) {
                            Text(titleContent.label)
                                .font(.caption)
                                .foregroundColor(.accentColor)

                            Text(titleContent.content)
                                .font(.caption)
                                .lineLimit(1)
                                .truncationMode(.head)
                        }
                    }
                }
            }
        }

        @ViewBuilder
        private func payloadJSONView(for payload: String) -> some View {
            ScrollView(.vertical, showsIndicators: true) {
                if #available(iOS 15.0, *) {
                    Text(payload)
                        .font(.caption.monospaced())
                } else {
                    Text(payload)
                        .font(.caption)
                }
            }
        }
    }
}

// MARK: - Display Helpers
private extension Notification {

    var titledContent: [(label: String, content: String)] {
        return [("Category", content.categoryIdentifier),
                ("Title", content.title),
                ("Subtitle", content.subtitle),
                ("Body", content.body)]
    }
}
