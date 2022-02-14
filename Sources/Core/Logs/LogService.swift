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
    associatedtype RecordView: View

    var record: Record { get }
    @ViewBuilder static func view(for entry: Log<Record>.Entry) -> RecordView
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
        func trim(log: inout Log<Item.Record>, from date: Date = Date()) {
            if let timeInterval = timeInterval {
                log.trimEntries(olderThan: timeInterval, from: date)
            }
        }
    }

    // MARK: - Properties
    let storage: AnyLogStorage<Item.Record>?
    @Published public var isEnabled = true
    @Published public var expirationInterval: ExpirationInterval = .oneWeek
    @Published public var log: Log<Item.Record> {
        didSet { storeLog() }
    }

    // MARK: - Initializers
    public init() {
        self.storage = nil
        self.log = .init()
    }

    public convenience init<Storage: LogStoring>(storage: Storage) throws where Storage.Item == Item.Record {
        try self.init(AnyLogStorage(storage))
    }

    private init(_ storage: AnyLogStorage<Item.Record>) throws {
        self.storage = storage
        self.log = try storage.retrieve() ?? .init()

        expirationInterval.trim(log: &log)
    }

    // MARK: - Interface
    public func insert(_ item: Item) {
        if isEnabled {
            expirationInterval.trim(log: &log)
            log.insert(item.record)
        }
    }

    public func remove(atOffsets offsets: IndexSet) {
        log.remove(atOffsets: offsets)
    }

    public func clear() {
        log.clear()
    }
}

// MARK: - Helper
private extension LogService {

    func storeLog() {
        do {
            try storage?.store(log)
        } catch {
            debugPrint("Error storing updated log: \(error)")
        }
    }
}
