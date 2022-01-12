//
//  DebugOptionCollectionContenetProviders.swift
//  DebugKit
//  
//  Copyright © 2022 Bottle Rocket Studios. All rights reserved.
//

import UIKit

// MARK: - CellContentProvider
public class CellContentProvider {

    // MARK: - Properties
    public let actionCell: UICollectionView.CellRegistration<UICollectionViewListCell, DebugOption.Item.Action>
    public let selectionCell: UICollectionView.CellRegistration<UICollectionViewListCell, DebugOption.Item.Selection>
    public let navigationCell: UICollectionView.CellRegistration<UICollectionViewListCell, DebugOption.Item.Presentation>

    // MARK: - Initializers
    public init(actionCell: UICollectionView.CellRegistration<UICollectionViewListCell, DebugOption.Item.Action> = .defaultDebugItemActionCell,
                selectionCell: UICollectionView.CellRegistration<UICollectionViewListCell, DebugOption.Item.Selection> = .defaultDebugItemSelectionCell,
                navigationCell: UICollectionView.CellRegistration<UICollectionViewListCell, DebugOption.Item.Presentation> = .defaultDebugItemNavigationCell) {
        self.actionCell = actionCell
        self.selectionCell = selectionCell
        self.navigationCell = navigationCell
    }

    // MARK: - Interface
    public func cell(in collectionView: UICollectionView, at indexPath: IndexPath, for content: DebugOption.Item) -> UICollectionViewCell? {
        switch content {
        case let .action(action): return collectionView.dequeueConfiguredReusableCell(using: actionCell, for: indexPath, item: action)
        case let .selection(selection): return collectionView.dequeueConfiguredReusableCell(using: selectionCell, for: indexPath, item: selection)
        case let .presentation(navigation): return collectionView.dequeueConfiguredReusableCell(using: navigationCell, for: indexPath, item: navigation)
        }
    }
}

// MARK: - SupplementaryContentProvider
public class SupplementaryContentProvider {

    // MARK: - Properties
    public let header: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>
    public let footer: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>

    // MARK: - Initializer
    public convenience init(dataSource: DebugOption.DataSource) {
        let sectionRetriever: (IndexPath) -> DebugOption.Section = { dataSource.snapshot().sectionIdentifiers[$0.section] }
        self.init(header: .defaultHeader(for: sectionRetriever), footer: .defaultFooter(for: sectionRetriever))
    }

    public init(header: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>,
                footer: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>) {
        self.header = header
        self.footer = footer
    }

    // MARK: - Interface
    public func supplementaryView(in collectionView: UICollectionView, of kind: String, at indexPath: IndexPath) -> UICollectionReusableView? {
        switch kind {
        case UICollectionView.elementKindSectionHeader: return collectionView.dequeueConfiguredReusableSupplementary(using: header, for: indexPath)
        case UICollectionView.elementKindSectionFooter: return collectionView.dequeueConfiguredReusableSupplementary(using: footer, for: indexPath)
        default: return nil
        }
    }
}

// MARK: - Default Cell Registrations
public extension UICollectionView.CellRegistration {

    static var defaultDebugItemActionCell: UICollectionView.CellRegistration<UICollectionViewListCell, DebugOption.Item.Action> {
        return .init { cell, _, configuration in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = configuration.title
            contentConfiguration.secondaryText = configuration.subtitle

            cell.contentConfiguration = contentConfiguration
        }
    }

    static var defaultDebugItemSelectionCell: UICollectionView.CellRegistration<UICollectionViewListCell, DebugOption.Item.Selection> {
        return .init { cell, _, configuration in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = configuration.title
            contentConfiguration.secondaryText = configuration.subtitle

            cell.contentConfiguration = contentConfiguration
            cell.accessories = configuration.isSelected ? [.checkmark()] : []
        }
    }

    static var defaultDebugItemNavigationCell: UICollectionView.CellRegistration<UICollectionViewListCell, DebugOption.Item.Presentation> {
        return .init { cell, _, configuration in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = configuration.title

            cell.contentConfiguration = contentConfiguration
            cell.accessories = [.disclosureIndicator()]
        }
    }
}

// MARK: - Default Supplementary View Registrations
public extension UICollectionView.SupplementaryRegistration {

    static func defaultHeader(for section: @escaping (IndexPath) -> DebugOption.Section) -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, _, indexPath in
            var contentConfiguration = supplementaryView.defaultContentConfiguration()
            contentConfiguration.text = section(indexPath).title

            supplementaryView.contentConfiguration = contentConfiguration
        }
    }

    static func defaultFooter(for section: @escaping (IndexPath) -> DebugOption.Section) -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionFooter) { supplementaryView, _, indexPath in
            var contentConfiguration = supplementaryView.defaultContentConfiguration()
            contentConfiguration.text = section(indexPath).footerText

            supplementaryView.contentConfiguration = contentConfiguration
        }
    }
}
