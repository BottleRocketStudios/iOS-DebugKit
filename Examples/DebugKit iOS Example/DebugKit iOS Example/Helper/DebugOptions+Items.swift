//
//  DebugOptionsCollectionController+Item.swift
//  DebugKit iOS Example
//
//  Created by Will McGinty on 12/28/21.
//  Copyright © 2020 Bottle Rocket Studios. All rights reserved.
//

import DebugKit
import Foundation

extension DebugOption.Item {

    public static func crashTest() -> Self {
        return .action(title: "Crash") { fatalError("Testing a crash!") }
    }
}
