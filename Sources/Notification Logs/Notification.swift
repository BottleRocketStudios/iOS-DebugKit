//
//  Notification.swift
//  DebugKit
//  
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import SwiftUI
import UserNotifications

public struct Notification: Identifiable {

    // MARK: - Properties
    public let id = UUID()
    let notification: UNNotification

    // MARK: - Initializer
    public init(notification: UNNotification) {
        self.notification = notification
    }

    // MARK: - Interface
    var content: UNNotificationContent { return notification.request.content }

    func remotePayloadString() throws -> String? {
        guard notification.request.trigger is UNPushNotificationTrigger else { return nil }
        let jsonData = try JSONSerialization.data(withJSONObject: content.userInfo, options: [.prettyPrinted])
        return String(data: jsonData, encoding: .utf8)
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
        let content = entry.element.content
        EntryView(contentConfiguration: .init(date: entry.date, category: content.categoryIdentifier,
                                              title: content.title, subtitle: content.subtitle, message: content.body),
                  remotePayload: try? entry.element.remotePayloadString())
    }
}

// MARK: - EntryView Subtype
private extension Notification {

    struct EntryView: View  {

        // MARK: - Properties
        let contentConfiguration: ContentView.Configuration
        let remotePayload: String?

        // MARK: - View
        var body: some View {
            if let payload = remotePayload {
                NavigationLink(destination: payloadJSONView(for: payload),
                               label: { ContentView(configuration: contentConfiguration) })
            } else {
                ContentView(configuration: contentConfiguration)
            }
        }

        // MARK: - Subviews
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

// MARK: - ContentView Subtype
private extension Notification.EntryView {

    struct ContentView: View {

        // MARK: - Configuration Subtype
        struct Configuration {

            // MARK: - Properties
            let date: Date
            let category: String
            let title: String
            let subtitle: String
            let message: String

            // MARK: - Interface
            var titledContent: [(label: String, content: String)] {
                return [("Category", category), ("Title", title), ("Subtitle", subtitle), ("Body", message)]
            }
        }

        // MARK: - Properties
        let configuration: Configuration

        // MARK: - View
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 4) {
                    Text(configuration.date, style: .date)
                    Text(configuration.date, style: .time)
                }
                .font(.caption)
                .foregroundColor(.secondary)

                VStack(alignment: .leading) {
                    ForEach(configuration.titledContent, id: \.0) { titleContent in
                        if !titleContent.content.isEmpty {
                            HStack(alignment: .firstTextBaseline) {
                                Text(titleContent.label.localizedUppercase)
                                    .font(.caption2.bold())
                                    .foregroundColor(.accentColor.opacity(0.75))

                                Text(titleContent.content)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct NotificationEntryView_Previews: PreviewProvider {

    static var previews: some View {
        let config = Notification.EntryView.ContentView.Configuration(date: Date(),
                                                                      category: "com.test.test",
                                                                      title: "title title title",
                                                                      subtitle: "subtitle subtitle subtitle",
                                                                      message: "message message message")

        Notification.EntryView(contentConfiguration: config, remotePayload: nil)
            .previewLayout(.sizeThatFits)

        Notification.EntryView(contentConfiguration: config, remotePayload: nil)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
