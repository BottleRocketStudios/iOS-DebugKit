//
//  Log.swift
//  DebugKit
//  
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import SwiftUI

public struct Log<Element> {

    public struct Entry {

        // MARK: - Properties
        public let date: Date
        public let element: Element

        // MARK: - Interface
        public func map<T>(_ transform: (Element) -> T) -> Log<T>.Entry {
            return .init(date: date, element: transform(element))
        }
    }

    // MARK: - Properties
    private(set) var entries: [Entry]

    // MARK: - Initializers
    public init() {
        self.init([])
    }

    public init<C: Collection>(_ entries: C) where C.Element == Entry {
        self.entries = Array(entries)
    }
}

// MARK: - MutableCollection
extension Log: MutableCollection {

    public mutating func append(_ item: Element, on date: Date = Date()) {
        entries.insert(.init(date: date, element: item), at: startIndex)
    }

    public mutating func trimEntries(olderThan timeInterval: TimeInterval, on date: Date = Date()) {
        entries.removeAll(where: { date.timeIntervalSince($0.date) > timeInterval })
    }

    public mutating func remove(atOffsets offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
    }
}

// MARK: - RandomAccessCollection
extension Log: RandomAccessCollection {

    public var startIndex: Int { return entries.startIndex }
    public var endIndex: Int { return entries.endIndex }

    public func index(after i: Int) -> Int {
        return entries.index(after: i)
    }

    public func index(before i: Int) -> Int {
        return entries.index(before: i)
    }

    public subscript (position: Int) -> Entry {
        get { return entries[position] }
        set { entries[position] = newValue }
    }
}

// MARK: - Identifiable
extension Log.Entry: Identifiable where Element: Identifiable {
    public var id: Element.ID { return element.id }
}

// MARK: - Hashable
extension Log.Entry: Hashable where Element: Hashable { }
extension Log.Entry: Equatable where Element: Equatable { }

extension Log: Hashable where Element: Hashable { }
extension Log: Equatable where Element: Equatable { }

// MARK: - Codable
extension Log.Entry: Codable where Element: Codable { }
extension Log: Codable where Element: Codable { }
