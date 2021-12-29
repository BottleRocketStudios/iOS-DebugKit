//
//  DebugOptionsCollectionController+Item.swift
//  DebugKit iOS Example
//
//  Created by Will McGinty on 12/28/21.
//

import Foundation
import DebugKit

extension DebugOptionsCollectionController.Item {

    public static func version(for bundle: Bundle = .main) -> Self {
        return .informational(title: "Version", subtitle: bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
    }

    public static func build(for bundle: Bundle = .main) -> Self {
        return .informational(title: "Build", subtitle: bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String)
    }

    public static func deviceToken(for token: Data?) -> Self {
        return .informational(title: "APNS Device Token", subtitle: token?.map { String(format: "%02x", $0) }.joined() ?? "--")
    }

    public static func crashTest() -> Self {
        return .action(.init(title: "Crash") { fatalError("Testing a crash!") })
    }
}

