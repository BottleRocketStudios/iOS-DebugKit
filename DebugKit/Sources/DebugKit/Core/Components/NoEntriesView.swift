//
//  NoEntriesView.swift
//  
//
//  Created by Will McGinty on 12/22/21.
//

import SwiftUI

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
