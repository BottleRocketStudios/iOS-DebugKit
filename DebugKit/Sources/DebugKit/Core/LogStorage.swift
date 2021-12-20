//
//  LogStorage.swift
//  
//
//  Created by Will McGinty on 12/16/21.
//

import Foundation

public protocol LogStoring {
    associatedtype Item

    func store(_ log: Log<Item>) throws
    func retrieve() throws -> Log<Item>?
}

class AnyLogStorage<Item>: LogStoring {

    private let _store: (Log<Item>) throws -> Void
    private let _retrieve: () throws -> Log<Item>?

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

public class LogFileStorage<Item: Codable>: LogStoring {

    // MARK: - Properties
    public let url: URL

    // MARK: - Initializer
    public init(url: URL) {
        self.url = url
    }

    // MARK: - Interface
    public func store(_ log: Log<Item>) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(log)
        try data.write(to: url, options: [.atomic])
    }

    public func retrieve() throws -> Log<Item>? {
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try decoder.decode(Log<Item>.self, from: data)
    }
}
