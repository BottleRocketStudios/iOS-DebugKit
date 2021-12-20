//
//  LogService.swift
//  
//
//  Created by Will McGinty on 12/14/21.
//

import SwiftUI

public protocol Recordable: Identifiable {
    associatedtype LogView: View
    @ViewBuilder static func view(for entry: Log<Self>.Entry) -> LogView
}

public class LogService<Item: Recordable>: ObservableObject {

    // MARK: - Subtypes
    public struct ExpirationInterval {

        // MARK: - Properties
        public let timeInterval: TimeInterval

        // MARK: - Initializer
        public init(timeInterval: TimeInterval) {
            self.timeInterval = timeInterval
        }

        // MARK: - Preset
        public static var oneHour: Self { return Self(timeInterval: 3600) }
        public static var oneDay: Self { Self(timeInterval: Self.oneHour.timeInterval * 24) }
        public static var oneWeek: Self { Self(timeInterval: Self.oneDay.timeInterval * 7) }
    }

    // MARK: - Properties
    let storage: AnyLogStorage<Item>?
    @Published public var expirationInterval: ExpirationInterval = .oneDay
    @Published public var log: Log<Item> {
        willSet { log.trimEntries(olderThan: expirationInterval.timeInterval) }
        didSet { try? storage?.store(log) }
    }

    // MARK: - Initializer
    public convenience init() {
        self.init(nil)
    }

    public convenience init<Storage: LogStoring>(storage: Storage?) where Storage.Item == Item {
        self.init(storage.map(AnyLogStorage.init))
    }

    private init(_ storage: AnyLogStorage<Item>?) {
        self.storage = storage
        self.log = (try? storage?.retrieve()) ?? .init()
    }

    // MARK: - Interface
    public func append(_ item: Item) {
        log.append(item)
    }
}
