//
//  NoEntriesView.swift
//  DebugKit
//  
//
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
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
        VStack(spacing: 10) {
            Image(systemName: configuration.imageName)
                .font(Font.system(size: 40, weight: .regular, design: .default))
            Text(configuration.title)
                .font(.title2)
        }
    }
}

// MARK: - Preview
struct NoEntriesView_Previews: PreviewProvider {

    static var previews: some View {
        NoEntriesView(configuration: .default)

        NoEntriesView(configuration: .default)
            .preferredColorScheme(.dark)
    }
}
