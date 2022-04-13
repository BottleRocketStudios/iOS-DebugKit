//
//  EnvironmentService.swift
//  Example
//
//  Copyright © 2020 Bottle Rocket Studios. All rights reserved.
//

import Foundation

class EnvironmentService: ObservableObject {

    // MARK: - Environment Subtype
    enum Environment: String, CaseIterable {
        case prod
        case staging
        case development
    }

    // MARK: - Properties
    @Published var selectedEnvironment: Environment = .prod
}
