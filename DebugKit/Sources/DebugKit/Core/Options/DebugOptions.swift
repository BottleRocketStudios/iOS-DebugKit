//
//  DebugOptions+Subtypes.swift
//  
//
//  Created by Will McGinty on 12/27/21.
//

import UIKit

// MARK: - Section Subtypes
public enum DebugOptions {

    // MARK: - ConfiguredSection Subtype
    public struct ConfiguredSection {

        // MARK: - Properties
        public let section: Section
        public let items: [Item]

        // MARK: - Initializer
        public init(section: DebugOptions.Section, items: [DebugOptions.Item]) {
            self.section = section
            self.items = items
        }

        // MARK: - Preset
        public static func environmentPicker<Env: RawRepresentable>(for environments: [Env], withTitle title: String,
                                                                    currentEnvironment: @autoclosure () -> Env,
                                                                    setNewEnvironment: @escaping (Env) -> Void) -> Self where Env.RawValue == String {
            return .init(section: .init(title: title),
                         items: environments.map { env in .selection(.init(title: env.rawValue,
                                                                           isSelected: env == currentEnvironment(),
                                                                           handler: { setNewEnvironment(env) })) })
        }
    }

    // MARK: - Section Subtype
    public struct Section: Hashable {

        // MARK: - Properties
        public let title: String?
        public let footerText: String?

        // MARK: - Initializer
        public init(title: String?, footerText: String? = nil) {
            self.title = title
            self.footerText = footerText
        }
    }
}

// MARK: - Item Subtypes
extension DebugOptions {

    public enum Item: Hashable {

        // MARK: - Action
        public struct Action: Hashable {

            // MARK: - Properties
            public let title: String
            public let subtitle: String?
            public let action: () -> Void

            // MARK: - Initializer
            public init(title: String, subtitle: String? = nil, action: @escaping () -> Void) {
                self.title = title
                self.subtitle = subtitle
                self.action = action
            }

            // MARK: - Interface
            func handleSelection() {
                action()
            }

            // MARK: Hashable
            public func hash(into hasher: inout Hasher) {
                hasher.combine(title)
                hasher.combine(subtitle)
            }

            public static func == (lhs: Action, rhs: Action) -> Bool {
                return lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
            }
        }

        // MARK: - Navigation
        public struct Navigation: Hashable {
            
            // MARK: - Properties
            public let title: String
            public let destination: () -> UIViewController

            // MARK: - Initializer
            public init(title: String, destination: UIViewController) {
                self.init(title: title, destination: { destination })
            }

            public init(title: String, destination: @escaping () -> UIViewController) {
                self.title = title
                self.destination = destination
            }

            // MARK: Hashable
            public func hash(into hasher: inout Hasher) {
                hasher.combine(title)
            }

            public static func == (lhs: Navigation, rhs: Navigation) -> Bool {
                return lhs.title == rhs.title
            }
        }

        // MARK: - Selection
        public struct Selection: Hashable {

            // MARK: - Properties
            public let title: String
            public let subtitle: String?
            public let isSelected: Bool
            public let handler: () -> Void

            public init(title: String, subtitle: String? = nil, isSelected: Bool, handler: @escaping () -> Void) {
                self.title = title
                self.subtitle = subtitle
                self.isSelected = isSelected
                self.handler = handler
            }

            // MARK: - Interface
            func handleSelection() {
                handler()
            }

            // MARK: Hashable
            public func hash(into hasher: inout Hasher) {
                hasher.combine(title)
                hasher.combine(subtitle)
                hasher.combine(isSelected)
            }

            public static func == (lhs: Selection, rhs: Selection) -> Bool {
                return lhs.title == rhs.title && lhs.subtitle == rhs.subtitle && lhs.isSelected == rhs.isSelected
            }
        }

        case action(Action)
        case selection(Selection)
        case navigation(Navigation)

        // MARK: - Interface
        func handleSelection(at indexPath: IndexPath, from collectionController: DebugOptionsCollectionController) {
            switch self {
            case .action(let action): action.handleSelection()
            case .selection(let selection): selection.handleSelection()
            case .navigation(let navigation): collectionController.delegate?.debugOptionsCollectionController(collectionController, didRequestPresentationOf: navigation.destination())
            }
        }

        // MARK: - Preset Actions
        public static func informational(title: String, subtitle: String?) -> Item {
            return .action(.init(title: title, subtitle: subtitle) { UIPasteboard.general.string = [title, subtitle].compactMap { $0 }.joined(separator: "\n") })
        }

        public static func pushToken(with data: Data?, title: String) -> Item {
            return informational(title: title, subtitle: data?.map { String(format: "%02x", $0) }.joined() ?? "--")
        }

        public static func action(title: String, subtitle: String? = nil, action: @escaping () -> Void) -> Item {
            return .action(.init(title: title, subtitle: subtitle, action: action))
        }


        // MARK: - Preset Selections
        public static func selection(title: String, subtitle: String? = nil, isSelected: Bool, handler: @escaping () -> Void) -> Item {
            return .selection(.init(title: title, subtitle: subtitle, isSelected: isSelected, handler: handler))
        }


        // MARK: - Preset Navigations
        public static func navigation(title: String, destination: UIViewController) -> Item {
            return .navigation(.init(title: title, destination: destination))
        }

        public static func navigation(title: String, destination: @escaping () -> UIViewController) -> Item {
            return .navigation(.init(title: title, destination: destination))
        }

        public static func log<T>(for title: String, logService: LogService<T>) -> Item {
            return .navigation(.init(title: title, destination: LogView<T>.viewController(for: logService, title: title)))
        }
    }
}
