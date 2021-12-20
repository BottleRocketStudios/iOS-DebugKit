//
//  LogList.swift
//  
//
//  Created by Will McGinty on 12/14/21.
//

import SwiftUI

public struct LogList<Item: Recordable>: View {

    // MARK: - Properties
    @ObservedObject var logService: LogService<Item>

    // MARK: - Initializer
    public init(logService: LogService<Item>) {
        self.logService = logService
    }

    // MARK: - View
    public var body: some View {
        if logService.log.isEmpty {
            VStack {
                Image(systemName: "book")
                Text("There's nothing here")
                    .font(.body)
            }
        } else {
            List {
                ForEach(logService.log) { entry in
                    Item.view(for: entry)
                }
                .onDelete(perform: delete)
            }
        }
    }
}

// MARK: - Helper
private extension LogList {

    func delete(at indexSet: IndexSet) {
        logService.remove(atOffsets: indexSet)
    }
}

struct NoEntriesView: View {

    struct Configuration {
        let title: LocalizedStringKey
        let imageName: String

        static let `default` = Configuration(title: "There's nothing here!", imageName: "book")
    }

    // MARK: - Properties
    let configuration: Configuration

    // MARK: - View
    var body: some View {
        VStack {
            Image(systemName: configuration.imageName)
            Text(configuration.title)
                .font(.body)
        }
    }
}
