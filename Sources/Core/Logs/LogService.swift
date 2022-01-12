//
//  LogService.swift
//  DebugKit
//  
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import SwiftUI

// MARK: - Recordable
public protocol Recordable: Identifiable {
    associatedtype Record: Recordable = Self
    associatedtype LogView: View

    var record: Record { get }
    @ViewBuilder static func view(for entry: Log<Record>.Entry) -> LogView
}

public extension Recordable where Record == Self {
    var record: Record { return self }
}

// MARK: - LogService
public class LogService<Item: Recordable>: ObservableObject {

    // MARK: - Subtypes
    public struct ExpirationInterval {

        // MARK: - Properties
        public let timeInterval: TimeInterval?

        // MARK: - Initializer
        public init(timeInterval: TimeInterval?) {
            self.timeInterval = timeInterval
        }

        // MARK: - Preset
        public static var none: Self { return Self(timeInterval: nil) }
        public static var oneHour: Self { return Self(timeInterval: 3600) }
        public static var oneDay: Self { Self(timeInterval: 3600 * 24) }
        public static var oneWeek: Self { Self(timeInterval: 3600 * 24 * 7) }

        // MARK: - Interface
        func trim(log: inout Log<Item.Record>, on date: Date = Date()) {
            if let timeInterval = timeInterval {
                log.trimEntries(olderThan: timeInterval, on: date)
            }
        }
    }

    // MARK: - Properties
    let storage: AnyLogStorage<Item.Record>?
    @Published public var expirationInterval: ExpirationInterval = .oneWeek
    @Published public var log: Log<Item.Record> {
        didSet { try? storage?.store(log) }
    }

    // MARK: - Initializers
    public convenience init() {
        self.init(nil)
    }

    public convenience init<Storage: LogStoring>(storage: Storage?) where Storage.Item == Item.Record {
        self.init(storage.map(AnyLogStorage.init))
    }

    private init(_ storage: AnyLogStorage<Item.Record>?) {
        self.storage = storage
        self.log = (try? storage?.retrieve()) ?? .init()

        expirationInterval.trim(log: &log)
    }

    // MARK: - Interface
    public func append(_ item: Item) {
        expirationInterval.trim(log: &log)
        log.append(item.record)
    }

    public func remove(atOffsets offsets: IndexSet) {
        log.remove(atOffsets: offsets)
    }
}
