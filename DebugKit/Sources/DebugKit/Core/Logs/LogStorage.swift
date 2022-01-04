//
//  LogStorage.swift
//  DebugKit
//  
//
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import Foundation

// MARK: - LogStoring
public protocol LogStoring {
    associatedtype Item

    func store(_ log: Log<Item>) throws
    func retrieve() throws -> Log<Item>?
}

// MARK: - LogFileStorage
public class LogFileStorage<Item: Codable>: LogStoring {

    // MARK: - Properties
    public let url: URL

    // MARK: - Initializer
    public init(url: URL) {
        self.url = url
    }

    // MARK: - Interface
    public func store(_ log: Log<Item>) throws {
        let data = try JSONEncoder().encode(log)
        try data.write(to: url, options: [.atomic])
    }

    public func retrieve() throws -> Log<Item>? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try JSONDecoder().decode(Log<Item>.self, from: data)
    }
}

// MARK: - AnyLogStorage
class AnyLogStorage<Item>: LogStoring {

    // MARK: - Properties
    private let _store: (Log<Item>) throws -> Void
    private let _retrieve: () throws -> Log<Item>?

    // MARK: - Initializer
    init<Storage: LogStoring>(_ storage: Storage) where Storage.Item == Item {
        self._store = storage.store
        self._retrieve = storage.retrieve
    }

    // MARK: - Interface
    func store(_ log: Log<Item>) throws {
        try _store(log)
    }

    func retrieve() throws -> Log<Item>? {
        return try _retrieve()
    }
}
