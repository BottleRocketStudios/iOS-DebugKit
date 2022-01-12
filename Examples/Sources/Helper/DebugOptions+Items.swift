//
//  DebugOptionsCollectionController+Item.swift
//  Example
//
//  Copyright © 2020 Bottle Rocket Studios. All rights reserved.
//

import DebugKit
import Wormholy

extension DebugOption.Item {

    public static func crashTest() -> Self {
        return .action(title: "Crash") { fatalError("Testing a crash!") }
    }

    public static func wormholy() -> Self {
        guard let wormholyViewController = Wormholy.wormholyFlow else {
            return .informational(title: "Wormholy not available")
        }

        return .presentation(of: .modal, withTitle: "Network Traffic", to: wormholyViewController)
    }

    public static func colorReview() -> Self {
        return .presentation(of: .navigation, withTitle: "Color Review") {
            ColorsView(colors: [.blue, .brown, .cyan, .green, .indigo, .mint, .orange, .yellow, .pink, .red])
        }
    }
}
