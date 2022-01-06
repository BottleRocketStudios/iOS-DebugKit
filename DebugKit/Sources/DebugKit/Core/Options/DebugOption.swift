//
//  DebugOption+Subtypes.swift
//  DebugKit
//  
//
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import UIKit
import SwiftUI

// MARK: - Core Subtypes
public enum DebugOption {

    public typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>

    // MARK: - ConfiguredSection Subtype
    public struct ConfiguredSection: Hashable {

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
        case presentation(Presentation)

        // MARK: - Interface
        func handleSelection(at indexPath: IndexPath, from collectionController: DebugOptionsCollectionController) {
            switch self {
            case .action(let action): action.handleSelection()
            case .selection(let selection): selection.handleSelection()
            case .presentation(let presentation):
                let destination = presentation.destination()
                collectionController.delegate?.debugOptionsCollectionController(collectionController, didRequestPresentationOf: destination, style: presentation.style)
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

    // MARK: - Navigation
    struct Presentation: Hashable {

        // MARK: - Style Subtype
        public enum Style {
            case modal, navigation
        }

        // MARK: - Properties
        public let title: String
        public let destination: () -> UIViewController
        public let style: Style

        // MARK: - Initializer
        public init(title: String, style: Style, destination: UIViewController) {
            self.init(title: title, style: style, destination: { destination })
        }

        // MARK: - Initializer
        public init(title: String, style: Style, destination: @escaping () -> UIViewController) {
            self.title = title
            self.style = style
            self.destination = destination
        }

        // MARK: Hashable
        public func hash(into hasher: inout Hasher) {
            hasher.combine(title)
            hasher.combine(style)
        }

        public static func == (lhs: Presentation, rhs: Presentation) -> Bool {
            return lhs.title == rhs.title && lhs.style == rhs.style
        }
    }
}

// MARK: - Item Presets
extension DebugOption.Item {

    // MARK: - Actions
    public static func informational(title: String, subtitle: String? = nil) -> Self {
        return .action(.init(title: title, subtitle: subtitle) { UIPasteboard.general.string = [title, subtitle].compactMap { $0 }.joined(separator: "\n") })
    }

    public static func version(for bundle: Bundle = .main, title: String) -> Self {
        return informational(title: title, subtitle: bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
    }

    public static func build(for bundle: Bundle = .main, title: String) -> Self {
        return informational(title: title, subtitle: bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String)
    }

    public static func pushToken(with data: Data?, title: String) -> Self {
        return informational(title: title, subtitle: data?.map { String(format: "%02x", $0) }.joined() ?? "No Token")
    }

    public static func action(title: String, subtitle: String? = nil, action: @escaping () -> Void) -> Self {
        return .action(.init(title: title, subtitle: subtitle, action: action))
    }

    // MARK: - Selections
    public static func selection(title: String, subtitle: String? = nil, isSelected: Bool, handler: @escaping (DebugOption.Item.Selection) -> Void) -> Self {
        return .selection(.init(title: title, subtitle: subtitle, isSelected: isSelected, handler: handler))
    }

    // MARK: - Presentations
    public static func presentation(of style: Self.Presentation.Style, withTitle title: String, to destination: UIViewController) -> Self {
        return .presentation(.init(title: title, style: style, destination: destination))
    }

    public static func presentation(of style: Self.Presentation.Style, withTitle title: String, to destination: @escaping () -> UIViewController) -> Self {
        return .presentation(.init(title: title, style: style, destination: destination))
    }

    public static func presentation<T: View>(of style: Self.Presentation.Style, withTitle title: String, to destination: T) -> Self {
        return .presentation(of: style, withTitle: title, to: UIHostingController(rootView: destination))
    }

    public static func presentation<T: View>(of style: Self.Presentation.Style, withTitle title: String, to destination: @escaping () -> T) -> Self {
        return .presentation(of: style, withTitle: title) { UIHostingController(rootView: destination()) }
    }

    public static func log<T>(for title: String, logService: LogService<T>) -> Self {
        return .presentation(.init(title: title, style: .navigation, destination: LogView<T>.viewController(for: logService, title: title)))
    }
}
