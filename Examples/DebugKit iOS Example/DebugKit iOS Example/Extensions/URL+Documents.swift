//
//  URL+Documents.swift
//  DebugKit iOS Example
//
//  Created by Will McGinty on 12/23/21.
//

import Foundation


extension URL {

    static var documentsDirectory: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
