//
//  LogView.swift
//  DebugKit
//  
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import SwiftUI
import MetricKit

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
                ForEach(logService.log, content: Item.view)
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

#if DEBUG

// MARK: - Preview
struct LogView_Previews: PreviewProvider {

    static var previews: some View {
        LogView(logService: LogService<MXMetricPayload>.init())
            .previewLayout(.sizeThatFits)
    }
}

#endif
