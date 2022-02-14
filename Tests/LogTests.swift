//
//  LogTests.swift
//  DebugKit Tests
//
//  Created by Will McGinty on 2/7/22.
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

@testable import DebugKit
import XCTest

class LogTests: XCTestCase {

    struct MockIdentifiable: Identifiable {
        var id: UUID
    }

    // MARK: - Entry
    func testLogEntry_mappingEntryMutatesElementPreservesOriginalDate() {
        let date = Date()
        let entry = Log<String>.Entry(date: date, element: "abc")
        let mapped = entry.map { String($0.reversed()) }

        XCTAssertEqual(mapped.element, "cba")
        XCTAssertEqual(mapped.date, date)
    }

    func testLogEntry_entryInheritsIDFromElement() {
        let uuid = UUID()
        let identifiable = MockIdentifiable(id: uuid)
        let entry = Log<MockIdentifiable>.Entry(date: .now, element: identifiable)

        XCTAssertEqual(entry.id, uuid)
        XCTAssertEqual(entry.id, identifiable.id)
    }

    // MARK: - Log
    func testLog_initializesWithEmptyStorage() {
        let log = Log<String>()
        XCTAssertEqual(log.entries, [])
    }

    func testLog_initializesWithStorageMatchingPassedEntries() {
        let entries: [Log<String>.Entry] = [.init(date: .now, element: "abc"),
                                            .init(date: .now, element: "def")]
        let log = Log<String>(entries)
        XCTAssertEqual(log.entries, entries)
    }

    func testLog_appendingEntryInsertsToBeginningOfStorage() {
        var log = Log<String>()
        log.insert("some string")

        XCTAssertEqual(log.count, 1)
        XCTAssertEqual(log.endIndex, 1)
        XCTAssertEqual(log.first?.element, "some string")
    }

    func testLog_trimRemovesEntriesOlderThanDate() {
        let date = Date()
        let entries: [Log<String>.Entry] = [.init(date: date.advanced(by: -2), element: "abc"),
                                            .init(date: date.advanced(by: -1), element: "def"),
                                            .init(date: date, element: "hij")]
        var log = Log<String>(entries)
        log.trimEntries(olderThan: 1, from: date)

        XCTAssertEqual(log.entries.count, 2)
        XCTAssertEqual(log.entries.first?.element, "def")
        XCTAssertEqual(log.entries.last?.element, "hij")
    }

    func testLog_removingClearsSpecificIndices() {
        let entries: [Log<String>.Entry] = [.init(date: .now, element: "abc"),
                                            .init(date: .now, element: "def")]
        var log = Log<String>(entries)
        log.remove(atOffsets: .init(integer: 1))

        XCTAssertEqual(log.entries.count, 1)
        XCTAssertEqual(log.entries.first?.element, "abc")
    }

    func testLog_clearingRemovesAllEntries() {
        let entries: [Log<String>.Entry] = [.init(date: .now, element: "abc"),
                                            .init(date: .now, element: "def")]
        var log = Log<String>(entries)
        log.clear()

        XCTAssertTrue(log.entries.isEmpty)
    }

    func testLog_iteratingOverLogIteratesOverStorage() {
        let entries: [Log<String>.Entry] = [.init(date: .now, element: "abc"),
                                            .init(date: .now, element: "def"),
                                            .init(date: .now, element: "hij")]
        let log = Log<String>(entries)
        let zipped = zip(log, entries)

        for (a, b) in zipped {
            XCTAssertEqual(a, b)
        }
    }

    func testLog_reversingLogReversesUnderlyingStorage() {
        let entries: [Log<String>.Entry] = [.init(date: .now, element: "abc"),
                                            .init(date: .now, element: "def"),
                                            .init(date: .now, element: "hij")]
        let log = Log<String>(entries)
        let zipped = zip(log.reversed(), entries.reversed())

        for (a, b) in zipped {
            XCTAssertEqual(a, b)
        }
    }

    func testLog_mutatingByIndexMutatesStorage() {
        let entries: [Log<String>.Entry] = [.init(date: .now, element: "abc"),
                                            .init(date: .now, element: "def")]
        var log = Log<String>(entries)
        log[1] = .init(date: .now, element: "hij")

        XCTAssertEqual(log.entries.last?.element, "hij")
    }
}
