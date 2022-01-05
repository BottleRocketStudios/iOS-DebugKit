//
//  UICollectionViewRegistrations.swift
//  DebugKit iOS Example
//
//  Created by Will McGinty on 12/30/21.
//  Copyright © 2020 Bottle Rocket Studios. All rights reserved.
//

import DebugKit
import UIKit

extension UICollectionView.CellRegistration {

    static var testAction: UICollectionView.CellRegistration<UICollectionViewListCell, DebugOption.Item.Action> {
        return .init { cell, _, action in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = action.title
            contentConfiguration.textProperties.font = UIFont.systemFont(ofSize: 10, weight: .light)

            contentConfiguration.secondaryText = action.subtitle
            contentConfiguration.secondaryTextProperties.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            contentConfiguration.secondaryTextProperties.numberOfLines = 0

            cell.contentConfiguration = contentConfiguration
        }
    }

    static var testSelection: UICollectionView.CellRegistration<UICollectionViewListCell, DebugOption.Item.Selection> {
        return .init { cell, _, selection in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = selection.title
            contentConfiguration.textProperties.font = UIFont.systemFont(ofSize: 10, weight: .light)

            contentConfiguration.secondaryText = selection.subtitle
            contentConfiguration.secondaryTextProperties.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            contentConfiguration.secondaryTextProperties.numberOfLines = 0

            cell.contentConfiguration = contentConfiguration
        }
    }

    static var testNavigation: UICollectionView.CellRegistration<UICollectionViewListCell, DebugOption.Item.Presentation> {
        return .init { cell, _, navigation in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = navigation.title
            contentConfiguration.textProperties.font = UIFont.systemFont(ofSize: 10, weight: .light)

            cell.contentConfiguration = contentConfiguration
        }
    }
}

extension UICollectionView.SupplementaryRegistration {

    static func testHeader(for section: @escaping (IndexPath) -> DebugOption.Section) -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, _, indexPath in
            var contentConfiguration = supplementaryView.defaultContentConfiguration()
            contentConfiguration.textProperties.font = UIFont.systemFont(ofSize: 10, weight: .bold)
            contentConfiguration.text = section(indexPath).title

            supplementaryView.contentConfiguration = contentConfiguration
        }
    }

    static func testFooter(for section: @escaping (IndexPath) -> DebugOption.Section) -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionFooter) { supplementaryView, _, indexPath in
            var contentConfiguration = supplementaryView.defaultContentConfiguration()
            contentConfiguration.textProperties.font = UIFont.systemFont(ofSize: 10, weight: .light)
            contentConfiguration.text = section(indexPath).footerText

            supplementaryView.contentConfiguration = contentConfiguration
        }
    }
}
