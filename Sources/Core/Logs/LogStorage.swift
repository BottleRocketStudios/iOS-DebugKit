//
//  LogStorage.swift
//  DebugKit
//  
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import CryptoKit

// MARK: - LogStoring
public protocol LogStoring {
    associatedtype Item

    func store(_ log: Log<Item>) throws
    func retrieve() throws -> Log<Item>?
}

// MARK: - LogFileStorage
public class LogFileStorage<Item: Codable>: LogStoring {

    // MARK: - EncryptionKind Subtype
    public enum EncryptionKind {
        case none
        case symmetricKey(SymmetricKey)

        func encryptedData(from data: Data) throws -> Data? {
            switch self {
            case .none: return data
            case .symmetricKey(let key):
                let sealed = try AES.GCM.seal(data, using: key, nonce: .init())
                return sealed.combined
            }
        }

        func decryptedData(from data: Data) throws -> Data {
            switch self {
            case .none: return data
            case .symmetricKey(let key): return try AES.GCM.open(.init(combined: data), using: key)
            }
        }
    }

    // MARK: - Properties
    public let url: URL
    public let fileManager: FileManager

    public var encoder: JSONEncoder = .init()
    public var decoder: JSONDecoder = .init()

    public var encryptionKind: EncryptionKind = .none
    public var fileProtection: FileProtectionType = .completeUntilFirstUserAuthentication

    // MARK: - Initializer
    public init(url: URL, fileManager: FileManager = .default) {
        self.url = url
        self.fileManager = fileManager
    }

    // MARK: - Interface
    public func store(_ log: Log<Item>) throws {
        let data = try encoder.encode(log)
        let encryptedData = try encryptionKind.encryptedData(from: data)

        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }

        fileManager.createFile(atPath: url.path, contents: encryptedData, attributes: [.protectionKey: fileProtection])
    }

    public func retrieve() throws -> Log<Item>? {
        do {
            let data = try Data(contentsOf: url)
            let decryptedData = try encryptionKind.decryptedData(from: data)
            return try decoder.decode(Log<Item>.self, from: decryptedData)

        } catch CocoaError.fileReadNoSuchFile {
            // If the file can't be read because it doesn't exist, we can infer an empty log
            return nil
        }
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
