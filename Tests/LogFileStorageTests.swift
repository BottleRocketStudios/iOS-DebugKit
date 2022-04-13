//
//  LogFileStorageTests.swift
//  DebugKit Tests
//
//  Created by Will McGinty on 2/14/22.
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import CryptoKit
@testable import DebugKit
import XCTest

class LogFileStorageTests: XCTestCase {

    struct Mock: Codable {
        let id: UUID

        init() {
            id = UUID()
        }
    }

    private lazy var storageURL: URL = FileManager.default.temporaryDirectory.appendingPathComponent("testLog")

    // MARK: - Tear Down
    override func tearDown() {
        try? FileManager.default.removeItem(at: storageURL)
    }

    // MARK: - Tests
    func testLogFileStorage_logWithEmptyURLReturnsEmptyLog() throws {
        let storage = LogFileStorage<Mock>(url: storageURL)

        XCTAssertNil(try storage.retrieve())
    }

    func testLogFileStorage_storingLogMultipleTimesOverwritesPrevious() throws {
        var log = Log<Mock>([.init(date: .now, element: .init())])
        let storage = LogFileStorage<Mock>(url: storageURL)

        XCTAssertNoThrow(try storage.store(log))
        log.insert(.init())
        XCTAssertNoThrow(try storage.store(log))

        let retrieved = try storage.retrieve()
        XCTAssertEqual(retrieved?.count, 2)
    }

    func testLogFileStorage_encryptionKindNoneReturnsInput() throws {
        let encryptionKind = LogFileStorage<Mock>.EncryptionKind.none
        let contents = "abcdefghijklmnopqrstuvwxyz".data(using: .utf8)!

        let encrypted = try encryptionKind.encryptedData(from: contents)!
        XCTAssertEqual(encrypted, contents)

        let decrypted = try encryptionKind.decryptedData(from: encrypted)
        XCTAssertEqual(decrypted, contents)
    }

    func testLogFileStorage_encryptionKindUsesSymmetricKeyToEncryptAndDecryptContents() throws {
        let key = SymmetricKey(size: .bits256)
        let encryptionKind = LogFileStorage<Mock>.EncryptionKind.symmetricKey(key)
        let contents = "abcdefghijklmnopqrstuvwxyz".data(using: .utf8)!

        let encrypted = try encryptionKind.encryptedData(from: contents)!
        XCTAssertNotEqual(encrypted, contents)

        let decrypted = try encryptionKind.decryptedData(from: encrypted)
        XCTAssertEqual(decrypted, contents)
    }
}
