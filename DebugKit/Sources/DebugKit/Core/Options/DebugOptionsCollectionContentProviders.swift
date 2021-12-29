//
//  DebugOptionsCollectionContenetProviders.swift
//  
//
//  Created by Will McGinty on 12/23/21.
//

import Foundation
import UIKit

extension DebugOptionsCollectionController {

    class CellContentProvider {

        // MARK: - Properties
        let defaultActionCell: UICollectionView.CellRegistration<UICollectionViewListCell, Item.Action>
        let defaultSelectionCell: UICollectionView.CellRegistration<UICollectionViewListCell, Item.Selection>
        let defaultNavigationCell: UICollectionView.CellRegistration<UICollectionViewListCell, Item.Navigation>

        // MARK: - Initializer
        init() {
            self.defaultActionCell = .init { cell, _, configuration in
                var contentConfiguration = UIListContentConfiguration.valueCell()
                contentConfiguration.text = configuration.title
                contentConfiguration.secondaryText = configuration.subtitle
                
                cell.contentConfiguration = contentConfiguration
            }

            self.defaultSelectionCell = .init { cell, _, configuration in
                var contentConfiguration = UIListContentConfiguration.valueCell()
                contentConfiguration.text = configuration.title
                contentConfiguration.secondaryText = configuration.subtitle
                cell.contentConfiguration = contentConfiguration

                cell.accessories = configuration.isSelected ? [.checkmark()] : []
            }

            self.defaultNavigationCell = .init { cell, _, configuration in
                var contentConfiguration = UIListContentConfiguration.valueCell()
                contentConfiguration.text = configuration.title
                cell.contentConfiguration = contentConfiguration

                cell.accessories = [.disclosureIndicator()]
            }
        }

        // MARK: - Interface
        func cell(in collectionView: UICollectionView, at indexPath: IndexPath, for content: Item) -> UICollectionViewCell? {
            switch content {
            case let .action(action): return collectionView.dequeueConfiguredReusableCell(using: defaultActionCell, for: indexPath, item: action)
            case let .selection(selection): return collectionView.dequeueConfiguredReusableCell(using: defaultSelectionCell, for: indexPath, item: selection)
            case let .navigation(navigation): return collectionView.dequeueConfiguredReusableCell(using: defaultNavigationCell, for: indexPath, item: navigation)
            }
        }
    }

    class SupplementaryContentProvider {

        // MARK: - Properties
        let defaultHeader: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>
        let defaultFooter: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>

        // MARK: - Initializer
        init(dataSource: DataSource) {
            self.defaultHeader = .init(elementKind: UICollectionView.elementKindSectionHeader) { [unowned dataSource] supplementaryView, _, indexPath in
                let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]

                var contentConfiguration = UIListContentConfiguration.groupedHeader()
                contentConfiguration.text = section.title
                supplementaryView.contentConfiguration = contentConfiguration
            }

            self.defaultFooter = .init(elementKind: UICollectionView.elementKindSectionFooter) { [unowned dataSource] supplementaryView, _, indexPath in
                let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]

                var contentConfiguration = UIListContentConfiguration.groupedFooter()
                contentConfiguration.text = section.footerText
                supplementaryView.contentConfiguration = contentConfiguration
            }
        }

        // MARK: - Interface
        func supplementaryView(in collectionView: UICollectionView, of kind: String, at indexPath: IndexPath) -> UICollectionReusableView? {
            switch kind {
            case UICollectionView.elementKindSectionHeader: return collectionView.dequeueConfiguredReusableSupplementary(using: defaultHeader, for: indexPath)
            case UICollectionView.elementKindSectionFooter: return collectionView.dequeueConfiguredReusableSupplementary(using: defaultFooter, for: indexPath)
            default: return nil
            }
        }
    }
}
