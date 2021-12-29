//
//  EnvironmentService.swift
//  DebugKit iOS Example
//
//  Created by Will McGinty on 12/28/21.
//

import Foundation

class EnvironmentService: ObservableObject {

    enum Environment: String, CaseIterable {
        case prod
        case staging
        case development
    }

    @Published var selectedEnvironment: Environment = .prod
}
