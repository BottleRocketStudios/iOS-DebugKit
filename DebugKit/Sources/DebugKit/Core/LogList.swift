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
            NoEntriesView(configuration: .default)

        } else {
            List {
                ForEach(logService.log) { Item.view(for: $0) }
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

// MARK: - Convenience
public extension LogList {

    static func viewController<T: Recordable>(for logService: LogService<T>) -> UIViewController {
        return UIHostingController(rootView: LogList<T>(logService: logService))
    }
}
