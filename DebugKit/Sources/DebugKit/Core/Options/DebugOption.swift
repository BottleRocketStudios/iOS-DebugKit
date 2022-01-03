//
//  DebugOption+Subtypes.swift
//  
//
//  Created by Will McGinty on 12/27/21.
//

import UIKit

// MARK: - Core Subtypes
public enum DebugOption {

    public typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>

    // MARK: - ConfiguredSection Subtype
    public struct ConfiguredSection {

        // MARK: - Properties
        public let section: Section
        public let items: [Item]

        // MARK: - Initializer
        public init(section: DebugOption.Section, items: [DebugOption.Item]) {
            self.section = section
            self.items = items
        }

        // MARK: - Preset
        public static func environmentPicker<Env: RawRepresentable>(for environments: [Env], withTitle title: String,
                                                                    currentEnvironment: @autoclosure () -> Env,
                                                                    setNewEnvironment: @escaping (Item.Selection, Env) -> Void) -> Self where Env.RawValue == String {
            return .init(section: .init(title: title),
                         items: environments.map { env in .selection(.init(title: env.rawValue,
                                                                           isSelected: env == currentEnvironment(),
                                                                           handler: { setNewEnvironment($0, env) })) })
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

    // MARK: - Item Subtype
    public enum Item: Hashable {
        case action(Action)
        case selection(Selection)
        case navigation(Navigation)

        // MARK: - Interface
        func handleSelection(at indexPath: IndexPath, from collectionController: DebugOptionsCollectionController) {
            switch self {
            case .action(let action): action.handleSelection()
            case .selection(let selection): selection.handleSelection()
            case .navigation(let navigation):
                let destination = navigation.destination()
                collectionController.delegate?.debugOptionsCollectionController(collectionController, didRequestPresentationOf: destination)
            }
        }
    }
}

// MARK: - Item Subtypes
public extension DebugOption.Item {

    // MARK: - Action
    struct Action: Hashable {

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
    struct Navigation: Hashable {

        // MARK: - Properties
        public let title: String
        public let destination: () -> UIViewController

        // MARK: - Initializer
        public init(title: String, destination: UIViewController) {
            self.init(title: title, destination: { destination })
        }

        // MARK: - Initializer
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
    struct Selection: Hashable {

        // MARK: - Properties
        public let title: String
        public let subtitle: String?
        public let isSelected: Bool
        public let handler: (Selection) -> Void

        // MARK: - Initializer
        public init(title: String, subtitle: String? = nil, isSelected: Bool, handler: @escaping (Selection) -> Void) {
            self.title = title
            self.subtitle = subtitle
            self.isSelected = isSelected
            self.handler = handler
        }

        // MARK: - Interface
        func handleSelection() {
            handler(self)
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
}

// MARK: - Item Presets
extension DebugOption.Item {

    // MARK: - Actions
    public static func informational(title: String, subtitle: String?) -> Self {
        return .action(.init(title: title, subtitle: subtitle) { UIPasteboard.general.string = [title, subtitle].compactMap { $0 }.joined(separator: "\n") })
    }

    public static func version(for bundle: Bundle = .main, title: String) -> Self {
        return informational(title: title, subtitle: bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
    }

    public static func build(for bundle: Bundle = .main, title: String) -> Self {
        return informational(title: title, subtitle: bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String)
    }

    public static func pushToken(with data: Data?, title: String) -> Self {
        return informational(title: title, subtitle: data?.map { String(format: "%02x", $0) }.joined() ?? "--")
    }

    public static func action(title: String, subtitle: String? = nil, action: @escaping () -> Void) -> Self {
        return .action(.init(title: title, subtitle: subtitle, action: action))
    }

    // MARK: - Selections
    public static func selection(title: String, subtitle: String? = nil, isSelected: Bool, handler: @escaping (DebugOption.Item.Selection) -> Void) -> Self {
        return .selection(.init(title: title, subtitle: subtitle, isSelected: isSelected, handler: handler))
    }

    // MARK: - Navigations
    public static func navigation(title: String, destination: UIViewController) -> Self {
        return .navigation(.init(title: title, destination: destination))
    }

    public static func navigation(title: String, destination: @escaping () -> UIViewController) -> Self {
        return .navigation(.init(title: title, destination: destination))
    }

    public static func log<T>(for title: String, logService: LogService<T>) -> Self {
        return .navigation(.init(title: title, destination: LogView<T>.viewController(for: logService, title: title)))
    }
}
