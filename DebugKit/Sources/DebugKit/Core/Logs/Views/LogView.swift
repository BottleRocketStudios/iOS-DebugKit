//
//  LogView.swift
//  DebugKit
//  
//
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import SwiftUI

public struct LogView<Item: Recordable>: View {

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
private extension LogView {

    func delete(at indexSet: IndexSet) {
        logService.remove(atOffsets: indexSet)
    }
}

// MARK: - Convenience
public extension LogView {

    static func viewController<T: Recordable>(for logService: LogService<T>, title: String) -> UIViewController {
        let hostingController = UIHostingController(rootView: LogView<T>(logService: logService))
        hostingController.title = title

        return hostingController
    }
}
