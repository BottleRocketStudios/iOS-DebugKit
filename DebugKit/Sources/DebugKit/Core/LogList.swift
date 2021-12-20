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
            }
        }
    }
}
